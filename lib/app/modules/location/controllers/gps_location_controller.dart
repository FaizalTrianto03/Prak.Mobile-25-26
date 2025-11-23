import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/services/location_service.dart';

/// Controller untuk GPS Location Tracker
/// Menggunakan GPS dengan akurasi tinggi
class GpsLocationController extends GetxController {
  final LocationService _locationService = LocationService();

  // Observables
  final Rx<Position?> _currentPosition = Rx<Position?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _isTracking = false.obs;
  final Rx<LocationPermission> _permissionStatus =
      LocationPermission.denied.obs;

  // FlutterMap Controller
  MapController? _mapController;
  bool _isDisposed = false;

  // Map center position dan zoom
  final Rx<LatLng> _mapCenter = Rx<LatLng>(
    const LatLng(-6.2088, 106.8456), // Jakarta default
  );
  final RxDouble _mapZoom = 15.0.obs;

  // Stream subscription
  StreamSubscription<Position>? _positionSubscription;

  // Getters
  Position? get currentPosition => _currentPosition.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get isTracking => _isTracking.value;
  LocationPermission get permissionStatus => _permissionStatus.value;
  MapController get mapController {
    if (_mapController == null || _isDisposed) {
      try {
        _mapController?.dispose();
      } catch (e) {
        // Ignore error saat dispose
      }
      _mapController = MapController();
      _isDisposed = false;
    }
    return _mapController!;
  }

  bool get isMapControllerReady => _mapController != null && !_isDisposed;
  LatLng get mapCenter => _mapCenter.value;
  double get mapZoom => _mapZoom.value;

  // Computed values
  double? get latitude => _currentPosition.value?.latitude;
  double? get longitude => _currentPosition.value?.longitude;
  double? get accuracy => _currentPosition.value?.accuracy;
  double? get altitude => _currentPosition.value?.altitude;
  double? get speed => _currentPosition.value?.speed;
  DateTime? get timestamp => _currentPosition.value?.timestamp;

  @override
  void onInit() {
    super.onInit();
    _isDisposed = false;
    try {
      _mapController?.dispose();
    } catch (e) {
      // Ignore error
    }
    _mapController = MapController();
    _initializeLocation();
  }

  @override
  void onClose() {
    _isDisposed = true;
    _stopTracking();
    _positionSubscription?.cancel();
    _positionSubscription = null;

    try {
      _mapController?.dispose();
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing map controller: $e');
      }
    } finally {
      _mapController = null;
    }

    super.onClose();
  }

  bool _canUseMapController() {
    return !_isDisposed && _mapController != null;
  }

  Future<void> _initializeLocation() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // GPS memerlukan GPS service aktif
      bool isEnabled = await _locationService.isLocationServiceEnabled();
      if (!isEnabled) {
        _errorMessage.value = 'GPS tidak aktif. Silakan aktifkan GPS.';
        _isLoading.value = false;
        return;
      }

      _permissionStatus.value = await _locationService.checkPermission();

      if (_permissionStatus.value == LocationPermission.denied ||
          _permissionStatus.value == LocationPermission.deniedForever) {
        await requestPermission();
      }

      await getLastKnownPosition();

      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = 'Error: ${e.toString()}';
      _isLoading.value = false;
      if (kDebugMode) {
        print('Location initialization error: $e');
      }
    }
  }

  Future<void> requestPermission() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      bool granted = await _locationService.requestPermission(
        requireGps: true, // GPS memerlukan GPS service
      );
      _permissionStatus.value = await _locationService.checkPermission();

      if (!granted) {
        _errorMessage.value =
            'Permission lokasi ditolak. Silakan aktifkan di Settings.';
      } else {
        await getCurrentPosition();
      }

      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = 'Error: ${e.toString()}';
      _isLoading.value = false;
    }
  }

  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }

  Future<void> getCurrentPosition() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      Position? position = await _locationService.getCurrentPosition(
        useGps: true, // Selalu GPS
      );

      if (position != null) {
        _currentPosition.value = position;
        _updateMapPosition(position);
        _errorMessage.value = '';
      } else {
        _errorMessage.value = 'Tidak dapat mendapatkan posisi saat ini.';
      }

      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = 'Error: ${e.toString()}';
      _isLoading.value = false;
      if (kDebugMode) {
        print('Get current position error: $e');
      }
    }
  }

  Future<void> getLastKnownPosition() async {
    try {
      Position? position = await _locationService.getLastKnownPosition();

      if (position != null) {
        _currentPosition.value = position;
        _updateMapPosition(position);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Get last known position error: $e');
      }
    }
  }

  Future<void> startTracking() async {
    try {
      bool hasPermission = await _locationService.requestPermission(
        requireGps: true, // GPS memerlukan GPS service
      );
      if (!hasPermission) {
        _errorMessage.value = 'Permission lokasi diperlukan untuk tracking.';
        return;
      }

      _isTracking.value = true;
      _errorMessage.value = '';

      Stream<Position>? positionStream = _locationService.getPositionStream(
        useGps: true, // Selalu GPS
        distanceFilter: 10,
      );

      if (positionStream != null) {
        _positionSubscription?.cancel();
        _positionSubscription = positionStream.listen(
          (Position position) {
            _currentPosition.value = position;
            _updateMapPosition(position);
          },
          onError: (error) {
            _errorMessage.value = 'Error tracking: ${error.toString()}';
            if (kDebugMode) {
              print('Position stream error: $error');
            }
          },
        );
      } else {
        _errorMessage.value = 'Tidak dapat memulai tracking.';
        _isTracking.value = false;
      }
    } catch (e) {
      _errorMessage.value = 'Error: ${e.toString()}';
      _isTracking.value = false;
      if (kDebugMode) {
        print('Start tracking error: $e');
      }
    }
  }

  void _stopTracking() {
    _isTracking.value = false;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _locationService.stopPositionStream();
  }

  void stopTracking() {
    _stopTracking();
  }

  void _updateMapPosition(Position position) {
    if (_isDisposed || !_canUseMapController()) return;

    final newCenter = LatLng(position.latitude, position.longitude);
    _mapCenter.value = newCenter;

    try {
      _mapController?.move(newCenter, _mapZoom.value);
    } catch (e) {
      if (kDebugMode) {
        print('Map controller not ready yet: $e');
      }
    }
  }

  void updateMapCenter(LatLng center, double zoom) {
    if (_isDisposed) return;
    _mapCenter.value = center;
    _mapZoom.value = zoom;
  }

  void setZoom(double zoom) {
    if (_isDisposed || !_canUseMapController()) return;

    _mapZoom.value = zoom;
    if (_currentPosition.value != null) {
      try {
        _mapController?.move(
          LatLng(
            _currentPosition.value!.latitude,
            _currentPosition.value!.longitude,
          ),
          zoom,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Map controller not ready for zoom: $e');
        }
      }
    }
  }

  void zoomIn() {
    final newZoom = (_mapZoom.value + 1).clamp(3.0, 18.0);
    setZoom(newZoom);
  }

  void zoomOut() {
    final newZoom = (_mapZoom.value - 1).clamp(3.0, 18.0);
    setZoom(newZoom);
  }

  void moveToCurrentPosition() {
    if (_isDisposed || !_canUseMapController()) return;

    if (_currentPosition.value != null) {
      try {
        final position = _currentPosition.value!;
        final center = LatLng(position.latitude, position.longitude);
        _mapController?.move(center, _mapZoom.value);
        _mapCenter.value = center;
      } catch (e) {
        if (kDebugMode) {
          print('Map controller not ready for move: $e');
        }
      }
    }
  }

  Future<void> refreshPosition() async {
    await getCurrentPosition();
  }

  void resetMapController() {
    try {
      _mapController?.dispose();
    } catch (e) {
      // Ignore error
    }
    _mapController = MapController();
    _isDisposed = false;
  }

  Future<void> toggleTracking() async {
    if (_isTracking.value) {
      stopTracking();
    } else {
      await startTracking();
    }
  }
}
