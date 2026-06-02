class Kost {
  final String id;
  final String name;
  final String address;
  final double pricePerMonth;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final String category; // Putra | Putri | Campur
  final List<String> facilities;
  final String description;

  const Kost({
    required this.id,
    required this.name,
    required this.address,
    required this.pricePerMonth,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.category,
    required this.facilities,
    required this.description,
  });

  String get formattedPrice {
    final price = pricePerMonth.toInt();
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    );
    return 'Rp $formatted / bulan';
  }

  String get formattedDistance => '${distanceKm.toStringAsFixed(1)} km';
}
