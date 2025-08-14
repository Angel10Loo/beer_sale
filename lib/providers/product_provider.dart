import 'package:beer_sale/model/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
   List<Product> _products = [];
  bool _isLoading = false;
  bool get loading => _isLoading;


  // Getter for products
  List<Product> get products => List.unmodifiable(_products);

  


  // Load products from Firebase
  Future<void> fetchProducts() async {
    try {
      _isLoading = true;
 notifyListeners();
      final snapshot = await _firestore.collection('products').get();
      _products.clear();
      _products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      notifyListeners();
      _isLoading = false;
    } catch (e) {
      debugPrint('Error fetching products: $e');
    }
  }

    void updateProductStock(String productId, int updatedStock) {
    final index = _products.indexWhere((product) => product.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(stock: updatedStock);
      notifyListeners(); 
    }
  }

  // Add a new product
  Future<void> addProduct(Product product) async {
    try {
      _isLoading = true;

         DocumentReference docRef =  await _firestore.collection('products').add({
        'name': product.name,
        'stock': product.stock,
        'imageName': product.imageName,
        'price': product.price,
        'purchasePrice': product.purchasePrice,
        'createdDate': product.createdDate,
      });
      product.id = docRef.id;
      _products.add(product);
      notifyListeners();
      _isLoading = false;
    } catch (e) {
      debugPrint('Error adding product: $e');
    }
  }


  Future<void> updateProduct(String id, Product updatedProduct) async {
  try {
    await FirebaseFirestore.instance.collection('products').doc(id).update(updatedProduct.toMap());
    final index = _products.indexWhere((product) => product.id == id);
    if (index != -1) {
      _products[index] = updatedProduct; 
    }
      notifyListeners();
  } catch (e) {
    print('Failed to update product: $e');
  }
}

  // Remove a product by document ID
  Future<void> removeProduct(String id) async {
    try {
      final docId = _firestore.collection('products').doc(id); // Replace with a saved ID
      _products.removeWhere((x) => x.id == id);
      await docId.delete();
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing product: $e');
    }
  }
}