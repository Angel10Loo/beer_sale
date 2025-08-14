import 'package:beer_sale/model/enums/userRole.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String? id;
  final String email;
  final String name;
  final String role;
  final String password;
  final bool isActive;
  final String? createdBy;


  AppUser({
     this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.password,
    required this.isActive,
    this.createdBy
  });

    AppUser copyWith({
    String? id,
    String? email,
    String? password,
    UserRole? role,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name,
      password: password ?? this.password,
      role: role?.name ?? this.role,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
    );
  }


    Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name':name,
      'password': password,
      'role': role,
      'isActive': isActive,
      'createdBy': createdBy,
    };
  }


  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'],
      role: UserRole.values.firstWhere((r) => r.name == data['role']).toString(),
      isActive: data['isActive'] ?? true,
       password: data['password'] ?? '',
       createdBy: data['createdBy'] ?? ''
    );
  }
}
