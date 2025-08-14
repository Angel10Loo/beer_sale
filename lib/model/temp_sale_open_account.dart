import 'package:cloud_firestore/cloud_firestore.dart';

class TempOpenSaleAccount {
   String? id; // Firestore document ID
  final String customerId;
  final String productId;
  final int salePrice;
  final int quantitySold;
  final DateTime createdDate;

  TempOpenSaleAccount({
    this.id,
    required this.customerId,
    required this.productId,
    required this.salePrice,
    required this.quantitySold,
    required this.createdDate,
  });

  // Convert Sale object to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'productId': productId,
      'salePrice': salePrice,
      'quantitySold': quantitySold,
      'createdDate' : DateTime.now(),
    };
  }

  // Create Sale object from Firestore map
  factory TempOpenSaleAccount.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TempOpenSaleAccount(
      id: doc.id,
      customerId: data['customerId'] as String,
      productId: data['productId'] as String,
      salePrice: data['salePrice'],
      quantitySold: data['quantitySold'] as int,
      createdDate: (data['createdDate'] as Timestamp).toDate(),
    );
  }

 
  // copyWith method
  TempOpenSaleAccount copyWith({
    String? id,
    String? customerId,
    String? productId,
    int? salePrice,
    int? quantitySold,
    DateTime? createdDate
  }) {
    return TempOpenSaleAccount(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      productId: productId ?? this.productId,
      salePrice: salePrice ?? this.salePrice,
      quantitySold: quantitySold ?? this.quantitySold,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}