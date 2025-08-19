import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String? id;
  final String title;
  final double amount;
  final DateTime date;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  // Create a map suitable for Firestore
  Map<String, dynamic> toMap() => {
        'title': title,
        'amount': amount,
        'date': Timestamp.fromDate(date),
      };

  // Build an Expense from Firestore data (expects 'date' as Timestamp)
  factory Expense.fromMap(Map<String, dynamic> map) {
    final ts = map['date'] as Timestamp?;
    return Expense(
      id: map['id'] as String?,
      title: (map['title'] ?? '') as String,
      amount: (map['amount'] as num).toDouble(),
      date: ts?.toDate() ?? DateTime.now(),
    );
  }

  // copyWith — use this to create a modified copy (important for optimistic update)
  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }
}
