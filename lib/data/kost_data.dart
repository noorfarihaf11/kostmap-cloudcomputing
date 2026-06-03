import '../models/kost_model.dart';

// Local fallback data (not used in production — app fetches from API)
final List<Kost> dummyKostList = [
  const Kost(
    id: '1',
    title: 'Kost Barokah Jaya',
    label: 'Putra',
    city: 'Sidoarjo',
    lat: -7.4478,
    lng: 112.7183,
    distanceKm: 0.8,
    address: 'Jl. Jenggolo No. 12, Sidoarjo',
    pricePerMonth: 750000,
    description: 'WiFi, Parkir',
  ),
  const Kost(
    id: '2',
    title: 'Kost Melati Putri',
    label: 'Putri',
    city: 'Sidoarjo',
    lat: -7.4512,
    lng: 112.7201,
    distanceKm: 1.2,
    address: 'Jl. Pahlawan No. 45, Sidoarjo',
    pricePerMonth: 900000,
    description: 'WiFi, AC, Kamar Mandi Dalam',
  ),
  const Kost(
    id: '3',
    title: 'Kost Harmoni',
    label: 'Campur',
    city: 'Sidoarjo',
    lat: -7.4445,
    lng: 112.7165,
    distanceKm: 1.8,
    address: 'Jl. Majapahit No. 8, Sidoarjo',
    pricePerMonth: 650000,
    description: 'WiFi, Parkir',
  ),
];
