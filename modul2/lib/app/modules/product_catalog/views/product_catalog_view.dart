import 'package:flutter/material.dart';

/// Aplikasi Katalog Produk Dinamis dengan Responsivitas dan Animasi
/// 
/// Fitur utama:
/// - Grid responsif yang menyesuaikan jumlah kolom berdasarkan lebar layar
/// - Animasi implisit menggunakan AnimatedContainer
/// - Kontrol interaktif untuk spacing dan scale
/// - State management menggunakan StatefulWidget
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

  // Data produk dummy - minimal 20 item
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

  /// Menentukan jumlah kolom grid berdasarkan lebar layar
  /// - < 600px: 2 kolom (smartphone)
  /// - 600-800px: 3 kolom (tablet portrait)
  /// - > 800px: 4 kolom (tablet landscape/desktop)
  int _getCrossAxisCount(double width) {
    if (width < 600) {
      return 2;
    } else if (width < 800) {
      return 3;
    } else {
      return 4;
    }
  }

  /// Menghitung ukuran font yang adaptif berdasarkan lebar layar
  double _getAdaptiveFontSize(double width) {
    if (width < 600) {
      return 14.0;
    } else if (width < 800) {
      return 16.0;
    } else {
      return 18.0;
    }
  }

  /// Menghitung ukuran icon yang adaptif
  double _getAdaptiveIconSize(double width) {
    if (width < 600) {
      return 40.0;
    } else if (width < 800) {
      return 48.0;
    } else {
      return 56.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Produk'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Panel kontrol untuk spacing dan scale
          _buildControlPanel(context),
          
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
    
    return Container(
      padding: EdgeInsets.all(width < 600 ? 12.0 : 16.0),
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
          // Slider untuk spacing
          Row(
            children: [
              Icon(Icons.space_bar, size: fontSize + 4),
              SizedBox(width: width < 600 ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jarak Item: ${_itemSpacing.toStringAsFixed(0)}px',
                      style: TextStyle(
                        fontSize: fontSize,
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
          
          // Slider untuk scale factor
          Row(
            children: [
              Icon(Icons.zoom_in, size: fontSize + 4),
              SizedBox(width: width < 600 ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skala Card: ${(_scaleFactor * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: fontSize,
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

  /// Widget grid responsif menggunakan MediaQuery
  /// Otomatis menyesuaikan jumlah kolom berdasarkan lebar layar
  Widget _buildResponsiveGrid(BuildContext context) {
    // Menggunakan MediaQuery untuk mendapatkan ukuran layar
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
        childAspectRatio: 0.85, // Rasio lebar:tinggi card
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

  /// Widget card produk individual dengan animasi implisit
  /// Menggunakan AnimatedContainer untuk transisi smooth
  Widget _buildProductCard(
    BuildContext context,
    ProductItem product,
    int index,
    double fontSize,
    double iconSize,
  ) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle selection: jika sudah dipilih, unselect
          _selectedIndex = isSelected ? null : index;
        });
      },
      child: AnimatedContainer(
        // Durasi animasi 400ms dengan curve easeInOutCubic
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        
        // Transform untuk scale effect saat dipilih
        transform: Matrix4.identity()
          ..scale(
            isSelected ? _scaleFactor * 1.15 : _scaleFactor,
            isSelected ? _scaleFactor * 1.15 : _scaleFactor,
          ),
        
        child: Card(
          // Elevation meningkat saat dipilih
          elevation: isSelected ? 12 : 4,
          
          // Rounded corners
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
            
            // Background berubah warna saat dipilih
            decoration: BoxDecoration(
              color: isSelected 
                  ? product.color.withOpacity(0.3)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container berwarna sebagai placeholder image
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  width: isSelected ? iconSize * 1.8 : iconSize * 1.6,
                  height: isSelected ? iconSize * 1.8 : iconSize * 1.6,
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
                    size: iconSize,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Nama produk
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    product.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: isSelected 
                          ? FontWeight.bold 
                          : FontWeight.w500,
                      color: isSelected ? Colors.blue.shade900 : Colors.black87,
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

/// Widget alternatif menggunakan LayoutBuilder
/// Tidak bergantung pada ukuran layar global, lebih modular
class ResponsiveGridWithLayoutBuilder extends StatelessWidget {
  final List<ProductItem> products;
  final double itemSpacing;
  final double scaleFactor;
  final int? selectedIndex;
  final Function(int) onTap;

  const ResponsiveGridWithLayoutBuilder({
    super.key,
    required this.products,
    required this.itemSpacing,
    required this.scaleFactor,
    required this.selectedIndex,
    required this.onTap,
  });

  /// Menentukan jumlah kolom berdasarkan constraints dari parent
  int _getCrossAxisCountFromConstraints(double maxWidth) {
    if (maxWidth < 600) {
      return 2;
    } else if (maxWidth < 800) {
      return 3;
    } else {
      return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // constraints.maxWidth memberikan lebar maksimal yang tersedia
        final crossAxisCount = _getCrossAxisCountFromConstraints(
          constraints.maxWidth,
        );
        
        return GridView.builder(
          padding: EdgeInsets.all(itemSpacing),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: itemSpacing,
            mainAxisSpacing: itemSpacing,
            childAspectRatio: 0.85,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final isSelected = selectedIndex == index;
            
            return GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                transform: Matrix4.identity()
                  ..scale(
                    isSelected ? scaleFactor * 1.15 : scaleFactor,
                    isSelected ? scaleFactor * 1.15 : scaleFactor,
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
                              fontWeight: isSelected 
                                  ? FontWeight.bold 
                                  : FontWeight.w500,
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
          },
        );
      },
    );
  }
}

/// Model data untuk produk
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
