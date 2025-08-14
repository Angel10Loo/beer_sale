// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:beer_sale/model/product.dart';
import 'package:beer_sale/model/temp_sale_open_account.dart';
import 'package:beer_sale/providers/open_account_provider.dart';
import 'package:beer_sale/providers/product_provider.dart';
import 'package:beer_sale/providers/sale_provider.dart';
import 'package:beer_sale/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:provider/provider.dart';

class SaleOpenAccount extends StatefulWidget {
  final String name;
  final String customerId;

  const SaleOpenAccount({super.key, required this.name, required this.customerId});

  @override
  State<SaleOpenAccount> createState() => _SaleOpenAccountState();
}

class _SaleOpenAccountState extends State<SaleOpenAccount> {
  Product? selectedProduct;
  final controller = MultiSelectController<Product>();
  late TextEditingController _priceController = TextEditingController();
  int count = 1;

  TempOpenSaleAccount tempOpenSaleAccount = TempOpenSaleAccount(
    customerId: '',
    productId: '',
    salePrice: 0,
    quantitySold: 0,
    createdDate: DateTime.now(),
  );

  String _name = '';

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    Future.microtask(() => Provider.of<SaleProvider>(context, listen: false)
        .fetchSalesByCustomerId(widget.customerId));
  }

  double _getTotalSaleAmount() {
    final sales = context.read<SaleProvider>().tempOpenSaleAccounts;
    return sales.fold(0.0, (sum, item) => sum + item.salePrice);
  }

  @override
  Widget build(BuildContext context) {
    _priceInput(MediaQuery.of(context).size.width, _priceController);
    final size = MediaQuery.of(context).size;
    final w = size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(213, 9, 9, 9),
        title: Text(_name, style: const TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, bc) {
            if (bc.maxWidth > 600) {
              return Row(
                children: [
                  Expanded(flex: 4, child: _buildForm(w, context)),
                  Expanded(flex: 6, child: _buildSaleList()),
                ],
              );
            }
            return Column(
              children: [
                Expanded(flex: 4, child: _buildForm(w, context)),
                Expanded(flex: 6, child: _buildSaleList()),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.025),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(onTap: _addToTemp, child: addButtom(context)),
                GestureDetector(onTap: _onPay, child: payButtom(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(double w, BuildContext context) {
    final products = context.watch<ProductProvider>().products;
    final dropdownItems = products
        .map((p) => DropdownItem<Product>(label: p.name, value: p))
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(w * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MultiDropdown<Product>(
            items: dropdownItems,
            controller: controller,
            singleSelect: true,
            searchEnabled: true,
            onSelectionChange: (sel) {
              setState(() {
                if (sel.isEmpty) {
                  selectedProduct = null;
                  count = 1;
                  tempOpenSaleAccount = tempOpenSaleAccount.copyWith(salePrice: 0);
                } else {
                  selectedProduct = sel.first;
                  count = 1;
                  tempOpenSaleAccount = tempOpenSaleAccount.copyWith(
                    salePrice: selectedProduct!.price,
                  );
                  _priceController = TextEditingController(
                    text: tempOpenSaleAccount.salePrice.toStringAsFixed(0),
                  );
                }
              });
            },
           fieldDecoration: FieldDecoration(
  hintText: 'Selecciona un producto',
  prefixIcon: const Icon(Icons.production_quantity_limits),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),

),
          ),
          SizedBox(height: w * 0.06),
          Text(
            'Cantidad',
            style: TextStyle(
              fontSize: w * 0.065,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: w * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                iconSize: w * 0.09,
                onPressed: _decrement,
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                splashRadius: 28,
                tooltip: 'Disminuir cantidad',
              ),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: w * 0.07,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                iconSize: w * 0.09,
                onPressed: _increment,
                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                splashRadius: 28,
                tooltip: 'Aumentar cantidad',
              ),
            ],
          ),
          SizedBox(height: w * 0.07),
          _priceInput(w, _priceController),
        ],
      ),
    );
  }

  Widget _priceInput(double w, TextEditingController controller) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: w * 0.025, horizontal: w * 0.05),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 6,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.monetization_on, color: Colors.green.shade700, size: w * 0.07),
          SizedBox(width: w * 0.03),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Ingresa el precio',
                hintStyle: TextStyle(color: Colors.green),
              ),
              style: TextStyle(
                fontSize: w * 0.065,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container payButtom(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      width: w * 0.42,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 50, 10),
            Colors.black,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monetization_on,
              color: Colors.lightGreenAccent,
            ),
            SizedBox(width: 8.0),
            Text(
              'Cobro General',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.lightGreenAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container addButtom(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      width: w * 0.42,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(212, 70, 20, 20),
            Color.fromARGB(214, 30, 0, 0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'Agregar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.9,
          ),
        ),
      ),
    );
  }

  Widget _buildSaleList() {
    final sales = context.watch<SaleProvider>().tempOpenSaleAccounts;
    final products = context.watch<ProductProvider>().products;

    if (sales.isEmpty) {
      return Center(
        child: Text(
          'No hay Productos Agregados',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: sales.length,
            itemBuilder: (context, i) {
              final sale = sales[i];
              final prod = products.firstWhere((p) => p.id == sale.productId);
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 6,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(prod.imageName,
                        width: 55, height: 55, fit: BoxFit.cover),
                  ),
                  title: Text(prod.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17)),
                  subtitle: Text(
                    'Cantidad: ${sale.quantitySold}    Total: \$${sale.salePrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: const Size(0, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.monetization_on, size: 20),
                        label: const Text("Cobrar",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        onPressed: () => _individualPayment(sale),
                      ),
                      const SizedBox(width: 6),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: const Size(0, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: Colors.red.shade700,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.remove_circle, size: 20),
                        label: const Text("Eliminar",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        onPressed: () => _removeTemp(sale),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 16, right: 20, top: 12, bottom: 12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Total: ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text('\$${_getTotalSaleAmount().toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700)),
            ],
          ),
        ),
      ],
    );
  }

  void _increment() {
    if (selectedProduct == null) return;
    setState(() {
      count++;
      tempOpenSaleAccount = tempOpenSaleAccount.copyWith(
        salePrice: tempOpenSaleAccount.salePrice + selectedProduct!.price,
      );
      _priceController = TextEditingController(
        text: tempOpenSaleAccount.salePrice.toStringAsFixed(0),
      );
    });
  }

  void _decrement() {
    if (count <= 1 || selectedProduct == null) return;
    setState(() {
      count--;
      tempOpenSaleAccount = tempOpenSaleAccount.copyWith(
        salePrice: tempOpenSaleAccount.salePrice - selectedProduct!.price,
      );
      _priceController = TextEditingController(
        text: tempOpenSaleAccount.salePrice.toStringAsFixed(0),
      );
    });
  }

  Future<void> _addToTemp() async {
    if (selectedProduct == null) {
      validation(context, 'Selecciona primero un producto');
      return;
    }
    if (selectedProduct!.stock < count) {
      validation(context, 'Stock insuficiente');
      return;
    }
    final ctx = await showLoadingDialog(context);
    tempOpenSaleAccount = tempOpenSaleAccount.copyWith(
      customerId: widget.customerId,
      productId: selectedProduct!.id,
      quantitySold: count,
      salePrice: int.tryParse(_priceController.text),
    );
    await context.read<SaleProvider>().addTempSaleOpenAccount(tempOpenSaleAccount);
    Navigator.of(ctx).pop();
    setState(() {
      selectedProduct =
          selectedProduct!.copyWith(stock: selectedProduct!.stock - count);
      count = 1;
      tempOpenSaleAccount = tempOpenSaleAccount.copyWith(salePrice: selectedProduct!.price);
      _priceController.text = selectedProduct!.price.toString(); 
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
  FocusScope.of(context).unfocus();
});
  }

  Future<void> _onPay() async {
    final sales = context.read<SaleProvider>().tempOpenSaleAccounts;
    if (sales.isEmpty) {
      validation(context, 'No hay cuenta pendiente');
      return;
    }
    await confirmationDialog(
      context: context,
      title: '💸 Cobrar',
      message: '¿Estás seguro que deseas realizar el cobro?',
      onConfirm: () {
        context.read<SaleProvider>().handleSaleOpenAccount(sales);
        context.read<OpenAccountProvider>().deleteOpenAccount(widget.customerId);
        showSuccessFullDialog(context, 'Cobro exitoso');
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> _removeTemp(TempOpenSaleAccount sale) async {
    await context.read<SaleProvider>().deleteTempOpenSaleAccountsByIds([sale.id.toString()]);
    final prodProv = context.read<ProductProvider>();
    final prod = prodProv.products.firstWhere((p) => p.id == sale.productId);
    await prodProv.updateProduct(prod.id!, prod.copyWith(stock: prod.stock + sale.quantitySold));
  }

  void validation(BuildContext context, String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(content), backgroundColor: Colors.red[200]),
    );
  }

  Future<void> _individualPayment(TempOpenSaleAccount sale) async {
    await confirmationDialog(
      context: context,
      title: '💸 Cobrar',
      message: '¿Estás seguro que deseas realizar el cobro?',
      onConfirm: () async {
        await context.read<SaleProvider>().handleSale(sale.productId, sale.quantitySold, sale.salePrice);
        await context.read<SaleProvider>().deleteTempOpenSaleAccountsByIds([sale.id.toString()]);
        await _removeTemp(sale);
        showSuccessFullDialog(context, 'Cobro exitoso');
      },
    );
  }
}
