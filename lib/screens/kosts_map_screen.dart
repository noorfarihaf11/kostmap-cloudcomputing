import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../data/kost_service.dart';
import '../data/route_service.dart';
import '../models/kost_model.dart';
import '../theme/app_theme.dart';
import '../widgets/category_badge.dart';
import 'detail_screen.dart';

class KostsMapScreen extends StatefulWidget {
  const KostsMapScreen({super.key});

  @override
  State<KostsMapScreen> createState() => _KostsMapScreenState();
}

class _KostsMapScreenState extends State<KostsMapScreen> {
  final MapController _mapController = MapController();
  
  List<Kost> _kosts = [];
  bool _loadingKosts = true;
  String? _errorMessage;

  LatLng? _userLocation;
  StreamSubscription<Position>? _positionStreamSubscription;

  Kost? _selectedKost;
  RouteResult? _routeResult;
  bool _loadingRoute = false;

  // Default center: Sidoarjo
  static const LatLng _defaultCenter = LatLng(-7.4478, 112.7183);

  @override
  void initState() {
    super.initState();
    _loadKosts();
    _initLocationTracking();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadKosts() async {
    setState(() {
      _loadingKosts = true;
      _errorMessage = null;
    });
    try {
      final list = await KostService.fetchAllKost();
      if (mounted) {
        setState(() {
          _kosts = list;
          _loadingKosts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _loadingKosts = false;
        });
      }
    }
  }

  Future<void> _initLocationTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      // 1. Get last known position instantly for zero-latency loading
      Position? lastPos;
      try {
        lastPos = await Geolocator.getLastKnownPosition();
      } catch (_) {
        // Fail silently on unsupported platforms (like Web/Windows)
      }
      if (lastPos != null && mounted) {
        setState(() {
          _userLocation = LatLng(lastPos!.latitude, lastPos!.longitude);
        });
      }

      // 2. Start listening to location updates in real-time
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3, // Update when user moves 3 meters
      );
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        if (mounted) {
          setState(() {
            _userLocation = LatLng(position.latitude, position.longitude);
          });
          // Quietly update route if it's active
          if (_selectedKost != null && _routeResult != null) {
            _calculateRouteQuietly(_selectedKost!);
          }
        }
      });

      // 3. Asynchronously request current position in background as upgrade
      Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 4),
        ),
      ).then((pos) {
        if (mounted) {
          setState(() {
            _userLocation = LatLng(pos.latitude, pos.longitude);
          });
          if (_selectedKost != null && _routeResult != null) {
            _calculateRouteQuietly(_selectedKost!);
          }
        }
      }).catchError((_) {});

    } catch (_) {
      // Fail silently
    }
  }

  Future<void> _calculateRouteQuietly(Kost kost) async {
    if (_userLocation == null) return;
    try {
      final start = _userLocation!;
      final end = LatLng(kost.lat, kost.lng);
      final result = await RouteService.fetchRoute(start, end);
      if (mounted) {
        setState(() {
          _routeResult = result;
        });
      }
    } catch (_) {
      // Fail silently
    }
  }

  Future<void> _calculateRoute(Kost kost) async {
    if (_userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi Anda tidak tersedia untuk membuat rute.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _loadingRoute = true;
      _routeResult = null;
    });

    try {
      final start = _userLocation!;
      final end = LatLng(kost.lat, kost.lng);
      final result = await RouteService.fetchRoute(start, end);
      if (mounted) {
        setState(() {
          _routeResult = result;
          _loadingRoute = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingRoute = false;
        });
      }
    }
  }

  double _calculateDistance(double lat, double lng) {
    if (_userLocation == null) return 0.0;
    const r = 6371.0; // km
    final dLat = _toRad(lat - _userLocation!.latitude);
    final dLon = _toRad(lng - _userLocation!.longitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(_userLocation!.latitude)) *
            math.cos(_toRad(lat)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  double _toRad(double deg) => deg * math.pi / 180;

  void _onMarkerTap(Kost kost) {
    setState(() {
      _selectedKost = kost;
      _routeResult = null; // Reset previous route polyline when selecting new pin
    });
    _mapController.move(LatLng(kost.lat, kost.lng), 14.5);
  }

  Color _getMarkerColor(String category) {
    switch (category) {
      case 'Putra':
        return AppColors.categoryPutraText;
      case 'Putri':
        return AppColors.categoryPutriText;
      default:
        return AppColors.categoryCampurText;
    }
  }

  void _zoomIn() =>
      _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
  void _zoomOut() =>
      _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Map widget
          _buildMap(),

          // 2. Translucent top title bar
          _buildTopHeader(),

          // 3. Zoom Controls
          _buildZoomControls(),

          // 4. Loading indicator for route calculation
          if (_loadingRoute) _buildRouteLoadingOverlay(),

          // 5. Selected Kost Card / Info Sheet at the bottom
          _buildSelectedKostCard(),

          // 6. Loading screen for initial Kost fetch
          if (_loadingKosts) _buildKostsLoadingScreen(),

          // 7. Error Screen if failed to fetch
          if (!_loadingKosts && _errorMessage != null) _buildErrorScreen(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    // Generate markers
    final markers = <Marker>[];

    // User location marker (blue circle)
    if (_userLocation != null) {
      markers.add(
        Marker(
          point: _userLocation!,
          width: 28,
          height: 28,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Kost markers
    for (final kost in _kosts) {
      final color = _getMarkerColor(kost.label);
      final isSelected = _selectedKost?.id == kost.id;
      markers.add(
        Marker(
          point: LatLng(kost.lat, kost.lng),
          width: isSelected ? 48 : 40,
          height: isSelected ? 48 : 40,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () => _onMarkerTap(kost),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : color,
                  width: isSelected ? 3.0 : 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: isSelected ? 12 : 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.location_pin,
                color: isSelected ? Colors.white : color,
                size: isSelected ? 26 : 22,
              ),
            ),
          ),
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: _defaultCenter,
        initialZoom: 12.5,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.kostmap',
        ),
        // Draw route polyline if available
        if (_routeResult != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routeResult!.points,
                color: const Color(0xFF0066FF),
                strokeWidth: 5.5,
                borderColor: Colors.white,
                borderStrokeWidth: 1.5,
              ),
            ],
          ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  Widget _buildTopHeader() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.chipBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.map_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Peta Interaktif Kost',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _loadingKosts
                        ? 'Memuat kost...'
                        : '${_kosts.length} kost terdaftar di database',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (_routeResult != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _routeResult = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.red,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Positioned(
      right: 16,
      bottom: _selectedKost != null ? 220 : 32,
      child: Column(
        children: [
          _ZoomButton(icon: Icons.add, onTap: _zoomIn),
          const SizedBox(height: 8),
          _ZoomButton(icon: Icons.remove, onTap: _zoomOut),
        ],
      ),
    );
  }

  Widget _buildRouteLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.25),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Mencari rute tercepat...',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedKostCard() {
    final kost = _selectedKost;
    if (kost == null) return const SizedBox.shrink();

    final distance = _calculateDistance(kost.lat, kost.lng);
    final hasImage = kost.imageUrl != null && kost.imageUrl!.isNotEmpty;

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row for details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: hasImage
                      ? Image.network(
                          kost.imageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),
                const SizedBox(width: 12),
                
                // 2. Info details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CategoryBadge(category: kost.label, fontSize: 10),
                          GestureDetector(
                            onTap: () => setState(() => _selectedKost = null),
                            child: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        kost.title,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        kost.formattedPrice,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _routeResult != null
                                  ? 'Rute: ${_routeResult!.formattedDistance} (${_routeResult!.formattedDuration})'
                                  : _userLocation != null
                                      ? '${distance.toStringAsFixed(1)} km dari Anda'
                                      : kost.displayAddress,
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _calculateRoute(kost),
                    icon: const Icon(Icons.directions_rounded, size: 18),
                    label: Text(
                      _routeResult != null ? 'Rute Ulang' : 'Rute Tercepat',
                      style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.secondary, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(kost: kost),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: Text(
                      'Detail Kost',
                      style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: AppColors.chipBackground,
      child: const Icon(
        Icons.home_outlined,
        color: AppColors.primary,
        size: 32,
      ),
    );
  }

  Widget _buildKostsLoadingScreen() {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.85),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
              const SizedBox(height: 16),
              Text(
                'Memuat lokasi kost dari database...',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Positioned.fill(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat peta',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadKosts,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ZoomButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}
