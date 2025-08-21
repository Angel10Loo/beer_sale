import 'package:beer_sale/model/product.dart';
import 'package:beer_sale/model/sale.dart';
import 'package:beer_sale/model/temp_sale_open_account.dart';
import 'package:beer_sale/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SaleProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late ProductProvider _productProvider;
  bool _isLoading = false;
  bool get loading => _isLoading;
  double _todaySale = 0;
  double get todaySale => _todaySale;
  List<TempOpenSaleAccount> _temOpenSaleAccounts = [];
  List<Product> get products => _productProvider.products;
  List<TempOpenSaleAccount> get tempOpenSaleAccounts =>
      List.unmodifiable(_temOpenSaleAccounts);


Future<String> performDailyClosing() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final DateTime now = DateTime.now();
  final DateTime startOfDay = DateTime(now.year, now.month, now.day);
  final DateTime endOfDay = startOfDay.add(const Duration(days: 1));

  final QuerySnapshot salesSnapshot = await firestore
      .collection('sales')
      .where('saleDate', isGreaterThanOrEqualTo: startOfDay)
      .where('saleDate', isLessThan: endOfDay)
      .get();

       // 🔹 Fetch today's expenses
  final QuerySnapshot expensesSnapshot = await firestore
      .collection('expenses')
      .where('date', isGreaterThanOrEqualTo: startOfDay)
      .where('date', isLessThan: endOfDay)
      .get();

  final sales = salesSnapshot.docs;
   final expenses = expensesSnapshot.docs;
  if (sales.isEmpty) {
    return "";
  }

double totalAmount = 0;
int totalUnitsSold = 0; 
Map<String, int> productQuantityMap = {}; 
Map<String, String> productNamesMap = {}; // To keep productId → productName mapping
Map<String, String> productImagesMap = {}; // To keep productId → productName mapping


for (var sale in sales) {

  final data = sale.data() as Map<String, dynamic>;

  totalAmount += (data['salePrice'] ?? 0).toDouble();

  final productId = data['productId'] as String;
  final productName = data['productName'] as String? ?? 'Unknown product';
  final quantitySold = (data['quantitySold'] ?? 0) as int;

  totalUnitsSold += quantitySold;
  productQuantityMap[productId] = (productQuantityMap[productId] ?? 0) + quantitySold;
 productImagesMap[productId] = data['imagePath'] ;
  productNamesMap[productId] = productName; 
}
  Map<String, Map<String, dynamic>> productDetails = {};
  productQuantityMap.forEach((productId, quantity) {
    productDetails[productId] = {
      'productName': productNamesMap[productId],
      'quantitySold': quantity,
      'imagePath': productImagesMap[productId] ?? '',
    };
  });

    double totalExpensesAmount = 0;
  List<Map<String, dynamic>> expensesDetails = [];

if(expenses.isNotEmpty){
  for (var expense in expenses) {
    final data = expense.data() as Map<String, dynamic>;
    totalExpensesAmount += (data['amount'] ?? 0).toDouble();

    expensesDetails.add({
      'title': data['title'] ?? 'No description',
      'amount': data['amount'] ?? 0,
    });
  }
}

  final closing = {
    'total': totalAmount,
    'date': now.toIso8601String(),
    'totalSales': totalUnitsSold,
    'productDetails': productDetails,
    'totalExpenses': totalExpensesAmount,
    'expensesDetails': expensesDetails,
    'netProfit': totalAmount - totalExpensesAmount,

  };

 final docRef =  await firestore.collection('closings').add(closing);
  _todaySale = 0; 
  notifyListeners();
 return docRef.id;
}


  void updateProductProvider(ProductProvider productProvider) {
    _productProvider = productProvider;
    notifyListeners();
  }

   Stream<List<Sale>> get salesStream {
    return _firestore
      .collection('sales') 
      .orderBy('saleDate', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList());
  }

Future<void> getTodaySales() async {
  final closingDoc = await FirebaseFirestore.instance
      .collection('closings')
      .orderBy('date', descending: true)
      .limit(1)
      .get();
  DateTime startTime;

  if (closingDoc.docs.isNotEmpty) {
    final doc = closingDoc.docs.first; 
   startTime =  DateTime.parse(doc['date']);
  } else {
    final now = DateTime.now();
    startTime = DateTime(now.year, now.month, now.day);
  }


  final snapshot = await FirebaseFirestore.instance
      .collection('sales')
      .where('saleDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startTime))
      .get();

  final sales = snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList();

  double todaySale = 0;
  for (var sale in sales) {
    todaySale += sale.salePrice;
  }

  _todaySale = todaySale;
  notifyListeners();
}

  Future<void> addTempSaleOpenAccount(
      TempOpenSaleAccount tempSaleOpenAccount) async {
    try {
      final salesCollection =
          FirebaseFirestore.instance.collection('tempOpenSaleAccounts');
      DocumentReference docRef =
          await salesCollection.add(tempSaleOpenAccount.toMap());
      tempSaleOpenAccount.id = docRef.id;

      final productIndex = products
          .indexWhere((product) => product.id == tempSaleOpenAccount.productId);
      final updatedStock =
          products[productIndex].stock - tempSaleOpenAccount.quantitySold;

      await _firestore
          .collection('products')
          .doc(tempSaleOpenAccount.productId)
          .update({'stock': updatedStock});

      _productProvider.updateProductStock(
          tempSaleOpenAccount.productId, updatedStock);

      _temOpenSaleAccounts.add(tempSaleOpenAccount);
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> fetchSalesByCustomerId(String customerId) async {
    try {
      _isLoading = true;
      notifyListeners();
      final salesCollection =
          FirebaseFirestore.instance.collection('tempOpenSaleAccounts');
      final querySnapshot = await salesCollection
          .where('customerId', isEqualTo: customerId)
          .get();

      _temOpenSaleAccounts = querySnapshot.docs
          .map((doc) => TempOpenSaleAccount.fromFirestore(doc))
          .toList();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleSaleOpenAccount(List<TempOpenSaleAccount> tempOpenSaleAccount) async {
     
    try {
      _isLoading = true;
      final salesCollection = _firestore.collection('sales');
      final productMap = {
        for (var product in _productProvider.products) product.id: product
      };
      final batch = FirebaseFirestore.instance.batch();


      for (TempOpenSaleAccount sale in tempOpenSaleAccount) {
        final product = productMap[sale.productId]!;
        final saleDoc = salesCollection.doc();
        batch.set(saleDoc, {
          'salePrice': sale.salePrice,
          'purchasePrice': product.purchasePrice,
          'productId': sale.productId,
          'productName': product.name,
          'imagePath': product.imageName,
          'quantitySold': sale.quantitySold,
          'saleDate': DateTime.now(),
        });
      }
      await batch.commit();
      _todaySale += tempOpenSaleAccount.fold<int>(0, (sum, s) => sum + s.salePrice);

      await deleteTempOpenSaleAccountsByIds(tempOpenSaleAccount.map((x) => x.id!).toList());
  
      
    } catch (e) {
      print('Error saving product list: $e');
    }finally{
          _isLoading = false;
      
      notifyListeners();
    }
  }

  Future<void> handleSale(String productId, int quantitySold, int salePrice) async {
      
    try {
      _isLoading = true;
      notifyListeners();

      final productIndex =
          products.indexWhere((product) => product.id == productId);
      if (productIndex == -1) throw Exception("Product not found");

      final selectedProduct = products[productIndex];
      if (quantitySold > selectedProduct.stock) {
        throw Exception("Quantity exceeds available stock");
      }
      final updatedStock = selectedProduct.stock - quantitySold;

      await _firestore
          .collection('products')
          .doc(productId)
          .update({'stock': updatedStock});

      _productProvider.updateProductStock(productId, updatedStock);

      await _firestore.collection('sales').add({
        'salePrice': salePrice,
        'purchasePrice': selectedProduct.purchasePrice,
        'productId': productId,
        'productName': selectedProduct.name,
        'imagePath': selectedProduct.imageName,
        'quantitySold': quantitySold,
        'saleDate': DateTime.now(),
      });
      _isLoading = false;
      await getTodaySales();
      notifyListeners();
    } catch (e) {
      print('Error completing sale: $e');
      rethrow;
    }
  }

  Future<void> deleteTempOpenSaleAccountsByIds(List<String> ids) async {
  try {

  final collection = FirebaseFirestore.instance.collection('tempOpenSaleAccounts');
  final batch = FirebaseFirestore.instance.batch();

  for (final id in ids) {
    final docRef = collection.doc(id);
    batch.delete(docRef);
  }

  await batch.commit();
  if(ids.length > 1){
_temOpenSaleAccounts = [];
  }else{
_temOpenSaleAccounts =  _temOpenSaleAccounts.where((x) => x.id != ids.first).toList();
  }
  notifyListeners();
      
    } catch (e) {
        print("Error $e");
    }

 }

}
