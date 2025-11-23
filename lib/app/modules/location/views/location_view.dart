import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../controllers/location_controller.dart';

/// View untuk Live Location Tracker
/// Menampilkan koordinat dan OpenStreetMap dengan marker lokasi pengguna
class LocationView extends StatelessWidget {
  const LocationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshPosition,
            tooltip: 'Refresh Location',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: controller.openAppSettings,
            tooltip: 'Open Settings',
          ),
        ],
      ),
      body: Obx(() {
        // Loading state
        if (controller.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Mendapatkan lokasi...'),
              ],
            ),
          );
        }

        // Error state
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: controller.requestPermission,
                    icon: const Icon(Icons.location_on),
                    label: const Text('Request Permission'),
                  ),
                ],
              ),
            ),
          );
        }

        // Main content
        return Column(
          children: [
            // Coordinate Display Section
            _buildCoordinateDisplay(controller),

            // OpenStreetMap Section
            Expanded(child: _buildOpenStreetMap(controller)),
          ],
        );
      }),
      floatingActionButton: Obx(
        () => Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Zoom controls
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
                  onPressed: controller.zoomIn,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  onPressed: controller.zoomOut,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'center',
                  mini: true,
                  onPressed: controller.moveToCurrentPosition,
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tracking button
            FloatingActionButton.extended(
              heroTag: 'tracking',
              onPressed: controller.toggleTracking,
              icon: Icon(controller.isTracking ? Icons.stop : Icons.play_arrow),
              label: Text(
                controller.isTracking ? 'Stop Tracking' : 'Start Tracking',
              ),
              backgroundColor: controller.isTracking
                  ? Colors.red
                  : Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  /// Build coordinate display widget
  Widget _buildCoordinateDisplay(LocationController controller) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Koordinat Lokasi',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (controller.isTracking)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (controller.currentPosition != null) ...[
              _buildCoordinateRow(
                'Latitude',
                controller.latitude?.toStringAsFixed(6) ?? 'N/A',
                Icons.north,
              ),
              const SizedBox(height: 8),
              _buildCoordinateRow(
                'Longitude',
                controller.longitude?.toStringAsFixed(6) ?? 'N/A',
                Icons.east,
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Akurasi',
                      '${controller.accuracy?.toStringAsFixed(1) ?? 'N/A'} m',
                      Icons.my_location,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoCard(
                      'Altitude',
                      '${controller.altitude?.toStringAsFixed(1) ?? 'N/A'} m',
                      Icons.height,
                    ),
                  ),
                ],
              ),
              if (controller.speed != null && controller.speed! > 0) ...[
                const SizedBox(height: 8),
                _buildInfoCard(
                  'Speed',
                  '${controller.speed?.toStringAsFixed(1) ?? 'N/A'} m/s',
                  Icons.speed,
                ),
              ],
              if (controller.timestamp != null) ...[
                const SizedBox(height: 8),
                _buildInfoCard(
                  'Waktu',
                  DateFormat('HH:mm:ss').format(controller.timestamp!),
                  Icons.access_time,
                ),
              ],
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Tidak ada data lokasi',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ], // closes if/else spread
          ], // closes children: [ from line 161
        ), // Column
      ), // SingleChildScrollView
    ); // Container
  }

  /// Build coordinate row
  Widget _buildCoordinateRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Get.theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              SelectableText(
                value,
                style: Get.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 20),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            Get.snackbar(
              'Copied',
              '$label: $value',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            );
          },
        ),
      ],
    );
  }

  /// Build info card
  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.3,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Get.theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build OpenStreetMap widget menggunakan FlutterMap
  Widget _buildOpenStreetMap(LocationController controller) {
    if (controller.currentPosition == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Menunggu data lokasi...',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.getCurrentPosition,
              icon: const Icon(Icons.location_searching),
              label: const Text('Dapatkan Lokasi'),
            ),
          ],
        ),
      );
    }

    return Obx(
      () => FlutterMap(
        mapController: controller.mapController,
        options: MapOptions(
          initialCenter: controller.mapCenter,
          initialZoom: controller.mapZoom,
          minZoom: 3.0,
          maxZoom: 18.0,
          onMapEvent: (MapEvent event) {
            if (event is MapEventMove) {
              final camera = controller.mapController.camera;
              controller.updateMapCenter(camera.center, camera.zoom);
            }
          },
        ),
        children: [
          // Tile Layer - OpenStreetMap tiles
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'flutter_supabase',
            maxZoom: 19,
            // Retina mode untuk kualitas lebih baik
            retinaMode: MediaQuery.of(Get.context!).devicePixelRatio > 1.0,
          ),

          // Marker Layer - Menampilkan marker lokasi pengguna
          if (controller.currentPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(controller.latitude!, controller.longitude!),
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

          // Attribution
          RichAttributionWidget(
            alignment: AttributionAlignment.bottomLeft,
            popupBackgroundColor: Colors.white,
            attributions: [
              TextSourceAttribution('OpenStreetMap', onTap: () => {}),
              TextSourceAttribution('Contributors', onTap: () => {}),
            ],
          ),
        ],
      ),
    );
  }
}
