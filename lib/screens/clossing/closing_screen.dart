import 'package:beer_sale/model/expense.dart';
import 'package:beer_sale/providers/expense_provider.dart';
import 'package:beer_sale/providers/product_provider.dart';
import 'package:beer_sale/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class ClosingDetailsScreen extends StatelessWidget {
  final String closingId;

  const ClosingDetailsScreen({super.key, required this.closingId});

  Future<Map<String, dynamic>> getClosingData() async {
    final doc = await FirebaseFirestore.instance
        .collection('closings')
        .doc(closingId)
        .get();

    return doc.data() ?? {};
  }

  String formatDate(String dateString) {
    final date = DateTime.parse(dateString).toLocal();
    // Format as: Monday, Aug 9, 2025 (simple manual)
    final weekdays = [
      'Lunes',
      'Martes',
      'Miercoles',
      'Jueves',
      'Viernes',
      'Sabado',
      'Domingo'
    ];
    final months = [
      'Enero',
      'Feb',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Decembre'
    ];

    final dayName = weekdays[date.weekday - 1];
    final monthName = months[date.month - 1];
    final day = date.day;
    final year = date.year;

    return '$dayName, $day $monthName, $year';
  }

  String formatCurrency(double value) {
    // Simple USD format with 2 decimals
    return '\$' + value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Colors.deepPurple;
    final provider = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detalle Del Cierre',
          style: TextStyle(color: Colors.white, fontSize: 23.0),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(213, 9, 9, 9),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getClosingData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No closing data found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final closing = snapshot.data!;
          final productDetails =
              Map<String, dynamic>.from(closing['productDetails'] ?? {});

          final expensesDetails = (closing['expensesDetails'] as List<dynamic>?)
                  ?.map((e) => Expense.fromMap(Map<String, dynamic>.from(e)))
                  .toList() ??
              [];

          final formattedDate = closing.containsKey('date')
              ? formatDate(closing['date'])
              : 'Unknown Date';

          final salesCount = closing['totalSales'] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  color: primaryColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                  shadowColor: primaryColor.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Fecha",
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Monto total",
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Helper.formatNumberWithCommas(
                              Helper.removeTrailingZeros(closing['total'])),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Total de venta",
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                       
                        const SizedBox(height: 4),
                        Text(
                          salesCount.toString(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                       if (expensesDetails.isNotEmpty) ...[
  const SizedBox(height: 16),
  Text(
    "Total de Gastos",
    style: theme.textTheme.labelMedium?.copyWith(
      color: primaryColor,
      fontWeight: FontWeight.bold,
    ),
  ),
  const SizedBox(height: 4),
  Text(
    Helper.formatNumberWithCommas(
      Helper.removeTrailingZeros(closing['totalExpenses']),
    ),
    style: theme.textTheme.titleLarge?.copyWith(
      color: Colors.black87,
    ),
  ),
],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  "Ventas",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),

                const SizedBox(height: 14),

                productDetails.isEmpty
                    ? const Center(
                        child: Text(
                          "No products sold today.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: productDetails.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final productId =
                              productDetails.keys.elementAt(index);
                          final product = productDetails[productId];
                          final productName =
                              product['productName'] ?? 'Unknown';
                          final quantity = product['quantitySold'] ?? 0;

                          final imageUrl =
                              product['imageUrl'] ?? product['imagePath'];

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(26),
                                child: imageUrl != null && imageUrl.isNotEmpty
                                    ? Image.asset(
                                        imageUrl,
                                        width: 52,
                                        height: 52,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          // fallback icon if image fails to load
                                          return CircleAvatar(
                                            radius: 26,
                                            backgroundColor:
                                                primaryColor.withOpacity(0.2),
                                            child: const Icon(
                                              Icons.broken_image,
                                              color: primaryColor,
                                              size: 28,
                                            ),
                                          );
                                        },
                                      )
                                    : CircleAvatar(
                                        radius: 26,
                                        backgroundColor:
                                            primaryColor.withOpacity(0.2),
                                        child: const Icon(
                                          Icons.shopping_bag_outlined,
                                          color: primaryColor,
                                          size: 28,
                                        ),
                                      ),
                              ),
                              title: Text(
                                productName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Cantidad: $quantity',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor.shade700,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 30),

                /// ---- EXPENSES ----
                if(expensesDetails.isNotEmpty) ...[
                Text("Gastos",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    )),
                const SizedBox(height: 14),

                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: expensesDetails.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Colors.grey),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading:
                          const Icon(Icons.money_off, color: Colors.redAccent),
                      title: Text(expensesDetails[index].title ?? 'Unnamed'),
                      trailing: Text(
                        "\$${expensesDetails[index].amount ?? 0}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent),
                      ),
                    );
                  },
                )
                ]
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.grey.shade100,
    );
  }
}
