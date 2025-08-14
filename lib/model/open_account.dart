import 'package:cloud_firestore/cloud_firestore.dart';

class OpenAccount {
  String? id;
  final String name;

  OpenAccount({this.id, required this.name});

  factory OpenAccount.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OpenAccount(
      id: doc.id, 
      name: data['name'] ?? '', 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}