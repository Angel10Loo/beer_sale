import 'package:beer_sale/model/sale.dart';
import 'package:beer_sale/providers/sale_provider.dart';
import 'package:beer_sale/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RevenueScreen extends StatelessWidget {
   RevenueScreen({super.key});
 
 @override
  Widget build(BuildContext context) {
      final saleProvider = Provider.of<SaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ganacias',style: TextStyle(color: Colors.white,fontSize: 23.0)),
        centerTitle: true,
         backgroundColor: const Color.fromARGB(213, 9, 9, 9),
      ),
      body: StreamBuilder<List<Sale>>(
        stream: saleProvider.salesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No sales data available'));
          }

          final sales = snapshot.data!;

          // Group revenue and investment by productName
          final revenueMap = <String, double>{};
          final investMap = <String, double>{};
          final quantitySoldMap = <String, int>{};
          final productImgdMap = <String, String>{};
          
         double totalSalesRevenue = 0;
         double totalCapital = 0;
          for (var sale in sales) {

            final investment = sale.purchasePrice * sale.quantitySold;
            final revenue =  sale.salePrice  - investment;

            
            totalSalesRevenue += revenue;
            totalCapital += investment;

            revenueMap[sale.productName] = (revenueMap[sale.productName] ?? 0) + revenue;
               if (!productImgdMap.containsKey(sale.productName)){
            productImgdMap[sale.productName] = (productImgdMap[sale.productName] ?? '')  + sale.imagePath!;
               }
            investMap[sale.productName] = (investMap[sale.productName] ?? 0) + investment;
            quantitySoldMap[sale.productName] = (quantitySoldMap[sale.productName] ?? 0) + sale.quantitySold;

          }

         final productNames = revenueMap.keys.toList();
          final revenues = productNames.map((p) => revenueMap[p]!).toList();
          final investments = productNames.map((p) => investMap[p]!).toList();
          final quantitySold = productNames.map((p) => quantitySoldMap[p]!).toList();
          final productImg = productNames.map((p) => productImgdMap[p]!).toList();




      
      
     return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children:[
             Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryColumn(
                          label: 'Ganancia ',
                          value: '\$${Helper.formatNumberWithCommas(Helper.removeTrailingZeros(totalSalesRevenue))}',
                          color: Colors.green,
                        ),
                           _buildSummaryColumn(
                          label: 'Capital ',
                          value: '\$${Helper.formatNumberWithCommas(Helper.removeTrailingZeros(totalCapital))}',
                          color: Colors.blue,
                        ),
          ])
                  )
             ),
            Expanded(
              child: ListView.builder(
              itemCount: productNames.length,
              itemBuilder: (context, index) {
              
                        
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Left Section: Product Icon or Placeholder
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(productImg[index])
                        ),
                        const SizedBox(width: 16),
                        
                        // Middle Section: Product Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productNames[index],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Vendida: ',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${quantitySold[index]} unidad',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'capital: ',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '\$${Helper.formatNumberWithCommas(Helper.removeTrailingZeros(investments[index]))}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Right Section: Revenue
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Ganancia',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                               '\$${Helper.formatNumberWithCommas(Helper.removeTrailingZeros(revenues[index]))}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
                        ),
            ),
          ]
        ),

      );
  }),
      backgroundColor: Colors.grey[100],
    );
  }
   Widget _buildSummaryColumn({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}