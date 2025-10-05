import 'package:flutter/material.dart';

/// Alternatif implementasi Katalog Produk menggunakan LayoutBuilder
/// 
/// Perbedaan dengan implementasi MediaQuery:
/// - LayoutBuilder tidak bergantung pada ukuran layar global
/// - Lebih modular dan dapat digunakan dalam container dengan ukuran custom
/// - Responsif terhadap ukuran parent widget, bukan ukuran layar
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
      color: Colors.blue.shade300,
    ),
    ProductItem(
      name: 'Smartphone',
      icon: Icons.phone_android,
      color: Colors.green.shade300,
    ),
    ProductItem(
      name: 'Tablet Pro',
      icon: Icons.tablet_mac,
      color: Colors.orange.shade300,
    ),
    ProductItem(
      name: 'Smartwatch',
      icon: Icons.watch,
      color: Colors.purple.shade300,
    ),
    ProductItem(
      name: 'Headphone',
      icon: Icons.headphones,
      color: Colors.red.shade300,
    ),
    ProductItem(
      name: 'Kamera DSLR',
      icon: Icons.camera_alt,
      color: Colors.teal.shade300,
    ),
    ProductItem(
      name: 'Speaker',
      icon: Icons.speaker,
      color: Colors.indigo.shade300,
    ),
    ProductItem(
      name: 'Keyboard Mechanical',
      icon: Icons.keyboard,
      color: Colors.pink.shade300,
    ),
    ProductItem(
      name: 'Mouse Gaming',
      icon: Icons.mouse,
      color: Colors.cyan.shade300,
    ),
    ProductItem(
      name: 'Monitor 4K',
      icon: Icons.desktop_windows,
      color: Colors.lime.shade300,
    ),
    ProductItem(
      name: 'Printer',
      icon: Icons.print,
      color: Colors.amber.shade300,
    ),
    ProductItem(
      name: 'Router WiFi',
      icon: Icons.router,
      color: Colors.deepOrange.shade300,
    ),
    ProductItem(
      name: 'Hard Drive',
      icon: Icons.storage,
      color: Colors.blueGrey.shade300,
    ),
    ProductItem(
      name: 'Microphone',
      icon: Icons.mic,
      color: Colors.lightGreen.shade300,
    ),
    ProductItem(
      name: 'Webcam HD',
      icon: Icons.videocam,
      color: Colors.deepPurple.shade300,
    ),
    ProductItem(
      name: 'Gaming Console',
      icon: Icons.sports_esports,
      color: Colors.brown.shade300,
    ),
    ProductItem(
      name: 'Smart TV',
      icon: Icons.tv,
      color: Colors.lightBlue.shade300,
    ),
    ProductItem(
      name: 'Power Bank',
      icon: Icons.battery_charging_full,
      color: Colors.yellow.shade700,
    ),
    ProductItem(
      name: 'USB Hub',
      icon: Icons.usb,
      color: Colors.grey.shade400,
    ),
    ProductItem(
      name: 'Charger Fast',
      icon: Icons.electrical_services,
      color: Colors.orange.shade400,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Produk (LayoutBuilder)'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          _buildControlPanel(context),
          Expanded(
            // LayoutBuilder akan memberikan constraints dari parent
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _buildGridWithConstraints(constraints);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.space_bar),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jarak Item: ${_itemSpacing.toStringAsFixed(0)}px',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Slider(
                      value: _itemSpacing,
                      min: 8.0,
                      max: 32.0,
                      divisions: 24,
                      label: '${_itemSpacing.toStringAsFixed(0)}px',
                      onChanged: (value) {
                        setState(() {
                          _itemSpacing = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.zoom_in),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skala Card: ${(_scaleFactor * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Slider(
                      value: _scaleFactor,
                      min: 0.8,
                      max: 1.2,
                      divisions: 20,
                      label: '${(_scaleFactor * 100).toStringAsFixed(0)}%',
                      onChanged: (value) {
                        setState(() {
                          _scaleFactor = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build grid berdasarkan constraints dari LayoutBuilder
  /// Ini adalah keuntungan utama LayoutBuilder - responsif terhadap parent, bukan layar
  Widget _buildGridWithConstraints(BoxConstraints constraints) {
    // Menentukan kolom berdasarkan lebar maksimal yang tersedia
    final crossAxisCount = _getCrossAxisCountFromWidth(constraints.maxWidth);
    
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
        return _buildProductCard(_products[index], index);
      },
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

  Widget _buildProductCard(ProductItem product, int index) {
    final isSelected = _selectedIndex == index;

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
            isSelected ? _scaleFactor * 1.15 : _scaleFactor,
            isSelected ? _scaleFactor * 1.15 : _scaleFactor,
          ),
        child: Card(
          elevation: isSelected ? 12 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            decoration: BoxDecoration(
              color: isSelected
                  ? product.color.withOpacity(0.3)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  width: isSelected ? 72 : 64,
                  height: isSelected ? 72 : 64,
                  decoration: BoxDecoration(
                    color: product.color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: product.color.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    product.icon,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    product.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? Colors.blue.shade900
                          : Colors.black87,
                    ),
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
  final Color color;

  ProductItem({
    required this.name,
    required this.icon,
    required this.color,
  });
}
