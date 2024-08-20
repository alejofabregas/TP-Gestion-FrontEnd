import 'package:flutter/material.dart';

class LoginFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formLoginKey = GlobalKey<FormState>();

  Map<String, String> formValues = {
    'username': '',
    'email': '',
    'password': '',
    'mp_alias': '',
  };

  bool _recordarme = false;

  bool _registrarme = false;

  set register(bool value) {
    _registrarme = value;
    notifyListeners();
  }

  bool get register => _registrarme;

  set recordarme(bool value) {
    _recordarme = value;
    notifyListeners();
  }

  bool get recordarme => _recordarme;

  bool isValidForm() {
    return formLoginKey.currentState?.validate() ?? false;
  }
}
