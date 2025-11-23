import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

/// Service untuk mengelola lokasi GPS
/// Menggunakan Geolocator dengan best practices
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
  /// Menggunakan permission_handler untuk handling yang lebih baik
  Future<bool> requestPermission() async {
    // Cek apakah service enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
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
  /// Menggunakan LocationAccuracy.high untuk akurasi terbaik
  Future<Position?> getCurrentPosition() async {
    try {
      // Cek permission dulu
      bool hasPermission = await requestPermission();
      if (!hasPermission) {
        return null;
      }

      // Dapatkan posisi dengan akurasi tinggi
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
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
  /// LocationSettings untuk konfigurasi akurasi dan interval
  Stream<Position>? getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meter
    Duration? timeLimit,
  }) {
    try {
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
