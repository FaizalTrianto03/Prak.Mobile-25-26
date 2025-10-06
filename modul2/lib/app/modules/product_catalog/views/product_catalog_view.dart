import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Aplikasi Katalog Produk Dinamis dengan Responsivitas dan Animasi
/// 
/// Fitur utama:
/// - Grid responsif yang menyesuaikan jumlah kolom berdasarkan lebar layar (MediaQuery)
/// - Animasi implisit menggunakan AnimatedContainer
/// - Kontrol interaktif untuk spacing dan scale
/// - State management menggunakan StatefulWidget
/// - Dukungan light/dark mode dengan warna solid minimalist
class ProductCatalogView extends StatefulWidget {
  const ProductCatalogView({super.key});

  @override
  State<ProductCatalogView> createState() => _ProductCatalogViewState();
}

class _ProductCatalogViewState extends State<ProductCatalogView> {
  // State variables untuk kontrol UI
  double _itemSpacing = 16.0; // Jarak antar item (8-32px)
  double _scaleFactor = 1.0; // Scale factor untuk card (0.8-1.2)
  int? _selectedIndex; // Index item yang sedang dipilih

  // Data produk dummy dengan warna solid yang proporsional untuk light/dark mode
  final List<ProductItem> _products = [
    ProductItem(
      name: 'Laptop Premium',
      icon: Icons.laptop_mac,
      colorLight: const Color(0xFF5DADE2), // Soft blue
      colorDark: const Color(0xFF3498DB),
    ),
    ProductItem(
      name: 'Smartphone',
      icon: Icons.phone_android,
      colorLight: const Color(0xFF58D68D), // Soft green
      colorDark: const Color(0xFF27AE60),
    ),
    ProductItem(
      name: 'Tablet Pro',
      icon: Icons.tablet_mac,
      colorLight: const Color(0xFFEC7063), // Soft coral
      colorDark: const Color(0xFFE74C3C),
    ),
    ProductItem(
      name: 'Smartwatch',
      icon: Icons.watch,
      colorLight: const Color(0xFFAF7AC5), // Soft purple
      colorDark: const Color(0xFF9B59B6),
    ),
    ProductItem(
      name: 'Headphone',
      icon: Icons.headphones,
      colorLight: const Color(0xFFF39C12), // Soft orange
      colorDark: const Color(0xFFE67E22),
    ),
    ProductItem(
      name: 'Kamera DSLR',
      icon: Icons.camera_alt,
      colorLight: const Color(0xFF48C9B0), // Soft teal
      colorDark: const Color(0xFF16A085),
    ),
    ProductItem(
      name: 'Speaker',
      icon: Icons.speaker,
      colorLight: const Color(0xFF5DADE2), // Soft blue
      colorDark: const Color(0xFF2980B9),
    ),
    ProductItem(
      name: 'Keyboard',
      icon: Icons.keyboard,
      colorLight: const Color(0xFFEC7063), // Soft coral
      colorDark: const Color(0xFFC0392B),
    ),
    ProductItem(
      name: 'Mouse Gaming',
      icon: Icons.mouse,
      colorLight: const Color(0xFF48C9B0), // Soft teal
      colorDark: const Color(0xFF1ABC9C),
    ),
    ProductItem(
      name: 'Monitor 4K',
      icon: Icons.desktop_windows,
      colorLight: const Color(0xFF58D68D), // Soft green
      colorDark: const Color(0xFF229954),
    ),
    ProductItem(
      name: 'Printer',
      icon: Icons.print,
      colorLight: const Color(0xFFF39C12), // Soft orange
      colorDark: const Color(0xFFD68910),
    ),
    ProductItem(
      name: 'Router WiFi',
      icon: Icons.router,
      colorLight: const Color(0xFFAF7AC5), // Soft purple
      colorDark: const Color(0xFF8E44AD),
    ),
    ProductItem(
      name: 'Hard Drive',
      icon: Icons.storage,
      colorLight: const Color(0xFF85929E), // Soft gray
      colorDark: const Color(0xFF5D6D7E),
    ),
    ProductItem(
      name: 'Microphone',
      icon: Icons.mic,
      colorLight: const Color(0xFF58D68D), // Soft green
      colorDark: const Color(0xFF28B463),
    ),
    ProductItem(
      name: 'Webcam HD',
      icon: Icons.videocam,
      colorLight: const Color(0xFFAF7AC5), // Soft purple
      colorDark: const Color(0xFF7D3C98),
    ),
    ProductItem(
      name: 'Gaming Console',
      icon: Icons.sports_esports,
      colorLight: const Color(0xFF5DADE2), // Soft blue
      colorDark: const Color(0xFF2E86C1),
    ),
    ProductItem(
      name: 'Smart TV',
      icon: Icons.tv,
      colorLight: const Color(0xFF48C9B0), // Soft teal
      colorDark: const Color(0xFF138D75),
    ),
    ProductItem(
      name: 'Power Bank',
      icon: Icons.battery_charging_full,
      colorLight: const Color(0xFFF39C12), // Soft orange
      colorDark: const Color(0xFFCA6F1E),
    ),
    ProductItem(
      name: 'USB Hub',
      icon: Icons.usb,
      colorLight: const Color(0xFF85929E), // Soft gray
      colorDark: const Color(0xFF566573),
    ),
    ProductItem(
      name: 'Charger',
      icon: Icons.electrical_services,
      colorLight: const Color(0xFFEC7063), // Soft coral
      colorDark: const Color(0xFFCD6155),
    ),
  ];

  /// Menentukan jumlah kolom grid berdasarkan lebar layar (MediaQuery)
  /// Breakpoint: <600px = 2 kolom, 600-800px = 3 kolom, >800px = 4 kolom
  int _getCrossAxisCount(double width) {
    if (width < 600) {
      return 2; // Mobile portrait
    } else if (width < 800) {
      return 3; // Tablet portrait
    } else {
      return 4; // Tablet landscape / Desktop
    }
  }

  /// Menghitung ukuran font yang adaptif berdasarkan lebar layar
  double _getAdaptiveFontSize(double width) {
    if (width < 600) {
      return 13.0;
    } else if (width < 800) {
      return 15.0;
    } else {
      return 16.0;
    }
  }

  /// Menghitung ukuran icon yang adaptif
  double _getAdaptiveIconSize(double width) {
    if (width < 600) {
      return 36.0;
    } else if (width < 800) {
      return 42.0;
    } else {
      return 48.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Produk'),
        actions: [
          // Theme toggle
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              Get.changeThemeMode(
                isDark ? ThemeMode.light : ThemeMode.dark,
              );
            },
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
          ),
        ],
      ),
      body: Column(
        children: [
          // Panel kontrol untuk spacing dan scale
          _buildControlPanel(context),
          
          // Info breakpoint
          _buildBreakpointInfo(context),
          
          // Grid produk yang responsif
          Expanded(
            child: _buildResponsiveGrid(context),
          ),
        ],
      ),
    );
  }

  /// Widget panel kontrol dengan slider dan informasi
  Widget _buildControlPanel(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = _getAdaptiveFontSize(width);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(width < 600 ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAFAFA),
        border: Border(
          bottom: BorderSide(
            color: isDark 
                ? Colors.white.withOpacity(0.1) 
                : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Slider untuk spacing
          _buildSliderControl(
            context,
            icon: Icons.space_bar,
            label: 'Jarak Item',
            value: _itemSpacing,
            min: 8.0,
            max: 32.0,
            divisions: 24,
            fontSize: fontSize,
            onChanged: (value) {
              setState(() {
                _itemSpacing = value;
              });
            },
          ),
          
          SizedBox(height: width < 600 ? 8 : 12),
          
          // Slider untuk scale factor
          _buildSliderControl(
            context,
            icon: Icons.zoom_in,
            label: 'Skala Card',
            value: _scaleFactor,
            min: 0.8,
            max: 1.2,
            divisions: 20,
            fontSize: fontSize,
            isPercentage: true,
            onChanged: (value) {
              setState(() {
                _scaleFactor = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliderControl(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required double fontSize,
    required Function(double) onChanged,
    bool isPercentage = false,
  }) {
    final displayValue = isPercentage 
        ? '${(value * 100).toStringAsFixed(0)}%' 
        : '${value.toStringAsFixed(0)}px';
    
    return Row(
      children: [
        Icon(icon, size: fontSize + 6),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      displayValue,
                      style: TextStyle(
                        fontSize: fontSize - 1,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                label: displayValue,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Info breakpoint dan kolom
  Widget _buildBreakpointInfo(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(width);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    String breakpointName;
    if (width < 600) {
      breakpointName = 'Mobile';
    } else if (width < 800) {
      breakpointName = 'Tablet';
    } else {
      breakpointName = 'Desktop';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: isDark 
          ? const Color(0xFF2C3E50).withOpacity(0.3)
          : const Color(0xFF2C3E50).withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Text(
            'MediaQuery • $breakpointName (${width.toInt()}px) • $crossAxisCount Kolom',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget grid responsif menggunakan MediaQuery
  Widget _buildResponsiveGrid(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(width);
    final fontSize = _getAdaptiveFontSize(width);
    final iconSize = _getAdaptiveIconSize(width);

    return GridView.builder(
      padding: EdgeInsets.all(_itemSpacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: _itemSpacing,
        mainAxisSpacing: _itemSpacing,
        childAspectRatio: 0.85,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(
          context,
          _products[index],
          index,
          fontSize,
          iconSize,
        );
      },
    );
  }

  /// Widget card produk individual dengan animasi implisit (AnimatedContainer)
  /// Durasi 400ms dengan curve easeInOutCubic untuk transisi smooth
  Widget _buildProductCard(
    BuildContext context,
    ProductItem product,
    int index,
    double fontSize,
    double iconSize,
  ) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productColor = isDark ? product.colorDark : product.colorLight;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle selection dengan setState untuk trigger rebuild
          _selectedIndex = isSelected ? null : index;
        });
      },
      child: AnimatedContainer(
        // Animasi implisit dengan durasi 400ms
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        
        // Transform scale saat dipilih (10-15% lebih besar)
        transform: Matrix4.identity()
          ..scale(
            isSelected ? _scaleFactor * 1.12 : _scaleFactor,
            isSelected ? _scaleFactor * 1.12 : _scaleFactor,
          ),
        
        child: Card(
          // Elevation meningkat saat dipilih
          elevation: isSelected ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            // Border yang muncul saat dipilih
            side: BorderSide(
              color: isSelected 
                  ? productColor 
                  : Colors.transparent,
              width: 2,
            ),
          ),
          
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            
            // Background berubah saat dipilih
            decoration: BoxDecoration(
              color: isSelected 
                  ? productColor.withOpacity(isDark ? 0.15 : 0.08)
                  : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
              borderRadius: BorderRadius.circular(12),
            ),
            
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container icon dengan animasi
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  width: isSelected ? iconSize * 1.5 : iconSize * 1.3,
                  height: isSelected ? iconSize * 1.5 : iconSize * 1.3,
                  decoration: BoxDecoration(
                    // Warna solid proporsional
                    color: productColor,
                    borderRadius: BorderRadius.circular(10),
                    // Shadow yang muncul saat dipilih
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: productColor.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    product.icon,
                    size: iconSize,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Nama produk
                Text(
                  product.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: isSelected 
                        ? FontWeight.w700 
                        : FontWeight.w500,
                    color: isSelected 
                        ? productColor 
                        : Theme.of(context).colorScheme.onSurface,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Model data untuk produk dengan warna untuk light dan dark mode
class ProductItem {
  final String name;
  final IconData icon;
  final Color colorLight; // Warna untuk light mode
  final Color colorDark; // Warna untuk dark mode

  ProductItem({
    required this.name,
    required this.icon,
    required this.colorLight,
    required this.colorDark,
  });
}
