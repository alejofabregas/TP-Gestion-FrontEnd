import 'package:flutter/material.dart';

class UsernameProvider extends ChangeNotifier {
  final GlobalKey<FormState> formUserKey = GlobalKey<FormState>();

  Map<String, String> formValues = {
    'username': '',
  };

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool isValidForm() {
    return formUserKey.currentState?.validate() ?? false;
  }
}
