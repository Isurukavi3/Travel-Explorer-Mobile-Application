import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../models/place_model.dart';

class AppProvider extends ChangeNotifier {
  final FirebaseService _service = FirebaseService();

  User? get currentUser => _service.currentUser;
  bool get isLoggedIn => currentUser != null;

  String _selectedCategory = 'all';
  String get selectedCategory => _selectedCategory;

  void setCategory(String cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  Stream<List<PlaceModel>> get placesStream => _service.getPlaces(
    category: _selectedCategory == 'all' ? null : _selectedCategory,
  );

  FirebaseService get service => _service;

  Future<void> signOut() async {
    await _service.signOut();
    notifyListeners();
  }

  void notifyAuthChange() => notifyListeners();
}
