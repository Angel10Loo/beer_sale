import 'package:beer_sale/model/product.dart';
import 'package:beer_sale/model/sale.dart';
import 'package:beer_sale/providers/sale_provider.dart';
import 'package:beer_sale/shared/widgets/custom_button_widget.dart';
import 'package:beer_sale/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SalesScreen extends StatefulWidget {
  final Product product;
  const SalesScreen({super.key, required this.product});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  late Product product;
  late Sale saleModel;
  int count = 1;

  @override
  void initState() {
    super.initState();
    product = widget.product;
    saleModel = Sale.defaultSale().copyWith(salePrice: product.price.toInt());
  }

  void _updateSaleCount(int newCount) {
    if (newCount < 1) return; 
    if (newCount > product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[400],
          content: Text("Solo tienes ${product.stock} unidades de ${product.name}"),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      count = newCount;
      saleModel = saleModel.copyWith(salePrice: product.price.toInt() * count);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4B0082), Color(0xFF8A2BE2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 2 * 3.14159),
                    duration: const Duration(seconds: 4),
                    builder: (context, rotation, child) {
                      return Transform.rotate(angle: rotation, child: child);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        product.imageName,
                        height: 140,
                        width: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    product.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Quantity Selector & Total Price ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity controls
                      Row(
                        children: [
                          _CircleIconButton(
                            icon: Icons.remove,
                            color: Colors.deepPurple,
                            onTap: () => _updateSaleCount(count - 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              '$count',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          _CircleIconButton(
                            icon: Icons.add,
                            color: Colors.deepPurple,
                            onTap: () => _updateSaleCount(count + 1),
                          ),
                        ],
                      ),

                      // Total price display
                      Text(
                        '\$${(saleModel.salePrice).toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            // --- Action Button ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: CustomButton(
                label: 'Cobrar',
                onPressed: () async {
                  await confirmationDialog(
                    context: context,
                    title: '💸 Venta',
                    message: '¿Estás seguro de realizar esta venta?',
                    onConfirm: () async {
                      final dialogContext = await showLoadingDialog(context);
                      await context.read<SaleProvider>().handleSale(
                            product.id!,
                            count,
                            saleModel.salePrice,
                          );
                      Navigator.of(dialogContext).pop();

                      setState(() {
                        count = 1;
                        saleModel = saleModel.copyWith(
                          salePrice: product.price.toInt(),
                        );
                      });
                      showSuccessFullDialog(context, "Cobro realizado con éxito");
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      color: color,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
