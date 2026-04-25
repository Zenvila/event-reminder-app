import 'package:event_reminder_app/models/app_user.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  AppUser? _user;
  AppUser? get user => _user;

  Future<void> setUser(AppUser user) async {
    _user = user;
    notifyListeners();
  }

  Future<void> setLocalUser({
    required String name,
    String? email,
  }) async {
    _user = AppUser(
      uid: 'local_user',
      name: name,
      email: email,
      photoUrl: null,
    );
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}