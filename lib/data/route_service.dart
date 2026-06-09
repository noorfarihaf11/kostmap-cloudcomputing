import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  final bool isRoadRoute;

  RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    this.isRoadRoute = true,
  });

  String get formattedDistance {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${distanceMeters.round()} m';
  }

  String get formattedDuration {
    final minutes = (durationSeconds / 60).round();
    if (minutes < 1) return 'Kurang dari 1 mnt';
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMins = minutes % 60;
      return '$hours jam $remainingMins mnt';
    }
    return '$minutes mnt';
  }
}

class RouteService {
  static Future<RouteResult> fetchRoute(LatLng start, LatLng end) async {
    final url = 'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'com.example.kostmap',
      }).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'Ok' &&
            data['routes'] != null &&
            (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];
          final coordinates = geometry['coordinates'] as List;

          final points = coordinates.map((coord) {
            final list = coord as List;
            return LatLng(
              (list[1] as num).toDouble(),
              (list[0] as num).toDouble(),
            );
          }).toList();

          final distanceMeters = (route['distance'] as num).toDouble();
          final durationSeconds = (route['duration'] as num).toDouble();

          return RouteResult(
            points: points,
            distanceMeters: distanceMeters,
            durationSeconds: durationSeconds,
            isRoadRoute: true,
          );
        }
      }
    } catch (_) {
      // Fail silently and use fallback
    }

    // Fallback: straight line route
    final distance = _haversineDistance(start, end);
    // Rough estimate: average driving speed of 30 km/h (8.33 m/s)
    final duration = distance / 8.33;

    return RouteResult(
      points: [start, end],
      distanceMeters: distance,
      durationSeconds: duration,
      isRoadRoute: false,
    );
  }

  static double _haversineDistance(LatLng p1, LatLng p2) {
    const r = 6371000.0; // earth radius in meters
    final dLat = _toRad(p2.latitude - p1.latitude);
    final dLon = _toRad(p2.longitude - p1.longitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(p1.latitude)) *
            math.cos(_toRad(p2.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _toRad(double deg) => deg * math.pi / 180;
}
