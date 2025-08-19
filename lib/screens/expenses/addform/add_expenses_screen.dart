import 'package:beer_sale/model/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beer_sale/providers/expense_provider.dart';

class AddExpenseForm extends StatefulWidget {
  const AddExpenseForm({super.key});

  @override
  State<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      final title = _titleController.text;
      final amount = double.parse(_amountController.text);

      final newExpense = Expense(title: title, amount: amount);

      try {
        // Save to Firestore via provider
        final expenseProvider =
            Provider.of<ExpenseProvider>(context, listen: false);
        await expenseProvider.addExpense(newExpense);

          await expenseProvider.fetchExpenses();

        Navigator.pop(context); // Close the bottom sheet
      } catch (e) {
        // Show error message if needed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar gasto: $e')),
        );
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Titulo"),
              validator: (value) =>
                  value == null || value.isEmpty ? "Ingresa el título" : null,
            ),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: "Monto"),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value == null || value.isEmpty ? "Ingresa el monto" : null,
            ),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submit,
                    child: const Text("Agregar Gasto"),
                  ),
          ],
        ),
      ),
    );
  }
}
