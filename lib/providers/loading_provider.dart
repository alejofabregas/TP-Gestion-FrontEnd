import 'package:flutter/material.dart';

class LoadingProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool aceptar = false;

  bool get getAceptar => aceptar;

  set setAceptar(bool value) {
    aceptar = value;
    notifyListeners();
  }
}
