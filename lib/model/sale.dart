import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final String id; 
  final String productId; 
  final String productName; 
  final int quantitySold; 
  late final int salePrice; 
  late final int purchasePrice; 

  final String? imagePath; 
  final DateTime saleDate; 

  Sale({
    this.imagePath,
    required this.id,
    required this.salePrice,
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.saleDate,
    required this.purchasePrice
  });

  Sale.defaultSale()
      : id = '',
        productId = '',
        productName = '',
        quantitySold = 0,
        salePrice = 0, 
        purchasePrice = 0, 
        imagePath = '',
        saleDate = DateTime.now();


  factory Sale.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Sale(
      id: doc.id,
      imagePath: data['imagePath'],
      productId: data['productId'],
      productName: data['productName'],
      quantitySold: data['quantitySold'],
      saleDate: (data['saleDate'] as Timestamp).toDate(), 
      salePrice: data['salePrice'],
      purchasePrice: data['purchasePrice']

    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'imagePath':imagePath,
      'productId': productId,
      'productName': productName,
      'quantitySold': quantitySold,
      'saleDate': Timestamp.fromDate(saleDate),
      'salePrice': salePrice,
      'purchasePrice':purchasePrice
    };
  }
   Sale copyWith({
    String? id,
    String? productId,
    String? productName,
    int? quantitySold,
    int? salePrice,
    int? purchasePrice,
    String? imagePath,
    DateTime? saleDate,
  }) {
    return Sale(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantitySold: quantitySold ?? this.quantitySold,
      salePrice: salePrice ?? this.salePrice,
      purchasePrice:purchasePrice ?? this.purchasePrice,
      imagePath: imagePath ?? this.imagePath,
      saleDate: saleDate ?? this.saleDate,
    );
  }
}
