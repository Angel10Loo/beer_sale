import 'package:flutter/services.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final int decimalDigits;

  CurrencyInputFormatter({this.decimalDigits = 2});
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    int selectionIndex = newValue.selection.baseOffset;
    final StringBuffer newText = StringBuffer();
    int count = 0;

    for (int i = 0; i < newValue.text.length; i++) {
      if (newValue.text[i] == ',' || newValue.text[i] == '.') {
        continue;
      }

      if (count == decimalDigits) break;

      newText.write(newValue.text[i]);
      count++;
    }

    // Handle decimal digits
    if (count == decimalDigits && selectionIndex <= newText.length) {
      newText.write('.');
      newText
          .write(newValue.text.substring(newValue.text.length - decimalDigits));
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(
        offset: newText.length,
      ),
    );
  }
}
