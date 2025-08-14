import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String? id;
  final String name;
  final int stock;
  final String imageName;
  final int purchasePrice;
  final int price;
  final DateTime createdDate;

  Product({
    this.id,
    required this.name,
    required this.stock,
    required this.imageName,
    required this.purchasePrice,
    required this.price,
    required this.createdDate,
  });

    factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      stock: json['stock'],
      imageName: json['imageName'],
      purchasePrice: json['purchasePrice'],
      price: json['price'],
      createdDate: DateTime.parse(json['createdDate']), 
    );
  }

    factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
       id: doc.id, 
       name: data['name'],
       stock: data['stock'],
       imageName: data['imageName'],
       purchasePrice: data['purchasePrice'],
       price: data['price'],
       createdDate: (data['createdDate'] as Timestamp).toDate(),
    );
  }

    Map<String, dynamic> toMap() {
    return {
      'name': name,
      'stock': stock,
      'imageName': imageName,
      'price': price,
      'createdDate': createdDate,
    };
  }

    // copyWith method to clone and update fields
  Product copyWith({
    String? id,
    String? name,
    int? stock,
    String? imageName,
    int? purchasePrice,
    int? price,
    DateTime? createdDate,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      stock: stock ?? this.stock,
      imageName: imageName ?? this.imageName,
      purchasePrice: this.purchasePrice,
      price: this.price,
      createdDate: createdDate ?? this.createdDate,
    );
  }


  @override
  String toString() {
     return 'Product(name: $name, stock: $stock,imageName: $imageName,price: $price,createdDate: $createdDate)';
  }
}