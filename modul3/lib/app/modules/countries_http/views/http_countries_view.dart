import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/http_countries_controller.dart';

// Halaman countries yang pakai HTTP package
// Di sini kalian bisa lihat:
// - Responsive design pakai MediaQuery
// - Handle loading, error, success state
// - Pull to refresh
// - Search dengan debouncing
class HttpCountriesView extends GetView<HttpCountriesController> {
  const HttpCountriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Pakai MediaQuery untuk cek ukuran layar (responsive)
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countries (HTTP)'),
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
          _buildInfoBanner(context, isTablet),
          
          // Search bar
          _buildSearchBar(context, isTablet),
          
          // Countries list
          Expanded(
            child: Obx(() {
              // Obx ini otomatis rebuild kalau state berubah
              
              // Cek loading state
              if (controller.isLoading.value && controller.countries.isEmpty) {
                return _buildLoadingState();
              }
              
              // Cek error state
              if (controller.errorMessage.isNotEmpty && controller.countries.isEmpty) {
                return _buildErrorState(context);
              }
              
              // Success state - tampilkan list dengan RefreshIndicator
              return RefreshIndicator(
                onRefresh: controller.refreshCountries,
                child: _buildCountriesList(context, isTablet),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: isTablet ? 20 : 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Expanded(
            child: Text(
              'Menggunakan HTTP package • MediaQuery responsive',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
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
          Text('Loading countries...'),
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

  Widget _buildCountriesList(BuildContext context, bool isTablet) {
    return Obx(() {
      final countries = controller.countries;
      
      if (countries.isEmpty) {
        return const Center(
          child: Text('No countries found'),
        );
      }
      
      // Tampilan responsive: Grid untuk tablet, List untuk mobile
      if (isTablet) {
        // Tablet = pakai grid 2 kolom
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3,
          ),
          itemCount: countries.length,
          itemBuilder: (context, index) {
            return _buildCountryCard(context, countries[index]);
          },
        );
      } else {
        // Mobile = pakai list biasa
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: countries.length,
          itemBuilder: (context, index) {
            return _buildCountryCard(context, countries[index]);
          },
        );
      }
    });
  }

  Widget _buildCountryCard(BuildContext context, country) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Icon(
            Icons.flag,
            color: Theme.of(context).colorScheme.primary,
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
