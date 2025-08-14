import 'package:beer_sale/model/open_account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OpenAccountProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   List<OpenAccount> _openAccounts = [];
   List<OpenAccount> get openAccounts => List.unmodifiable(_openAccounts);

   Future<void> addAccount(OpenAccount account) async {
    final collection = _firestore.collection('openAccounts');
    
     DocumentReference docRef =  await collection.add(account.toMap());
     account.id = docRef.id;
     _openAccounts.add(account);
    notifyListeners();

  }

     Future<void> fetchAllAccounts() async {
    final snapshot = await FirebaseFirestore.instance.collection('openAccounts').get();
    _openAccounts = snapshot.docs.map((doc) => OpenAccount.fromFirestore(doc)).toList();
    notifyListeners();
  }

   Future<void> deleteOpenAccount(String id) async {

     final docRef =  FirebaseFirestore.instance.collection('openAccounts').doc(id);

        await docRef.delete();
      _openAccounts = _openAccounts.where((x) => x.id != id).toList();

    notifyListeners();
  }
  

}