import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

/// Service untuk mengelola lokasi (GPS dan Network Provider)
/// Menggunakan Geolocator dengan best practices
/// Default menggunakan Network Provider saja (tanpa GPS)
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Stream untuk mendapatkan posisi real-time
  Stream<Position>? _positionStream;

  /// Status permission saat ini
  LocationPermission? _permissionStatus;

  /// Cek apakah GPS service enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request permission untuk akses lokasi
  /// [requireGps]: true jika memerlukan GPS aktif, false untuk network provider saja
  /// Menggunakan permission_handler untuk handling yang lebih baik
  Future<bool> requestPermission({bool requireGps = false}) async {
    // Jika memerlukan GPS, cek apakah service enabled
    // Jika hanya network provider, tidak perlu cek GPS service
    if (requireGps) {
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }
    }

    // Cek permission status
    _permissionStatus = await Geolocator.checkPermission();

    if (_permissionStatus == LocationPermission.denied) {
      // Request permission
      _permissionStatus = await Geolocator.requestPermission();
      if (_permissionStatus == LocationPermission.denied) {
        return false;
      }
    }

    if (_permissionStatus == LocationPermission.deniedForever) {
      // Permission permanently denied, perlu buka settings
      return false;
    }

    // Permission granted
    return true;
  }

  /// Cek permission status
  Future<LocationPermission> checkPermission() async {
    _permissionStatus = await Geolocator.checkPermission();
    return _permissionStatus ?? LocationPermission.denied;
  }

  /// Buka settings untuk enable permission
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Buka app settings
  Future<void> openAppSettings() async {
    await permission_handler.openAppSettings();
  }

  /// Dapatkan posisi saat ini (one-time)
  /// [useGps]: true untuk GPS (high accuracy), false untuk network provider saja (low accuracy)
  /// Default: false (network provider saja)
  Future<Position?> getCurrentPosition({bool useGps = false}) async {
    try {
      // Cek permission dulu (hanya require GPS jika useGps = true)
      bool hasPermission = await requestPermission(requireGps: useGps);
      if (!hasPermission) {
        return null;
      }

      // Pilih akurasi berdasarkan GPS toggle
      // LocationAccuracy.low = network provider saja (tanpa GPS)
      // LocationAccuracy.high = GPS dengan akurasi tinggi
      final accuracy = useGps ? LocationAccuracy.high : LocationAccuracy.low;

      // Dapatkan posisi dengan akurasi sesuai setting
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: const Duration(seconds: 10),
        ),
      );

      return position;
    } catch (e) {
      return null;
    }
  }

  /// Dapatkan posisi terakhir yang diketahui
  Future<Position?> getLastKnownPosition() async {
    try {
      bool hasPermission = await requestPermission();
      if (!hasPermission) {
        return null;
      }

      Position? position = await Geolocator.getLastKnownPosition();
      return position;
    } catch (e) {
      return null;
    }
  }

  /// Mulai listening posisi real-time
  /// [useGps]: true untuk GPS (high accuracy), false untuk network provider saja (low accuracy)
  /// Default: false (network provider saja)
  Stream<Position>? getPositionStream({
    bool useGps = false,
    int distanceFilter = 10, // meter
    Duration? timeLimit,
  }) {
    try {
      // Pilih akurasi berdasarkan GPS toggle
      final accuracy = useGps ? LocationAccuracy.high : LocationAccuracy.low;

      _positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          distanceFilter: distanceFilter,
          timeLimit: timeLimit,
        ),
      );
      return _positionStream;
    } catch (e) {
      return null;
    }
  }

  /// Stop listening posisi
  void stopPositionStream() {
    _positionStream = null;
  }

  /// Hitung jarak antara dua koordinat (dalam meter)
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Hitung bearing antara dua koordinat
  double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}
