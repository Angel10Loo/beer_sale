import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final int price;
  final String name;
  final int quantity;
  final String image;

  const ProductCard({
    super.key,
    required this.price,
    required this.name,
    required this.quantity,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1, // Adjust based on your layout
              child: Image.asset(
                image,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$$price',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
              _buildChip(
                null,
              name,
              Colors.blue[100]!,
              Colors.blue[800]!,
            ),
            _buildChip(
              quantity,
              'Disponible: $quantity',
              Colors.green[100]!,
              Colors.green[800]!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(int? stock,String text, Color bgColor, Color textColor) {

    if(stock != null && stock < 10){
        bgColor =  Colors.red[100]!;
        textColor = Colors.red[800]!;
    }
      
    return Chip(
      backgroundColor: bgColor,
      label: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
