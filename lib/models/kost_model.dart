class Kost {
  final dynamic id;
  final String title;
  final String label;
  final String city;
  final double lat;
  final double lng;
  final String? address;
  final String? neighborhood;
  final String? street;
  final String? state;
  final String? phone;
  final String? website;
  final String? mapUrl;
  final String? imageUrl;
  final double? pricePerMonth;
  final String? description;
  final double? distanceKm;

  const Kost({
    required this.id,
    required this.title,
    required this.label,
    required this.city,
    required this.lat,
    required this.lng,
    this.address,
    this.neighborhood,
    this.street,
    this.state,
    this.phone,
    this.website,
    this.mapUrl,
    this.imageUrl,
    this.pricePerMonth,
    this.description,
    this.distanceKm,
  });

  factory Kost.fromJson(Map<String, dynamic> json) {
    double? price;
    if (json['price'] != null) {
      price = double.tryParse(json['price'].toString());
    } else if (json['price_per_month'] != null) {
      price = (json['price_per_month'] as num).toDouble();
    }

    return Kost(
      id: json['id'],
      title: json['title'] ?? '',
      label: json['label'] ?? 'Campur',
      city: json['city'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: json['address'],
      neighborhood: json['neighborhood'],
      street: json['street'],
      state: json['state'],
      phone: json['phone'],
      website: json['website'],
      mapUrl: json['url'],
      imageUrl: json['image_url'],
      pricePerMonth: price,
      description: json['description'],
      distanceKm: json['distance_km'] != null
          ? (json['distance_km'] as num).toDouble()
          : null,
    );
  }

  String get idString => id.toString();

  // backward-compat getters
  String get name => title;
  String get category => label;
  double get latitude => lat;
  double get longitude => lng;
  String get displayAddress => address ?? city;

  String get formattedDistance {
    if (distanceKm == null) return '-';
    return '${distanceKm!.toStringAsFixed(1)} km';
  }

  String get formattedPrice {
    if (pricePerMonth == null) return 'Hubungi pemilik';
    final price = pricePerMonth!.toInt();
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    );
    return 'Rp $formatted / bulan';
  }
}
