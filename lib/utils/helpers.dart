import 'package:flutter/material.dart';
import 'dart:async';



   Future<void> confirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String cancelText = 'Cancelar',
    String confirmText = 'Confirmar',
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 20.0),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                cancelText,
                style: const TextStyle(color: Colors.red, fontSize: 20.0),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onConfirm(); // Call the external function
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                confirmText,
                style: const TextStyle(fontSize: 20.0,color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
  

Future<BuildContext> showLoadingDialog(BuildContext context) async {
  final Completer<BuildContext> completer = Completer();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      if (!completer.isCompleted) {
        completer.complete(dialogContext); 
      }
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );

  return completer.future;
}

void showSuccessFullDialog(BuildContext context,String content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 40.0),
            SizedBox(width: 8),
            Text('Exito!'),
          ],
        ),
        content:  Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
class Helper {
    static String formatNumberWithCommas(String number) {
    String formattedNumber = number;
    final RegExp regExp = RegExp(r'\B(?=(\d{3})+(?!\d))');

    return formattedNumber.replaceAllMapped(regExp, (Match match) => ',');
  }

   static String removeTrailingZeros(double value) {
    String stringValue = value.toString();
    if (stringValue.contains('.')) {
      // Remove trailing zeros after the decimal point
      stringValue = stringValue.replaceAll(RegExp(r"0*$"), "");
      // Remove the decimal point if no decimal part remains
      if (stringValue.endsWith('.')) {
        stringValue = stringValue.substring(0, stringValue.length - 1);
      }
    }
    return stringValue;
  }

  String formatDate(String dateString) {
  final date = DateTime.parse(dateString).toLocal();
  // Format as: Monday, Aug 9, 2025 (simple manual)
  final weekdays = [
    'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo'
  ];
  final months = [
    'Enero', 'Feb', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Decembre'
  ];

  final dayName = weekdays[date.weekday - 1];
  final monthName = months[date.month - 1];
  final day = date.day;
  final year = date.year;

  return '$dayName, $day $monthName, $year';
}

}