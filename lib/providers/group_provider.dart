import 'package:flutter/material.dart';

class GroupProvider extends ChangeNotifier {
  GlobalKey<FormState> formLoginKey = GlobalKey<FormState>();

  Map<String, String> formValues = {
    "name": "",
    "description": "",
    "budget": "",
  };

  Map<String, String> presupuestoValues = {
    "budget": "-1",
  };

  void initPresupuesto(dynamic value) {
    presupuestoValues["budget"] = value;
  }

  bool isValidForm() {
    return formLoginKey.currentState?.validate() ?? false;
  }

  bool isLoading = false;

  void setLoading(bool value) {
    isLoading = value;
  }

  Map<String, bool> categories = {
    "Comida": true,
    "Transporte": true,
    "Salud": true,
    "Educación": true,
    "Entretenimiento": true,
    "Servicios": true,
    "Otros": true,
  };

  void setCategory() {
    notifyListeners();
  }
}
