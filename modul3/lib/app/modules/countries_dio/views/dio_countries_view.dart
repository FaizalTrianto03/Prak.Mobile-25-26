import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dio_countries_controller.dart';

// Halaman countries yang pakai Dio package
// Perbedaan dengan HTTP view:
// - Pakai LayoutBuilder bukan MediaQuery (lebih modular)
// - Ada progress tracking (fitur khusus Dio)
class DioCountriesView extends GetView<DioCountriesController> {
  const DioCountriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countries (Dio)'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          _buildInfoBanner(context),
          
          // Progress indicator (Dio feature)
          _buildProgressIndicator(),
          
          // Search bar
          _buildSearchBar(context),
          
          // Countries list dengan LayoutBuilder
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.countries.isEmpty) {
                return _buildLoadingState();
              }
              
              if (controller.errorMessage.isNotEmpty && controller.countries.isEmpty) {
                return _buildErrorState(context);
              }
              
              return RefreshIndicator(
                onRefresh: controller.refreshCountries,
                child: _buildCountriesListWithLayoutBuilder(),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.fetchCountriesWithProgress,
        icon: const Icon(Icons.download),
        label: const Text('Fetch with Progress'),
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Menggunakan Dio package • LayoutBuilder responsive',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Obx(() {
      final progress = controller.downloadProgress.value;
      
      // Tampilkan progress bar kalau lagi download
      if (progress > 0 && progress < 1) {
        return Column(
          children: [
            LinearProgressIndicator(value: progress),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Downloading: ${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        );
      }
      
      return const SizedBox.shrink();
    });
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: controller.searchCountry,
        decoration: InputDecoration(
          hintText: 'Search countries...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.clear),
                onPressed: controller.clearSearch,
              );
            }
            return const SizedBox.shrink();
          }),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading countries with Dio...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            )),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.fetchCountries,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // LayoutBuilder ini mirip MediaQuery tapi lebih modular
  // Dia cuma peduli ukuran widget parent, bukan ukuran layar
  Widget _buildCountriesListWithLayoutBuilder() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Cek lebar yang tersedia dari parent widget
        final width = constraints.maxWidth;
        final isTablet = width > 600;
        final isDesktop = width > 900;
        
        return Obx(() {
          final countries = controller.countries;
          
          if (countries.isEmpty) {
            return const Center(
              child: Text('No countries found'),
            );
          }
          
          // Layout adaptif berdasarkan lebar yang tersedia
          if (isDesktop) {
            return _buildGridView(context, countries, 3); // Desktop = 3 kolom
          } else if (isTablet) {
            return _buildGridView(context, countries, 2); // Tablet = 2 kolom
          } else {
            return _buildListView(context, countries); // Mobile = list
          }
        });
      },
    );
  }

  Widget _buildGridView(BuildContext context, List countries, int columns) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3,
      ),
      itemCount: countries.length,
      itemBuilder: (context, index) {
        return _buildCountryCard(context, countries[index]);
      },
    );
  }

  Widget _buildListView(BuildContext context, List countries) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: countries.length,
      itemBuilder: (context, index) {
        return _buildCountryCard(context, countries[index]);
      },
    );
  }

  Widget _buildCountryCard(BuildContext context, country) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          child: Icon(
            Icons.flag,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        title: Text(
          country.commonName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          country.officialName,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        ),
      ),
    );
  }
}
