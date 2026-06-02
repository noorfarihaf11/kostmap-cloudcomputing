import '../models/kost_model.dart';

final List<Kost> dummyKostList = [
  const Kost(
    id: '1',
    name: 'Kost Barokah Jaya',
    address: 'Jl. Jenggolo No. 12, Sidoarjo',
    pricePerMonth: 750000,
    latitude: -7.4478,
    longitude: 112.7183,
    distanceKm: 0.8,
    category: 'Putra',
    facilities: ['WiFi', 'Parkir'],
    description:
        'Kost nyaman di tengah kota Sidoarjo, cocok untuk mahasiswa dan karyawan. '
        'Lingkungan aman dan bersih dengan penjaga kost 24 jam. '
        'Dekat dengan pusat perbelanjaan, stasiun, dan fasilitas umum lainnya.',
  ),
  const Kost(
    id: '2',
    name: 'Kost Melati Putri',
    address: 'Jl. Pahlawan No. 45, Sidoarjo',
    pricePerMonth: 900000,
    latitude: -7.4512,
    longitude: 112.7201,
    distanceKm: 1.2,
    category: 'Putri',
    facilities: ['WiFi', 'AC', 'Kamar Mandi Dalam'],
    description:
        'Kost khusus putri dengan fasilitas lengkap dan suasana yang nyaman. '
        'Lokasi strategis dekat pusat perbelanjaan Delta Plaza dan terminal bus. '
        'Kamar bersih, aman, dan dikelola dengan baik oleh ibu kost yang ramah.',
  ),
  const Kost(
    id: '3',
    name: 'Kost Harmoni',
    address: 'Jl. Majapahit No. 8, Sidoarjo',
    pricePerMonth: 650000,
    latitude: -7.4445,
    longitude: 112.7165,
    distanceKm: 1.8,
    category: 'Campur',
    facilities: ['WiFi', 'Parkir'],
    description:
        'Kost campur dengan harga terjangkau dan suasana kekeluargaan yang hangat. '
        'Cocok untuk karyawan yang mencari tempat tinggal sementara di Sidoarjo. '
        'Fasilitas umum tersedia di area kost, lingkungan bersih dan tenang.',
  ),
  const Kost(
    id: '4',
    name: 'Kost Sejahtera',
    address: 'Jl. Ahmad Yani No. 33, Sidoarjo',
    pricePerMonth: 800000,
    latitude: -7.4590,
    longitude: 112.7220,
    distanceKm: 2.3,
    category: 'Putra',
    facilities: ['WiFi', 'AC', 'Parkir'],
    description:
        'Kost putra modern dengan fasilitas AC dan parkir luas. '
        'Dekat dengan kawasan industri dan perkantoran Sidoarjo, '
        'sangat cocok untuk karyawan pabrik dan pegawai kantoran.',
  ),
  const Kost(
    id: '5',
    name: 'Kost Damai Indah',
    address: 'Jl. Diponegoro No. 21, Sidoarjo',
    pricePerMonth: 1100000,
    latitude: -7.4420,
    longitude: 112.7140,
    distanceKm: 3.1,
    category: 'Campur',
    facilities: ['WiFi', 'AC', 'Kamar Mandi Dalam', 'Parkir'],
    description:
        'Kost premium dengan fasilitas lengkap dan keamanan terjamin. '
        'Kamar luas dilengkapi AC, kamar mandi dalam, dan akses parkir 24 jam. '
        'Lingkungan asri dan tenang, ideal untuk pasangan atau profesional muda.',
  ),
];
