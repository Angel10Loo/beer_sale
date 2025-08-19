import 'dart:io';

import 'package:beer_sale/model/product.dart';
import 'package:beer_sale/providers/product_provider.dart';
import 'package:beer_sale/shared/product_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});


  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
   final List<String> images = [
     'assets/images/GORRA.webp',
     'assets/images/gorra_blanca.webp',
     'assets/images/vitoria.png',
     'assets/images/vitoriaagua.webp',


  ];
 int? _selectedImageIndex;
    final _stockController = TextEditingController();
  final _priceController = TextEditingController();
  final _purchasePriceController = TextEditingController();

  final _nameController = TextEditingController();
 
@override
  void initState() {
    super.initState();
     Future.microtask(() =>
      Provider.of<ProductProvider>(context, listen: false).fetchProducts());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar al inventario',style: TextStyle(color: Colors.white,fontSize: 23.0),),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(213, 9, 9, 9),
      ),
         body:  Padding(
        padding: const  EdgeInsets.all(10.0),
        child: ProductListWidget(),
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(213, 9, 9, 9),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: () {
            _showDetailsModal(context); // Close the modal
          },
          icon: const Icon(Icons.add, color: Colors.white, size: 40),
        ),
      ),
    );
  }
  
  
 
 void _clearInputs() {
    _stockController.clear();
    _priceController.clear();
    _purchasePriceController.clear();
    _nameController.clear();
    _selectedImageIndex = null;
  }
  void _showDetailsModal(BuildContext context) {


  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Horizontal Image List
                  SizedBox(
  height: 100,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: images.length + 1, // One extra for the upload button
    itemBuilder: (context, index) {
      if (index < images.length) {
        // Image item
        return GestureDetector(
          onTap: () {
            setModalState(() {
              _selectedImageIndex = index;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedImageIndex == index
                    ? Colors.blue
                    : Colors.transparent,
                width: 3,
              ),
              image: DecorationImage(
                image: images[index].startsWith('http')
                    ? NetworkImage(images[index])
                    : AssetImage(images[index]) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      } else {
        // Upload button as last item
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: IconButton(
            icon: Icon(Icons.upload_file, color: Colors.blue),
            onPressed: () async {
            },
          ),
        );
      }
    },
  ),
),
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              const SizedBox(height: 16),

                   TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

                  TextField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: "Cantidad",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
             
              
              const SizedBox(height: 16),
                TextField(
                controller: _purchasePriceController,
                decoration: const InputDecoration(
                  labelText: "Precio Compra",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: "Precio Venta",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (
                        _nameController.text.isNotEmpty &&
                        _stockController.text.isNotEmpty &&
                        _priceController.text.isNotEmpty &&
                        _purchasePriceController.text.isNotEmpty) {
                      final newProduct = Product(
                        name: _nameController.text,
                        stock: int.parse(_stockController.text),
                        imageName: _selectedImageIndex != null ? images[_selectedImageIndex!] : 'assets/images/defaultImg.png',
                        purchasePrice: int.parse(_purchasePriceController.text),
                        price: int.parse(_priceController.text),
                        createdDate: DateTime.now(),
                      );
                      context.read<ProductProvider>().addProduct(newProduct);
                      Navigator.pop(context);
                      _clearInputs();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(213, 9, 9, 9),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Guardar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
             
                ],
              ),
            ),
          );
        },
      );
    },
    
  );

  
  }}