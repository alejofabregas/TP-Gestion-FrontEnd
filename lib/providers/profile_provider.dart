import 'package:flutter/material.dart';
import '../../models/models.dart';

class ProfileProvider extends ChangeNotifier {
  Profile? _profile;
  Profile? get profile => _profile;

  void setProfile(Profile profile) {
    _profile = profile;
    notifyListeners();
  }
}
