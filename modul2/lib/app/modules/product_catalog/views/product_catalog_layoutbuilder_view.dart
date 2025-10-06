import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Alternatif implementasi Katalog Produk menggunakan LayoutBuilder
/// 
/// Perbedaan dengan implementasi MediaQuery:
/// - LayoutBuilder tidak bergantung pada ukuran layar global
/// - Lebih modular dan dapat digunakan dalam container dengan ukuran custom
/// - Responsif terhadap ukuran parent widget, bukan ukuran layar
/// - Dukungan light/dark mode dengan warna solid minimalist
class ProductCatalogLayoutBuilderView extends StatefulWidget {
  const ProductCatalogLayoutBuilderView({super.key});

  @override
  State<ProductCatalogLayoutBuilderView> createState() =>
      _ProductCatalogLayoutBuilderViewState();
}

class _ProductCatalogLayoutBuilderViewState
    extends State<ProductCatalogLayoutBuilderView> {
  double _itemSpacing = 16.0;
  double _scaleFactor = 1.0;
  int? _selectedIndex;

  // Data produk yang sama dengan versi MediaQuery
  final List<ProductItem> _products = [
    ProductItem(
      name: 'Laptop Premium',
      icon: Icons.laptop_mac,
      colorLight: const Color(0xFF5DADE2),
      colorDark: const Color(0xFF3498DB),
    ),
    ProductItem(
      name: 'Smartphone',
      icon: Icons.phone_android,
      colorLight: const Color(0xFF58D68D),
      colorDark: const Color(0xFF27AE60),
    ),
    ProductItem(
      name: 'Tablet Pro',
      icon: Icons.tablet_mac,
      colorLight: const Color(0xFFEC7063),
      colorDark: const Color(0xFFE74C3C),
    ),
    ProductItem(
      name: 'Smartwatch',
      icon: Icons.watch,
      colorLight: const Color(0xFFAF7AC5),
      colorDark: const Color(0xFF9B59B6),
    ),
    ProductItem(
      name: 'Headphone',
      icon: Icons.headphones,
      colorLight: const Color(0xFFF39C12),
      colorDark: const Color(0xFFE67E22),
    ),
    ProductItem(
      name: 'Kamera DSLR',
      icon: Icons.camera_alt,
      colorLight: const Color(0xFF48C9B0),
      colorDark: const Color(0xFF16A085),
    ),
    ProductItem(
      name: 'Speaker',
      icon: Icons.speaker,
      colorLight: const Color(0xFF5DADE2),
      colorDark: const Color(0xFF2980B9),
    ),
    ProductItem(
      name: 'Keyboard',
      icon: Icons.keyboard,
      colorLight: const Color(0xFFEC7063),
      colorDark: const Color(0xFFC0392B),
    ),
    ProductItem(
      name: 'Mouse Gaming',
      icon: Icons.mouse,
      colorLight: const Color(0xFF48C9B0),
      colorDark: const Color(0xFF1ABC9C),
    ),
    ProductItem(
      name: 'Monitor 4K',
      icon: Icons.desktop_windows,
      colorLight: const Color(0xFF58D68D),
      colorDark: const Color(0xFF229954),
    ),
    ProductItem(
      name: 'Printer',
      icon: Icons.print,
      colorLight: const Color(0xFFF39C12),
      colorDark: const Color(0xFFD68910),
    ),
    ProductItem(
      name: 'Router WiFi',
      icon: Icons.router,
      colorLight: const Color(0xFFAF7AC5),
      colorDark: const Color(0xFF8E44AD),
    ),
    ProductItem(
      name: 'Hard Drive',
      icon: Icons.storage,
      colorLight: const Color(0xFF85929E),
      colorDark: const Color(0xFF5D6D7E),
    ),
    ProductItem(
      name: 'Microphone',
      icon: Icons.mic,
      colorLight: const Color(0xFF58D68D),
      colorDark: const Color(0xFF28B463),
    ),
    ProductItem(
      name: 'Webcam HD',
      icon: Icons.videocam,
      colorLight: const Color(0xFFAF7AC5),
      colorDark: const Color(0xFF7D3C98),
    ),
    ProductItem(
      name: 'Gaming Console',
      icon: Icons.sports_esports,
      colorLight: const Color(0xFF5DADE2),
      colorDark: const Color(0xFF2E86C1),
    ),
    ProductItem(
      name: 'Smart TV',
      icon: Icons.tv,
      colorLight: const Color(0xFF48C9B0),
      colorDark: const Color(0xFF138D75),
    ),
    ProductItem(
      name: 'Power Bank',
      icon: Icons.battery_charging_full,
      colorLight: const Color(0xFFF39C12),
      colorDark: const Color(0xFFCA6F1E),
    ),
    ProductItem(
      name: 'USB Hub',
      icon: Icons.usb,
      colorLight: const Color(0xFF85929E),
      colorDark: const Color(0xFF566573),
    ),
    ProductItem(
      name: 'Charger',
      icon: Icons.electrical_services,
      colorLight: const Color(0xFFEC7063),
      colorDark: const Color(0xFFCD6155),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog (LayoutBuilder)'),
        actions: [
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
          _buildControlPanel(context),
          Expanded(
            // LayoutBuilder memberikan constraints dari parent widget
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _buildGridWithConstraints(context, constraints);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20.0),
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
          _buildSliderControl(
            context,
            icon: Icons.space_bar,
            label: 'Jarak Item',
            value: _itemSpacing,
            min: 8.0,
            max: 32.0,
            divisions: 24,
            onChanged: (value) {
              setState(() {
                _itemSpacing = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildSliderControl(
            context,
            icon: Icons.zoom_in,
            label: 'Skala Card',
            value: _scaleFactor,
            min: 0.8,
            max: 1.2,
            divisions: 20,
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
    required Function(double) onChanged,
    bool isPercentage = false,
  }) {
    final displayValue = isPercentage 
        ? '${(value * 100).toStringAsFixed(0)}%' 
        : '${value.toStringAsFixed(0)}px';
    
    return Row(
      children: [
        Icon(icon, size: 21),
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
                    style: const TextStyle(
                      fontSize: 15,
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
                        fontSize: 14,
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

  /// Build grid berdasarkan constraints dari LayoutBuilder
  /// Ini adalah keuntungan utama LayoutBuilder - responsif terhadap parent, bukan layar
  Widget _buildGridWithConstraints(BuildContext context, BoxConstraints constraints) {
    // Menentukan kolom berdasarkan lebar maksimal yang tersedia dari constraints
    final crossAxisCount = _getCrossAxisCountFromWidth(constraints.maxWidth);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    String breakpointName;
    if (constraints.maxWidth < 600) {
      breakpointName = 'Mobile';
    } else if (constraints.maxWidth < 800) {
      breakpointName = 'Tablet';
    } else {
      breakpointName = 'Desktop';
    }
    
    return Column(
      children: [
        // Info breakpoint dari LayoutBuilder
        Container(
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
                'LayoutBuilder • $breakpointName (${constraints.maxWidth.toInt()}px) • $crossAxisCount Kolom',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        
        // Grid view
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(_itemSpacing),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: _itemSpacing,
              mainAxisSpacing: _itemSpacing,
              childAspectRatio: 0.85,
            ),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(context, _products[index], index);
            },
          ),
        ),
      ],
    );
  }

  /// Logika breakpoint sama dengan MediaQuery version
  int _getCrossAxisCountFromWidth(double width) {
    if (width < 600) {
      return 2;
    } else if (width < 800) {
      return 3;
    } else {
      return 4;
    }
  }

  Widget _buildProductCard(BuildContext context, ProductItem product, int index) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productColor = isDark ? product.colorDark : product.colorLight;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = isSelected ? null : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        transform: Matrix4.identity()
          ..scale(
            isSelected ? _scaleFactor * 1.12 : _scaleFactor,
            isSelected ? _scaleFactor * 1.12 : _scaleFactor,
          ),
        child: Card(
          elevation: isSelected ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? productColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  width: isSelected ? 60 : 52,
                  height: isSelected ? 60 : 52,
                  decoration: BoxDecoration(
                    color: productColor,
                    borderRadius: BorderRadius.circular(10),
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
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  product.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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

/// Model data produk (sama dengan versi MediaQuery)
class ProductItem {
  final String name;
  final IconData icon;
  final Color colorLight;
  final Color colorDark;

  ProductItem({
    required this.name,
    required this.icon,
    required this.colorLight,
    required this.colorDark,
  });
}
