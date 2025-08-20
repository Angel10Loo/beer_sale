// lib/widgets/product_list_widget.dart
import 'dart:math';
import 'package:beer_sale/model/product.dart';
import 'package:beer_sale/providers/product_provider.dart';
import 'package:beer_sale/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductListWidget extends StatefulWidget {
  const ProductListWidget({super.key});

  @override
  State<ProductListWidget> createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Decide number of columns depending on width.
  int _calculateColumns(double width) {
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1200) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products;
    final isLoading = productProvider.loading;

    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(strokeWidth: 6, color: Colors.deepPurple),
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, color: Colors.deepPurpleAccent, size: 80),
              const SizedBox(height: 20),
              const Text(
                "No hay Productos Agregados 😢",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = _calculateColumns(width);

        // If only 1 column -> present as a vertical list (full width cards)
        if (columns == 1) {
          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return _ProductCard(
                product: product,
                onEdit: () => _showEditDialog(context, product),
                onTap: () => _showProductDetails(context, product),
                isGrid: false,
                maxWidth: width - 32,
              );
            },
          );
        }

        // Grid layout for 2+ columns
        final crossAxisSpacing = 18.0;
        final mainAxisSpacing = 18.0;
        final usableWidth = width - 32 - (crossAxisSpacing * (columns - 1));
        final tileWidth = usableWidth / columns;
        final childAspectRatio = (tileWidth / (tileWidth * 0.7)).clamp(0.7, 1.6);

        return GridView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _ProductCard(
              product: product,
              onEdit: () => _showEditDialog(context, product),
              onTap: () => _showProductDetails(context, product),
              isGrid: true,
              maxWidth: tileWidth,
            );
          },
        );
      }),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onTap;
  final bool isGrid;
  final double maxWidth;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onTap,
    required this.isGrid,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Responsive sizes
    final imageSize = (maxWidth * 0.28).clamp(64.0, 160.0);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: Colors.deepPurple.shade700,
      letterSpacing: 0.3,
      fontSize: isGrid ? 16 : 18,
    );

    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: Colors.deepPurple.shade300,
      fontSize: isGrid ? 12 : 13,
    );

    Widget content = Row(
      children: [
        Hero(
          tag: 'product-image-${product.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              product.imageName,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: titleStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                children: [
                  _StatusChip(
                    icon: Icons.inventory_2,
                    label: 'Disponible: ${product.stock}',
                    color: product.stock < 10 ? Colors.red : Colors.green,
                  ),
                  _StatusChip(
                    icon: Icons.price_check,
                    label: '\$${product.price}',
                    color: Colors.deepPurple,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Agregado: ${_formatDate(product.createdDate)}',
                style: subtitleStyle,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.shade600.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.shade400.withOpacity(0.28),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );

    // For very narrow cards (mobile list), we might want vertical layout
    if (!isGrid && maxWidth < 360) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Hero(
              tag: 'product-image-${product.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(product.imageName,
                    width: imageSize, height: imageSize, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(product.name, style: titleStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _StatusChip(
                icon: Icons.inventory_2,
                label: 'Disponible: ${product.stock}',
                color: product.stock < 10 ? Colors.red : Colors.green,
              ),
              _StatusChip(
                icon: Icons.price_check,
                label: '\$${product.price}',
                color: Colors.deepPurple,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Agregado: ${_formatDate(product.createdDate)}',
              style: subtitleStyle),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurple.shade600.withOpacity(0.9),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      );
    }

    return Card(
      elevation: 6,
      shadowColor: Colors.deepPurple.withOpacity(0.18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.deepPurple.withOpacity(0.08),
        highlightColor: Colors.deepPurple.withOpacity(0.02),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: content,
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: color.withOpacity(0.12),
      avatar: CircleAvatar(
        backgroundColor: color.withOpacity(0.24),
        child: Icon(icon, color: color, size: 16),
      ),
      label: Text(
        label,
        style: TextStyle(
          color: color.darken(0.18),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}

void _showProductDetails(BuildContext context, Product product) {
  final media = MediaQuery.of(context);
  final maxDialogWidth = min(media.size.width * 0.9, 620.0);

  showDialog(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxDialogWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Hero(
              tag: 'product-image-${product.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(product.imageName, height: 180, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 18),
            Text(product.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.deepPurple.shade700,
                    ),
                textAlign: TextAlign.center),
            const SizedBox(height: 14),
            _DetailRow(icon: Icons.price_check, label: 'Precio', value: '\$${product.price.toStringAsFixed(2)}'),
            _DetailRow(icon: Icons.inventory_2, label: 'Disponible', value: product.stock.toString()),
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'Fecha',
              value:
                  '${product.createdDate.day.toString().padLeft(2, '0')}/${product.createdDate.month.toString().padLeft(2, '0')}/${product.createdDate.year}',
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
              ),
            )
          ]),
        ),
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final color = Colors.deepPurple.shade700;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Text('$label:', style: TextStyle(fontWeight: FontWeight.w700, color: color)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(color: color.withOpacity(0.95)), overflow: TextOverflow.ellipsis),
          )
        ],
      ),
    );
  }
}

void _showEditDialog(BuildContext context, Product product) {
  final nameController = TextEditingController(text: product.name);
  final stockController = TextEditingController(text: product.stock.toString());
  final priceController = TextEditingController(text: product.price.toString());
  final formKey = GlobalKey<FormState>();
  final media = MediaQuery.of(context);
  final maxDialogWidth = min(media.size.width * 0.9, 620.0);

  showDialog(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxDialogWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Editar Producto',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.deepPurple.shade700,
                      )),
              const SizedBox(height: 18),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.drive_file_rename_outline),
                ),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: stockController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final v = int.tryParse(value ?? '');
                  if (v == null || v < 0) return 'Ingrese cantidad válida';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.price_check),
                ),
             
                validator: (value) {
                  final v = int.parse(value ?? '');
                  if (v < 0) return 'Ingrese precio válido';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar', style: TextStyle(color: Colors.deepPurple.shade400)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final updatedProduct = product.copyWith(
                        id: product.id,
                        name: nameController.text.trim(),
                        stock: int.parse(stockController.text),
                        price: int.parse(priceController.text),
                      );
                      context.read<ProductProvider>().updateProduct(product.id!, updatedProduct);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                ),
              ])
            ]),
          ),
        ),
      ),
    ),
  );
}

/// Helper extension to darken colors a bit for text on chips
extension ColorUtils on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
