import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/services/location_service.dart';

/// Controller untuk Network Provider Location Tracker
/// Menggunakan network provider saja (tanpa GPS)
class NetworkLocationController extends GetxController {
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
    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('🌐 [NETWORK CONTROLLER] _initializeLocation() called');
      print('🌐 [NETWORK CONTROLLER] Will fetch FRESH position (no cache)');
      print('═══════════════════════════════════════════════════════════');
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Network provider tidak perlu cek GPS service
      _permissionStatus.value = await _locationService.checkPermission();

      if (_permissionStatus.value == LocationPermission.denied ||
          _permissionStatus.value == LocationPermission.deniedForever) {
        await requestPermission();
      }

      // Langsung ambil posisi baru (tidak pakai cache)
      // Ini memastikan data selalu fresh dan sesuai dengan NETWORK source
      if (kDebugMode) {
        print('🌐 [NETWORK CONTROLLER] Fetching fresh position (no cache)...');
      }
      await getCurrentPosition();

      _isLoading.value = false;
    } catch (e, stackTrace) {
      // Gunakan error message asli dari sistem
      _errorMessage.value = e.toString();
      _isLoading.value = false;
      if (kDebugMode) {
        print(
          '❌ [NETWORK CONTROLLER] Location initialization error: ${e.toString()}',
        );
        print('❌ [NETWORK CONTROLLER] Stack trace: $stackTrace');
      }
    }
  }

  Future<void> requestPermission() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      bool granted = await _locationService.requestPermission(
        requireGps: false, // Network provider tidak perlu GPS
      );
      _permissionStatus.value = await _locationService.checkPermission();

      if (!granted) {
        // Throw exception dengan message dari permission status
        final status = await _locationService.checkPermission();
        if (status == LocationPermission.deniedForever) {
          throw PermissionDeniedException(
            'Location permission permanently denied',
          );
        } else {
          throw PermissionDeniedException('Location permission denied');
        }
      } else {
        _errorMessage.value = '';
        await getCurrentPosition();
      }

      _isLoading.value = false;
    } catch (e, stackTrace) {
      // Gunakan error message asli dari sistem
      _errorMessage.value = e.toString();
      _isLoading.value = false;
      if (kDebugMode) {
        print(
          '❌ [NETWORK CONTROLLER] Request permission error: ${e.toString()}',
        );
        print('❌ [NETWORK CONTROLLER] Stack trace: $stackTrace');
      }
    }
  }

  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }

  Future<void> getCurrentPosition() async {
    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('🌐 [NETWORK CONTROLLER] getCurrentPosition() called');
      print('🌐 [NETWORK CONTROLLER] useGps parameter: false (NETWORK ONLY)');
      print('═══════════════════════════════════════════════════════════');
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Cek permission dulu
      bool hasPermission = await _locationService.isPermissionGranted();
      if (!hasPermission) {
        if (kDebugMode) {
          print('❌ [NETWORK CONTROLLER] Permission not granted');
        }
        // Akan di-handle oleh requestPermission yang akan throw exception
      }

      if (kDebugMode) {
        print(
          '🌐 [NETWORK CONTROLLER] Calling LocationService.getCurrentPosition(useGps: false)',
        );
      }

      Position? position = await _locationService.getCurrentPosition(
        useGps: false, // Selalu network provider - HARUS FALSE
      );

      if (kDebugMode) {
        if (position != null) {
          print('✅ [NETWORK CONTROLLER] Position received');
          print('🌐 [NETWORK CONTROLLER] Accuracy: ${position.accuracy}m');
          print(
            '🌐 [NETWORK CONTROLLER] Lat: ${position.latitude}, Lng: ${position.longitude}',
          );
          if (position.accuracy < 50) {
            print(
              '⚠️ [NETWORK CONTROLLER] WARNING: Low accuracy (<50m) suggests GPS was used!',
            );
            print(
              '⚠️ [NETWORK CONTROLLER] This should not happen for NETWORK provider!',
            );
          } else {
            print(
              '✅ [NETWORK CONTROLLER] High accuracy (>50m) confirms NETWORK source',
            );
          }
        } else {
          print('❌ [NETWORK CONTROLLER] No position received');
        }
        print('═══════════════════════════════════════════════════════════');
      }

      if (position != null) {
        _currentPosition.value = position;
        _updateMapPosition(position);
        _errorMessage.value = '';
      } else {
        // Jika null, berarti ada error yang tidak di-throw
        // Throw exception agar error message bisa ditangkap
        throw Exception('Failed to get current position: Position is null');
      }

      _isLoading.value = false;
    } on PermissionDeniedException catch (e) {
      // Gunakan error message asli dari sistem
      _errorMessage.value = e.toString();
      _isLoading.value = false;
      if (kDebugMode) {
        print(
          '❌ [NETWORK CONTROLLER] PermissionDeniedException: ${e.toString()}',
        );
      }
    } on LocationServiceDisabledException catch (e) {
      // Gunakan error message asli dari sistem
      _errorMessage.value = e.toString();
      _isLoading.value = false;
      if (kDebugMode) {
        print(
          '❌ [NETWORK CONTROLLER] LocationServiceDisabledException: ${e.toString()}',
        );
      }
    } on TimeoutException catch (e) {
      // Gunakan error message asli dari sistem
      _errorMessage.value = e.toString();
      _isLoading.value = false;
      if (kDebugMode) {
        print('❌ [NETWORK CONTROLLER] TimeoutException: ${e.toString()}');
      }
    } catch (e, stackTrace) {
      // Gunakan error message asli dari sistem
      _errorMessage.value = e.toString();
      _isLoading.value = false;
      if (kDebugMode) {
        print('❌ [NETWORK CONTROLLER] Error: ${e.toString()}');
        print('❌ [NETWORK CONTROLLER] Stack trace: $stackTrace');
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
    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('🌐 [NETWORK CONTROLLER] startTracking() called');
      print('🌐 [NETWORK CONTROLLER] useGps parameter: false (NETWORK ONLY)');
      print('═══════════════════════════════════════════════════════════');
    }

    try {
      // Cek permission dulu
      bool hasPermission = await _locationService.isPermissionGranted();
      if (!hasPermission) {
        // Request permission jika belum granted
        if (kDebugMode) {
          print(
            '🌐 [NETWORK CONTROLLER] Requesting permission (requireGps: false)',
          );
        }
        hasPermission = await _locationService.requestPermission(
          requireGps: false, // Network provider tidak perlu GPS - HARUS FALSE
        );
      }

      if (!hasPermission) {
        // Throw exception dengan message dari permission status
        final status = await _locationService.checkPermission();
        if (status == LocationPermission.deniedForever) {
          throw PermissionDeniedException(
            'Location permission permanently denied',
          );
        } else {
          throw PermissionDeniedException('Location permission denied');
        }
      }

      _isTracking.value = true;
      _errorMessage.value = '';

      if (kDebugMode) {
        print(
          '🌐 [NETWORK CONTROLLER] Starting position stream (useGps: false)',
        );
      }

      Stream<Position>? positionStream = _locationService.getPositionStream(
        useGps: false, // Selalu network provider - HARUS FALSE
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
            // Gunakan error message asli dari sistem
            _errorMessage.value = error.toString();
            if (kDebugMode) {
              print(
                '❌ [NETWORK CONTROLLER] Position stream error: ${error.toString()}',
              );
            }
          },
        );
      } else {
        throw Exception(
          'Failed to start position stream: Position stream is null',
        );
      }
    } on PermissionDeniedException catch (e) {
      // Gunakan error message asli dari sistem
      _errorMessage.value = e.toString();
      _isTracking.value = false;
      if (kDebugMode) {
        print(
          '❌ [NETWORK CONTROLLER] PermissionDeniedException: ${e.toString()}',
        );
      }
    } on LocationServiceDisabledException catch (e) {
      // Gunakan error message asli dari sistem
      _errorMessage.value = e.toString();
      _isTracking.value = false;
      if (kDebugMode) {
        print(
          '❌ [NETWORK CONTROLLER] LocationServiceDisabledException: ${e.toString()}',
        );
      }
    } on TimeoutException catch (e) {
      // Gunakan error message asli dari sistem
      _errorMessage.value = e.toString();
      _isTracking.value = false;
      if (kDebugMode) {
        print('❌ [NETWORK CONTROLLER] TimeoutException: ${e.toString()}');
      }
    } catch (e, stackTrace) {
      // Gunakan error message asli dari sistem
      _errorMessage.value = e.toString();
      _isTracking.value = false;
      if (kDebugMode) {
        print('❌ [NETWORK CONTROLLER] Start tracking error: ${e.toString()}');
        print('❌ [NETWORK CONTROLLER] Stack trace: $stackTrace');
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

  /// Get error action button info berdasarkan konteks error
  Map<String, dynamic> getErrorAction() {
    final error = _errorMessage.value.toLowerCase();
    
    // Permission permanently denied - buka app settings
    if (error.contains('permanently denied') || 
        error.contains('deniedforever')) {
      return {
        'label': 'Buka Pengaturan',
        'icon': Icons.settings,
        'action': openAppSettings,
      };
    }
    
    // Permission denied - request permission
    if (error.contains('permission denied') || 
        error.contains('permission')) {
      return {
        'label': 'Berikan Izin Lokasi',
        'icon': Icons.location_on,
        'action': requestPermission,
      };
    }
    
    // Network unavailable atau timeout
    if (error.contains('timeout') || 
        error.contains('network') ||
        error.contains('unavailable')) {
      return {
        'label': 'Coba Lagi',
        'icon': Icons.refresh,
        'action': getCurrentPosition,
      };
    }
    
    // General error - retry
    return {
      'label': 'Coba Lagi',
      'icon': Icons.refresh,
      'action': getCurrentPosition,
    };
  }
}
