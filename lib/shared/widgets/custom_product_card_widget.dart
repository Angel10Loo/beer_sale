import 'package:flutter/material.dart';

class CustomProductCard extends StatelessWidget {
  final String price;
  final String title;
  final String quantity;
  final String imagePath;
  final VoidCallback? onTap;

  const CustomProductCard({
    super.key,
    required this.price,
    required this.title,
    this.quantity = '',
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.2,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(213, 9, 9, 9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: quantity.isNotEmpty
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        if (quantity.isNotEmpty)
                          Text(
                            quantity,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.width * -0.2,
            right: -35,
            child: SizedBox(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: 150,
                width: 150,
              ),
            ),
          ),
        ],
      ),
    );
  }
}