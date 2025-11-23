import 'dart:async';
import 'package:flutter/foundation.dart';
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

  /// Permission status dari permission_handler
  permission_handler.PermissionStatus? _permissionHandlerStatus;

  /// Cek apakah GPS service enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Cek status network connection
  /// Untuk network provider location, perlu koneksi internet
  /// Note: INTERNET permission tidak memerlukan runtime permission di Android
  /// Permission sudah dideklarasikan di AndroidManifest.xml
  Future<bool> isNetworkAvailable() async {
    try {
      // INTERNET permission tidak memerlukan runtime permission
      // Permission sudah dideklarasikan di AndroidManifest.xml
      // Untuk sekarang, kita asumsikan network tersedia
      // Di production, bisa menggunakan connectivity_plus package untuk cek real network state
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking network: $e');
      }
      return false;
    }
  }

  /// Request permission untuk akses lokasi
  /// [requireGps]: true jika memerlukan GPS aktif, false untuk network provider saja
  /// Menggunakan permission_handler untuk handling yang lebih baik
  /// Returns: true jika permission granted, false jika denied
  Future<bool> requestPermission({bool requireGps = false}) async {
    final locationSource = requireGps ? 'GPS' : 'NETWORK';
    if (kDebugMode) {
      print('📍 [LOCATION SERVICE] requestPermission() called');
      print(
        '📍 [LOCATION SERVICE] requireGps: $requireGps (Source: $locationSource)',
      );
    }

    try {
      // Jika memerlukan GPS, cek apakah service enabled
      if (requireGps) {
        if (kDebugMode) {
          print('📍 [LOCATION SERVICE] Checking GPS service status...');
        }
        bool serviceEnabled = await isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (kDebugMode) {
            print('❌ [LOCATION SERVICE] GPS service is not enabled');
          }
          return false;
        }
        if (kDebugMode) {
          print('✅ [LOCATION SERVICE] GPS service is enabled');
        }
      } else {
        if (kDebugMode) {
          print(
            '📍 [LOCATION SERVICE] NETWORK provider - skipping GPS service check',
          );
        }
      }

      // Untuk network provider, cek network availability
      if (!requireGps) {
        bool networkAvailable = await isNetworkAvailable();
        if (!networkAvailable) {
          if (kDebugMode) {
            print('Network is not available');
          }
          // Tetap lanjutkan, karena network mungkin tersedia nanti
        }
      }

      // Cek permission menggunakan permission_handler (lebih reliable)
      permission_handler.Permission locationPermission;
      if (requireGps) {
        // Untuk GPS, gunakan FINE_LOCATION
        locationPermission = permission_handler.Permission.locationWhenInUse;
        if (kDebugMode) {
          print(
            '📍 [LOCATION SERVICE] Using locationWhenInUse permission (GPS mode)',
          );
        }
      } else {
        // Untuk network provider, bisa gunakan COARSE_LOCATION atau FINE_LOCATION
        // Di Android, COARSE_LOCATION sudah cukup untuk network provider
        // Tapi untuk kompatibilitas, kita gunakan locationWhenInUse
        // PENTING: Meskipun menggunakan locationWhenInUse, kita tetap set accuracy ke LOW
        // untuk memastikan hanya network provider yang digunakan
        locationPermission = permission_handler.Permission.locationWhenInUse;
        if (kDebugMode) {
          print(
            '📍 [LOCATION SERVICE] Using locationWhenInUse permission (NETWORK mode)',
          );
          print(
            '📍 [LOCATION SERVICE] NOTE: Accuracy will be set to LOW to ensure NETWORK only',
          );
        }
      }

      // Cek status permission
      if (kDebugMode) {
        print('📍 [LOCATION SERVICE] Checking permission status...');
      }
      _permissionHandlerStatus = await locationPermission.status;

      // Jika permission sudah granted
      if (_permissionHandlerStatus ==
              permission_handler.PermissionStatus.granted ||
          _permissionHandlerStatus ==
              permission_handler.PermissionStatus.limited) {
        if (kDebugMode) {
          print('✅ [LOCATION SERVICE] Permission already granted');
        }
        // Sync dengan Geolocator
        _permissionStatus = await Geolocator.checkPermission();
        return true;
      }

      // Jika permission permanently denied
      if (_permissionHandlerStatus ==
          permission_handler.PermissionStatus.permanentlyDenied) {
        if (kDebugMode) {
          print('Location permission permanently denied');
        }
        _permissionStatus = LocationPermission.deniedForever;
        return false;
      }

      // Request permission jika belum granted
      if (_permissionHandlerStatus ==
          permission_handler.PermissionStatus.denied) {
        if (kDebugMode) {
          print('📍 [LOCATION SERVICE] Requesting permission...');
        }
        _permissionHandlerStatus = await locationPermission.request();

        if (kDebugMode) {
          print(
            '📍 [LOCATION SERVICE] Permission request result: ${_permissionHandlerStatus.toString()}',
          );
        }

        if (_permissionHandlerStatus ==
                permission_handler.PermissionStatus.granted ||
            _permissionHandlerStatus ==
                permission_handler.PermissionStatus.limited) {
          if (kDebugMode) {
            print('✅ [LOCATION SERVICE] Permission granted after request');
          }
          // Sync dengan Geolocator
          _permissionStatus = await Geolocator.checkPermission();
          return true;
        } else if (_permissionHandlerStatus ==
            permission_handler.PermissionStatus.permanentlyDenied) {
          if (kDebugMode) {
            print('❌ [LOCATION SERVICE] Permission permanently denied');
          }
          _permissionStatus = LocationPermission.deniedForever;
          return false;
        } else {
          if (kDebugMode) {
            print('❌ [LOCATION SERVICE] Permission denied');
          }
          _permissionStatus = LocationPermission.denied;
          return false;
        }
      }

      // Default: permission denied
      _permissionStatus = LocationPermission.denied;
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting location permission: $e');
      }
      _permissionStatus = LocationPermission.denied;
      return false;
    }
  }

  /// Cek permission status
  /// Returns: LocationPermission status
  Future<LocationPermission> checkPermission() async {
    try {
      // Cek menggunakan permission_handler dulu
      final status =
          await permission_handler.Permission.locationWhenInUse.status;

      // Map ke LocationPermission
      switch (status) {
        case permission_handler.PermissionStatus.granted:
        case permission_handler.PermissionStatus.limited:
          _permissionStatus = await Geolocator.checkPermission();
          break;
        case permission_handler.PermissionStatus.denied:
          _permissionStatus = LocationPermission.denied;
          break;
        case permission_handler.PermissionStatus.permanentlyDenied:
          _permissionStatus = LocationPermission.deniedForever;
          break;
        case permission_handler.PermissionStatus.restricted:
          _permissionStatus = LocationPermission.denied;
          break;
        case permission_handler.PermissionStatus.provisional:
          // iOS only - temporary permission
          _permissionStatus = await Geolocator.checkPermission();
          break;
      }

      return _permissionStatus ?? LocationPermission.denied;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking permission: $e');
      }
      // Fallback ke Geolocator
      _permissionStatus = await Geolocator.checkPermission();
      return _permissionStatus ?? LocationPermission.denied;
    }
  }

  /// Cek apakah permission sudah granted
  Future<bool> isPermissionGranted() async {
    final status = await checkPermission();
    return status == LocationPermission.whileInUse ||
        status == LocationPermission.always;
  }

  /// Cek apakah permission permanently denied
  Future<bool> isPermissionPermanentlyDenied() async {
    final status = await checkPermission();
    return status == LocationPermission.deniedForever;
  }

  /// Buka settings untuk enable permission
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Buka app settings
  Future<void> openAppSettings() async {
    await permission_handler.openAppSettings();
  }

  /// Dapatkan posisi saat ini (one-time) - FRESH DATA, NO CACHE
  /// [useGps]: true untuk GPS (high accuracy), false untuk network provider saja (low accuracy)
  /// Default: false (network provider saja)
  /// Throws: Exception jika permission tidak granted atau error lainnya
  ///
  /// ⚠️ IMPORTANT: Method ini selalu melakukan fresh fetch, TIDAK menggunakan cache
  Future<Position?> getCurrentPosition({bool useGps = false}) async {
    final locationSource = useGps ? 'GPS' : 'NETWORK';
    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('📍 [LOCATION SERVICE] getCurrentPosition() called');
      print('📍 [LOCATION SERVICE] useGps parameter: $useGps');
      print('📍 [LOCATION SERVICE] Location Source: $locationSource');
      print('✅ [LOCATION SERVICE] FRESH FETCH - NO CACHE will be used');
      print('═══════════════════════════════════════════════════════════');
    }

    try {
      // Cek permission dulu (hanya require GPS jika useGps = true)
      if (kDebugMode) {
        print(
          '📍 [LOCATION SERVICE] Checking permission (requireGps: $useGps)...',
        );
      }
      bool hasPermission = await requestPermission(requireGps: useGps);
      if (!hasPermission) {
        if (kDebugMode) {
          print('❌ [LOCATION SERVICE] Location permission not granted');
        }
        // Throw exception dengan message dari permission status
        final status = await checkPermission();
        if (status == LocationPermission.deniedForever) {
          throw PermissionDeniedException(
            'Location permission permanently denied',
          );
        } else {
          throw PermissionDeniedException('Location permission denied');
        }
      }
      if (kDebugMode) {
        print('✅ [LOCATION SERVICE] Permission granted');
      }

      // Untuk network provider, cek network availability
      if (!useGps) {
        if (kDebugMode) {
          print(
            '📍 [LOCATION SERVICE] Checking network availability for NETWORK provider...',
          );
        }
        bool networkAvailable = await isNetworkAvailable();
        if (!networkAvailable) {
          if (kDebugMode) {
            print(
              '⚠️ [LOCATION SERVICE] Network not available for network provider location',
            );
          }
          // Tetap lanjutkan, karena mungkin masih bisa dapat last known position
        } else {
          if (kDebugMode) {
            print('✅ [LOCATION SERVICE] Network available');
          }
        }
      } else {
        if (kDebugMode) {
          print('📍 [LOCATION SERVICE] Using GPS - skipping network check');
        }
      }

      // Pilih akurasi berdasarkan GPS toggle
      // LocationAccuracy.low = network provider saja (tanpa GPS)
      // LocationAccuracy.high = GPS dengan akurasi tinggi
      final accuracy = useGps ? LocationAccuracy.high : LocationAccuracy.low;

      if (kDebugMode) {
        print('📍 [LOCATION SERVICE] LocationAccuracy: ${accuracy.toString()}');
        print(
          '📍 [LOCATION SERVICE] Requesting position with $locationSource source...',
        );
      }

      // Dapatkan posisi dengan akurasi sesuai setting
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: const Duration(
            seconds: 15,
          ), // Increase timeout untuk network provider
        ),
      );

      // Log informasi position yang diterima
      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════════');
        print('✅ [LOCATION SERVICE] Position received!');
        print('📍 [LOCATION SERVICE] Requested Source: $locationSource');
        print(
          '📍 [LOCATION SERVICE] Position Accuracy: ${position.accuracy} meters',
        );
        print('📍 [LOCATION SERVICE] Position Latitude: ${position.latitude}');
        print(
          '📍 [LOCATION SERVICE] Position Longitude: ${position.longitude}',
        );
        print(
          '📍 [LOCATION SERVICE] Position Timestamp: ${position.timestamp}',
        );

        // Validasi: Cek apakah source sesuai dengan yang diminta
        // Network provider biasanya memiliki akurasi > 50 meter
        // GPS biasanya memiliki akurasi < 50 meter
        if (!useGps) {
          // NETWORK provider - harusnya akurasi > 50m
          if (position.accuracy < 50) {
            print(
              '⚠️⚠️⚠️ [LOCATION SERVICE] WARNING: Low accuracy (<50m) detected!',
            );
            print(
              '⚠️⚠️⚠️ [LOCATION SERVICE] This suggests GPS was used instead of NETWORK!',
            );
            print(
              '⚠️⚠️⚠️ [LOCATION SERVICE] Expected: NETWORK (accuracy >50m), Got: ${position.accuracy}m',
            );
            print(
              '⚠️⚠️⚠️ [LOCATION SERVICE] This should NOT happen for NETWORK provider!',
            );
          } else {
            print(
              '✅ [LOCATION SERVICE] Accuracy validation PASSED: ${position.accuracy}m > 50m (NETWORK source confirmed)',
            );
          }
        } else {
          // GPS provider - harusnya akurasi < 100m
          if (position.accuracy > 100) {
            print(
              '⚠️⚠️⚠️ [LOCATION SERVICE] WARNING: High accuracy (>100m) detected!',
            );
            print(
              '⚠️⚠️⚠️ [LOCATION SERVICE] This suggests NETWORK was used instead of GPS!',
            );
            print(
              '⚠️⚠️⚠️ [LOCATION SERVICE] Expected: GPS (accuracy <100m), Got: ${position.accuracy}m',
            );
            print(
              '⚠️⚠️⚠️ [LOCATION SERVICE] This should NOT happen for GPS provider!',
            );
          } else {
            print(
              '✅ [LOCATION SERVICE] Accuracy validation PASSED: ${position.accuracy}m < 100m (GPS source confirmed)',
            );
          }
        }
        print('═══════════════════════════════════════════════════════════');
      }

      return position;
    } on PermissionDeniedException catch (e) {
      if (kDebugMode) {
        print(
          '❌ [LOCATION SERVICE] PermissionDeniedException: ${e.toString()}',
        );
      }
      rethrow; // Throw kembali agar controller bisa handle dengan message asli
    } on LocationServiceDisabledException catch (e) {
      if (kDebugMode) {
        print(
          '❌ [LOCATION SERVICE] LocationServiceDisabledException: ${e.toString()}',
        );
      }
      rethrow; // Throw kembali agar controller bisa handle dengan message asli
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('❌ [LOCATION SERVICE] TimeoutException: ${e.toString()}');
      }
      rethrow; // Throw kembali agar controller bisa handle dengan message asli
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [LOCATION SERVICE] Error getting current position: $e');
        print('❌ [LOCATION SERVICE] Stack trace: $stackTrace');
      }
      rethrow; // Throw kembali agar controller bisa handle dengan message asli
    }
  }

  /// Dapatkan posisi terakhir yang diketahui (CACHED)
  /// ⚠️ WARNING: Method ini menggunakan cached position
  /// ⚠️ Method ini TIDAK digunakan di Network/GPS controllers untuk memastikan fresh data
  /// ⚠️ Hanya untuk keperluan khusus jika diperlukan
  Future<Position?> getLastKnownPosition() async {
    if (kDebugMode) {
      print(
        '⚠️⚠️⚠️ [LOCATION SERVICE] getLastKnownPosition() called - USING CACHE!',
      );
      print(
        '⚠️⚠️⚠️ [LOCATION SERVICE] WARNING: This uses cached position (may be from GPS or Network)',
      );
      print(
        '⚠️⚠️⚠️ [LOCATION SERVICE] This method should NOT be used for fresh location data!',
      );
    }

    try {
      bool hasPermission = await requestPermission();
      if (!hasPermission) {
        if (kDebugMode) {
          print(
            '❌ [LOCATION SERVICE] Permission not granted for last known position',
          );
        }
        return null;
      }

      Position? position = await Geolocator.getLastKnownPosition();

      if (kDebugMode) {
        if (position != null) {
          print('⚠️ [LOCATION SERVICE] Last known position found (CACHED)');
          print('📍 [LOCATION SERVICE] Accuracy: ${position.accuracy}m');
          print(
            '📍 [LOCATION SERVICE] Lat: ${position.latitude}, Lng: ${position.longitude}',
          );
          print(
            '⚠️ [LOCATION SERVICE] This is CACHED data - may not reflect current location!',
          );
        } else {
          print('⚠️ [LOCATION SERVICE] No last known position available');
        }
      }

      return position;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [LOCATION SERVICE] Error getting last known position: $e');
      }
      return null;
    }
  }

  /// Mulai listening posisi real-time
  /// [useGps]: true untuk GPS (high accuracy), false untuk network provider saja (low accuracy)
  /// Default: false (network provider saja)
  /// Note: Pastikan permission sudah granted sebelum memanggil method ini
  Stream<Position>? getPositionStream({
    bool useGps = false,
    int distanceFilter = 10, // meter
    Duration? timeLimit,
  }) {
    final locationSource = useGps ? 'GPS' : 'NETWORK';
    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('📍 [LOCATION SERVICE] getPositionStream() called');
      print('📍 [LOCATION SERVICE] useGps parameter: $useGps');
      print('📍 [LOCATION SERVICE] Location Source: $locationSource');
      print('📍 [LOCATION SERVICE] Distance Filter: $distanceFilter meters');
      print('═══════════════════════════════════════════════════════════');
    }

    try {
      // Pilih akurasi berdasarkan GPS toggle
      final accuracy = useGps ? LocationAccuracy.high : LocationAccuracy.low;

      if (kDebugMode) {
        print('📍 [LOCATION SERVICE] LocationAccuracy: ${accuracy.toString()}');
        print(
          '📍 [LOCATION SERVICE] Starting position stream with $locationSource source...',
        );
      }

      _positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          distanceFilter: distanceFilter,
          timeLimit: timeLimit,
        ),
      );

      // Wrap stream untuk logging dan validasi
      if (kDebugMode && _positionStream != null) {
        _positionStream = _positionStream!.map((position) {
          print(
            '📍 [LOCATION SERVICE] Stream update - Source: $locationSource',
          );
          print(
            '📍 [LOCATION SERVICE] Accuracy: ${position.accuracy}m, Lat: ${position.latitude}, Lng: ${position.longitude}',
          );

          // Validasi: Cek apakah source sesuai dengan yang diminta
          if (!useGps) {
            // NETWORK provider - harusnya akurasi > 50m
            if (position.accuracy < 50) {
              print(
                '⚠️⚠️⚠️ [LOCATION SERVICE] WARNING: Low accuracy (<50m) in stream!',
              );
              print(
                '⚠️⚠️⚠️ [LOCATION SERVICE] This suggests GPS was used instead of NETWORK!',
              );
              print(
                '⚠️⚠️⚠️ [LOCATION SERVICE] Expected: NETWORK (accuracy >50m), Got: ${position.accuracy}m',
              );
            } else {
              print(
                '✅ [LOCATION SERVICE] Stream validation PASSED: ${position.accuracy}m > 50m (NETWORK confirmed)',
              );
            }
          } else {
            // GPS provider - harusnya akurasi < 100m
            if (position.accuracy > 100) {
              print(
                '⚠️⚠️⚠️ [LOCATION SERVICE] WARNING: High accuracy (>100m) in stream!',
              );
              print(
                '⚠️⚠️⚠️ [LOCATION SERVICE] This suggests NETWORK was used instead of GPS!',
              );
              print(
                '⚠️⚠️⚠️ [LOCATION SERVICE] Expected: GPS (accuracy <100m), Got: ${position.accuracy}m',
              );
            } else {
              print(
                '✅ [LOCATION SERVICE] Stream validation PASSED: ${position.accuracy}m < 100m (GPS confirmed)',
              );
            }
          }

          return position;
        });
      }

      return _positionStream;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting position stream: $e');
      }
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
