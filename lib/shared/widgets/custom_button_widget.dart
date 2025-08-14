import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 27, 19, 19), // Button background color
        padding:
            const EdgeInsets.symmetric(vertical: 16), // Adjust button height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              size: 30.0,
              Icons.monetization_on,
              color: Colors.green,
            ),
           const SizedBox(width: 10.0),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white, // Text color
                fontSize: 24,
                fontWeight: FontWeight.bold, // Text style
                letterSpacing: 1.5, // Spacing between letters
              ),
            ),
          ],
        ),
      ),
    );
  }
}
