import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/services/location_service.dart';

/// Controller untuk Live Location Tracker
/// Menggunakan GetX untuk state management
/// Menggunakan OpenStreetMap dengan flutter_map
class LocationController extends GetxController {
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
    // Jika null atau disposed, buat baru
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
  
  /// Check if map controller is ready and not disposed
  bool get isMapControllerReady => 
      _mapController != null && !_isDisposed;
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
    // Reset state dan initialize map controller
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
    
    // Dispose map controller dengan error handling
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
  
  /// Safe method to check and use map controller
  bool _canUseMapController() {
    return !_isDisposed && _mapController != null;
  }

  /// Initialize location service
  Future<void> _initializeLocation() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Cek apakah GPS enabled
      bool isEnabled = await _locationService.isLocationServiceEnabled();
      if (!isEnabled) {
        _errorMessage.value = 'GPS tidak aktif. Silakan aktifkan GPS.';
        _isLoading.value = false;
        return;
      }

      // Cek permission
      _permissionStatus.value = await _locationService.checkPermission();

      // Jika permission belum granted, request
      if (_permissionStatus.value == LocationPermission.denied ||
          _permissionStatus.value == LocationPermission.deniedForever) {
        await requestPermission();
      }

      // Dapatkan posisi terakhir yang diketahui
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

  /// Request permission untuk akses lokasi
  Future<void> requestPermission() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      bool granted = await _locationService.requestPermission();
      _permissionStatus.value = await _locationService.checkPermission();

      if (!granted) {
        _errorMessage.value =
            'Permission lokasi ditolak. Silakan aktifkan di Settings.';
      } else {
        // Jika permission granted, dapatkan posisi saat ini
        await getCurrentPosition();
      }

      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = 'Error: ${e.toString()}';
      _isLoading.value = false;
    }
  }

  /// Buka location settings
  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  /// Buka app settings
  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }

  /// Dapatkan posisi saat ini (one-time)
  Future<void> getCurrentPosition() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      Position? position = await _locationService.getCurrentPosition();

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

  /// Dapatkan posisi terakhir yang diketahui
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

  /// Mulai tracking posisi real-time
  Future<void> startTracking() async {
    try {
      // Cek permission dulu
      bool hasPermission = await _locationService.requestPermission();
      if (!hasPermission) {
        _errorMessage.value = 'Permission lokasi diperlukan untuk tracking.';
        return;
      }

      _isTracking.value = true;
      _errorMessage.value = '';

      // Dapatkan stream posisi
      Stream<Position>? positionStream = _locationService.getPositionStream(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update setiap 10 meter
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

  /// Stop tracking posisi
  void _stopTracking() {
    _isTracking.value = false;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _locationService.stopPositionStream();
  }

  /// Stop tracking (public method)
  void stopTracking() {
    _stopTracking();
  }

  /// Update map position (center dan zoom)
  void _updateMapPosition(Position position) {
    if (_isDisposed || !_canUseMapController()) return;
    
    final newCenter = LatLng(position.latitude, position.longitude);
    _mapCenter.value = newCenter;

    // Animate map ke posisi baru (hanya jika map sudah ready)
    try {
      _mapController?.move(newCenter, _mapZoom.value);
    } catch (e) {
      // Map belum ready atau sudah disposed, skip update
      if (kDebugMode) {
        print('Map controller not ready yet: $e');
      }
    }
  }

  /// Update map center (untuk onMapMove callback)
  void updateMapCenter(LatLng center, double zoom) {
    if (_isDisposed) return;
    _mapCenter.value = center;
    _mapZoom.value = zoom;
  }

  /// Set zoom level
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

  /// Zoom in
  void zoomIn() {
    final newZoom = (_mapZoom.value + 1).clamp(3.0, 18.0);
    setZoom(newZoom);
  }

  /// Zoom out
  void zoomOut() {
    final newZoom = (_mapZoom.value - 1).clamp(3.0, 18.0);
    setZoom(newZoom);
  }

  /// Move map ke current position
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

  /// Refresh posisi
  Future<void> refreshPosition() async {
    await getCurrentPosition();
  }
  
  /// Reset map controller (untuk retry setelah error)
  void resetMapController() {
    try {
      _mapController?.dispose();
    } catch (e) {
      // Ignore error
    }
    _mapController = MapController();
    _isDisposed = false;
  }

  /// Toggle tracking
  Future<void> toggleTracking() async {
    if (_isTracking.value) {
      stopTracking();
    } else {
      await startTracking();
    }
  }
}
