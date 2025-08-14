import 'package:beer_sale/model/open_account.dart';
import 'package:beer_sale/providers/open_account_provider.dart';
import 'package:beer_sale/providers/sale_provider.dart';
import 'package:beer_sale/screens/sale/sale_open_account.dart';
import 'package:beer_sale/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BorrowScreen extends StatefulWidget {
  const BorrowScreen({super.key});

  @override
  State<BorrowScreen> createState() => _BorrowScreenState();
}

class _BorrowScreenState extends State<BorrowScreen> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch accounts on load
    Future.microtask(() =>
        Provider.of<OpenAccountProvider>(context, listen: false).fetchAllAccounts());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final openAccounts = context.watch<OpenAccountProvider>().openAccounts;
    final isEmpty = context.watch<SaleProvider>().tempOpenSaleAccounts.isEmpty;
    final isLoading = context.watch<SaleProvider>().loading;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(213, 9, 9, 9),
        title: const Text(
          'A crédito',
          style: TextStyle(color: Colors.white, fontSize: 23),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : openAccounts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      Icon(Icons.info_outline, size: 60, color: Colors.black54),
                      SizedBox(height: 16),
                      Text(
                        "No hay cuentas abiertas aún",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  itemCount: openAccounts.length,
                  itemBuilder: (context, index) {
                    final account = openAccounts[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        title: Text(
                          account.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent, size: 30),
                          tooltip: 'Eliminar cliente',
                          onPressed: () => _deleteAccount(context, account.id!, isEmpty),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SaleOpenAccount(
                              name: account.name,
                              customerId: account.id!,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(213, 9, 9, 9),
        onPressed: () => _showAddAccountModal(context),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
        tooltip: 'Agregar nueva cuenta',
        elevation: 6,
        highlightElevation: 12,
      ),
    );
  }

  void _showAddAccountModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nueva Cuenta',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(213, 9, 9, 9),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final name = _nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, ingrese un nombre')),
                      );
                      return;
                    }

                    final newAccount = OpenAccount(name: name);
                    context.read<OpenAccountProvider>().addAccount(newAccount);
                    Navigator.pop(context);
                    _clearInputs();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cuenta creada con éxito')),
                    );
                  },
                  child: const Text(
                    "Guardar",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context, String accountId, bool isEmpty) async {
    if (!isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.black87,
          content: Text(
            "Este cliente tiene cuenta pendiente. Debe saldarla o eliminarla primero.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    final confirm = await confirmationDialog(
      context: context,
      title: "Eliminar cuenta",
      message: "¿Seguro que deseas eliminar este cliente?",
      onConfirm: () async {
        final loadingContext = await showLoadingDialog(context);
        await context.read<OpenAccountProvider>().deleteOpenAccount(accountId);
        Navigator.of(loadingContext).pop();
     
      },
    );

   
  }

  void _clearInputs() {
    _nameController.clear();
  }
}
