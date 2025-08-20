import 'package:beer_sale/model/enums/userRole.dart';
import 'package:beer_sale/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final CollectionReference _usersColl =
      FirebaseFirestore.instance.collection('users');

  AppUser? _user;
   // ignore: prefer_final_fields
   List<AppUser> _users = [];

    bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  List<AppUser> get  users =>  List.unmodifiable(_users);

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
  
  void setLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }


  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

   Future<void> toggleUserActiveStatus(AppUser user) async {
    final newStatus = !user.isActive;

    // Update Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .update({'isActive': newStatus});

    // Update local list
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = _users[index].copyWith(isActive: newStatus);
      notifyListeners();
    }
  }

  Future<void> fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    _users = snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList();
    notifyListeners();
  }

  /// Create user (plaintext password) — admin-only screen should call this.
  Future<bool> createUserPlaintext({
    required String email,
    required String name,
    required String plainPassword,
     UserRole role = UserRole.normal,
    required String adminUid,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
 final user = AppUser(
    email: email,
    name: name,
    password: plainPassword,
    role: role.name,
    createdBy: adminUid,
    isActive: true
  );
  final docRef = await FirebaseFirestore.instance
      .collection('users')
      .add(user.toMap());

       _users.add(user.copyWith(id: docRef.id)); 
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Create user error: ${e.toString()}');
      return false;
    }
  }


  Future<bool> signInPlaintext({
    required String email,
    required String plainPassword,
  }) async {
    _setLoading(true);
    _setError(null);
    try {

  //       await createUserPlaintext(
  //   email: "admin",
  //   name: "Mary",
  //   plainPassword: "1234",
  //   role: UserRole.admin,
  //   adminUid: "system",
  // );

      final q = await _usersColl
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      if (q.docs.isEmpty) {
        _setLoading(false);
        _setError('User not found');
        return false;
      }

      final doc = q.docs.first;
      final data = doc.data() as Map<String, dynamic>;

      final isActive = (data['isActive'] ?? true) as bool;
      if (!isActive) {
        _setLoading(false);
        _setError('User is disabled');
        return false;
      }

      final stored = data['password'] as String?;
      if (stored == null) {
        _setLoading(false);
        _setError('User has no password set');
        return false;
      }

      if (stored != plainPassword) {
        _setLoading(false);
        _setError('Invalid credentials');
        return false;
      }

      // success: populate provider user
      _user = AppUser(
        id: doc.id,
        email: (data['email'] ?? '') as String,
        name: data['name'],
        role: (data['role'] ?? 'user') as String,
        isActive: isActive,
        password: (data['password'] ?? '') as String
      );
      setLoggedIn(true);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Login error: ${e.toString()}');
      return false;
    }
  }

  /// Simple logout
  void signOut() {
    _user = null;
      _isLoggedIn = false;
    notifyListeners();
  }

  /// Optional: fetch user by id (if you need to refresh)
  Future<void> refreshCurrentUser() async {
    if (_user == null) return;
    final doc = await _usersColl.doc(_user!.id).get();
    if (!doc.exists) {
      _user = null;
    } else {
      final data = doc.data() as Map<String, dynamic>;
      _user = AppUser(
        id: doc.id,
        email: (data['email'] ?? '') as String,
        name: data['name'],
        role: (data['role'] ?? 'user') as String,
        password: (data['password'] ?? '') as String,
        isActive: (data['isActive'] ?? true) as bool,
      );
    }
    notifyListeners();
  }
}