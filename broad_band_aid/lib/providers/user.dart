import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void updateDataUsage(int usedData) {
    if (_user != null) {
      _user = User(
        name: _user!.name,
        email: _user!.email,
        password: _user!.password,
        confirmPassword: _user!.confirmPassword,
        planLimit: _user!.planLimit,
        dataUsed: usedData,
      );
      notifyListeners();
    }
  }
}
