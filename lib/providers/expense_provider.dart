import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:beer_sale/model/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Expense> _expenses = [];
  bool loading = false;

  List<Expense> get expenses => _expenses;

  Future<void> deleteExpense(Expense expense) async {
  try {
    if (expense.id != null) {
      await _db.collection('expenses').doc(expense.id).delete();
    } 
  } catch (e) {
 
    rethrow;
  }
}

  Future<void> fetchExpenses() async {
    loading = true;
    notifyListeners();
    final snap = await _db.collection('expenses')
      .orderBy('date', descending: true)
      .get();
    _expenses = snap.docs.map((d) => Expense.fromMap(d.data()..['id'] = d.id)).toList();
    loading = false;
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    // create a local copy with current date (if needed)
    final local = expense.copyWith(date: expense.date ?? DateTime.now());
    // optimistic update: show immediately
    _expenses.insert(0, local);
    notifyListeners();

    try {
      final docRef = await _db.collection('expenses').add(local.toMap());
      // if you want to keep id:
      final idx = _expenses.indexWhere((e) => e == local);
      if (idx != -1) {
        _expenses[idx] = _expenses[idx].copyWith(id: docRef.id);
        notifyListeners();
      }
    } catch (e) {
      // rollback on error
      _expenses.remove(local);
      notifyListeners();
      rethrow;
    }
  }
}
