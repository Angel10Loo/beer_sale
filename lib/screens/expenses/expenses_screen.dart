import 'package:beer_sale/model/expense.dart';
import 'package:beer_sale/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpensesTrackerScreen extends StatefulWidget {
  const ExpensesTrackerScreen({super.key});

  @override
  State<ExpensesTrackerScreen> createState() => _ExpensesTrackerScreenState();
}

class _ExpensesTrackerScreenState extends State<ExpensesTrackerScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      await provider.addExpense(Expense(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
      ));
      _titleController.clear();
      _amountController.clear();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provide the provider **once at top** so the same instance is used
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider()..fetchExpenses(),
      child: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, _) {
          final expenses = expenseProvider.expenses;
          final total = expenses.fold<double>(0, (sum, item) => sum + item.amount);

          return Scaffold(
            appBar: AppBar(title: const Text("Gastos")),
            body: Column(
              children: [
                _buildBalanceCard(total),
                Expanded(
                  child: expenseProvider.loading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildExpensesList(expenses),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
  onPressed: () {
    // capturamos la instancia correcta aquí, en el contexto del screen
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Titulo"),
                  validator: (value) => value == null || value.isEmpty ? "Titulo" : null,
                ),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: "Monto"),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? "Monto" : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // usamos la instancia capturada (provider) — NO Provider.of(sheetContext)
                      await provider.addExpense(Expense(
                        title: _titleController.text,
                        amount: double.parse(_amountController.text),
                      ));
                      _titleController.clear();
                      _amountController.clear();
                      Navigator.pop(sheetContext); // cierra el sheet
                    }
                  },
                  child: const Text("Agregar Gasto"),
                ),
              ],
            ),
          ),
        );
      },
    );
  },
  icon: const Icon(Icons.add),
  label: const Text("Agregar Gasto"),
  backgroundColor: Colors.white,
),

          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(double total) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total de Gastos", style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
Widget _buildExpensesList(List<Expense> expenses) {
  final provider = Provider.of<ExpenseProvider>(context, listen: false);

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: expenses.length,
    itemBuilder: (context, index) {
      final expense = expenses[index];
      final key = Key(expense.id ?? 'expense_$index');

      return Dismissible(
        key: key,
        direction: DismissDirection.endToStart,
        background: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_forever, color: Colors.white),
        ),
        onDismissed: (direction) async {
          // keep a local copy for undo
          final removedExpense = expense;

          // call provider to delete (optimistic inside provider)
          try {
            await provider.deleteExpense(removedExpense);
            // show undo snack
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gasto eliminado'),
                action: SnackBarAction(
                  label: 'DESHACER',
                  onPressed: () async {
                    // re-add the expense (this will create a new doc if needed)
                    try {
                      await provider.addExpense(removedExpense);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No se pudo restaurar')),
                      );
                    }
                  },
                ),
                duration: const Duration(seconds: 4),
              ),
            );
          } catch (e) {
            // if provider rolled back on error it should reinsert; otherwise show error
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error al eliminar, inténtalo de nuevo')),
            );
          }
        },
        confirmDismiss: (direction) async {
          // optional: show a confirm dialog before deleting. Return true to allow.
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Confirmar'),
              content: const Text('¿Eliminar este gasto?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Eliminar')),
              ],
            ),
          );
          return confirmed ?? false;
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey,
                child: Icon(Icons.attach_money, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("${expense.date.day}/${expense.date.month}/${expense.date.year}", style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Text("- \$${expense.amount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    },
  );
}

}
