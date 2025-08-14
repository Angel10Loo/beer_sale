import 'package:beer_sale/providers/sale_provider.dart';
import 'package:beer_sale/screens/clossing/closing_screen.dart';
import 'package:beer_sale/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerformClosingScreen extends StatelessWidget {
  const PerformClosingScreen({super.key});

  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day.toString().padLeft(2,'0')}-${date.month.toString().padLeft(2,'0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final closingProvider = Provider.of<SaleProvider>(context, listen: false);

    return Scaffold(
         appBar: AppBar(
        title: const Text('Cierre De Cuadre',style: TextStyle(color: Colors.white,fontSize: 23.0),),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(213, 9, 9, 9),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.lock),
              label: const Text('Generar Cierre de Cuadre'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Confirmar Cierre ?'),
                    content: const Text('Estas seguro que deseas  generar el cierre de cuadre de hoy ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Confirmar'),
                      ),
                    ],
                  ),
                );

                if (confirmed ?? false) {
                  final closingId = await closingProvider.performDailyClosing();

                  if (closingId.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClosingDetailsScreen(closingId: closingId),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No sales found for today')),
                    );
                  }
                }
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('closings')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay Cuadres aun'));
                }

                final docs = snapshot.data!.docs;

                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final closing = docs[index].data() as Map<String, dynamic>;
                    final closingId = docs[index].id;
                    final dateTimestamp = closing['date'] as String?;
                    final totalSales = closing['total'] ?? closing['total'] ?? 0.0;

                    final formattedDate = dateTimestamp != null
                        ? formatDate(Timestamp.fromDate(DateTime.parse(dateTimestamp)))
                        : 'Unknown date';

                    return ListTile(
                      title: Text('Fecha: $formattedDate'),
                      subtitle: Text('Monto Total: \$${Helper.formatNumberWithCommas(Helper.removeTrailingZeros(totalSales))}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClosingDetailsScreen(closingId: closingId),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
