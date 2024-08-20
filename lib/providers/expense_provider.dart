import 'package:flutter/material.dart';

class ExpenseProvider extends ChangeNotifier {
  GlobalKey<FormState> formLoginKey = GlobalKey<FormState>();

  Map<String, dynamic> formValues = {
    "total_spent": "0",
    "category": null,
    "currency": null,
    "description": "",
    "participants": []
  };

  List<Map<String, dynamic>> _integrants = [];

  void addIntegrants(List<Map<String, dynamic>> new_integrants) async {
    List<Map<String, dynamic>> selectedUsers = new_integrants
        .where((user) => user["pending"] == false)
        .map((user) => {
              "uid": user["user"]["id"],
              "username": user["user"]["username"],
              "email": user["user"]["email"]
            })
        .toList();
    _integrants = [];
    for (var integrant in selectedUsers) {
      final Map<String, dynamic> newIntegrant = {
        "user_id": integrant["uid"],
        "username": integrant["username"],
        "email": integrant["email"],
        "check": false,
        "spent": 0,
        "paid": 0,
      };
      integrants.add(newIntegrant);
    }
  }

  List<bool> isExpanded = [];

  void setExpanded(int index, bool value) {
    isExpanded[index] = value;
    notifyListeners();
  }

  void initIsExpanded(int keys) {
    isExpanded = [];
    for (int i = 0; i < keys; i++) {
      isExpanded.add(false);
    }
  }

  List<Map<String, dynamic>> get integrants => _integrants;

  bool _isEquallyDivided = false;

  bool get isEquallyDivided => _isEquallyDivided;

  void divideExpenseEqually() {
    final int totalParticipants =
        integrants.where((integrant) => integrant["check"] == true).length;
    if (totalParticipants == 0) return;
    if (double.tryParse(formValues["total_spent"]) == null) return;
    final double totalSpent =
        double.parse(formValues["total_spent"].toString());
    final double amountPerPerson = totalSpent / totalParticipants;
    final double roundedAmount =
        double.parse(amountPerPerson.toStringAsFixed(2));
    for (var integrant in integrants) {
      integrant["spent"] = roundedAmount;
    }
    notifyListeners();
  }

  List<String> uidToPay = [];
  double totalToPay = 0;

  void setUidToPay(String uid) {
    uidToPay.add(uid);
    // notifyListeners();
  }

  void removeUidToPay(String uid) {
    uidToPay.remove(uid);
    // notifyListeners();
  }

  void toggleUidToPay(String uid, double amount) {
    if (uidToPay.contains(uid)) {
      removeUidToPay(uid);
      totalToPay -= amount;
    } else {
      setUidToPay(uid);
      totalToPay += amount;
    }
  }

  double getTotalToPay() {
    return totalToPay;
  }

  bool containsUidToPay(String uid) {
    return uidToPay.contains(uid);
  }

  void clearUidToPay() {
    uidToPay = [];
    totalToPay = 0;
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setEquallyDivided(bool value) {
    _isEquallyDivided = value;
    if (value) {
      divideExpenseEqually();
    }
    notifyListeners();
  }

  void setCheck(int index, bool value) {
    integrants[index]["check"] = value;
    notifyListeners();
  }

  void setAllCheck(bool value) {
    for (var integrant in integrants) {
      integrant["check"] = value;
    }
    notifyListeners();
  }

  void printValues() {
    print("El form quedo en ");
    print(formValues);
    print(integrants);
  }

  void submit() {
    notifyListeners();
  }

  bool isValidName() {
    return formValues["name"] != null && formValues["name"].isNotEmpty;
  }

  bool isValidExpense() {
    bool integrants =
        _integrants.any((integrant) => integrant["check"] == true);
    bool category = formValues["category"] != null;
    bool currency = formValues["currency"] != null;
    bool validate = formLoginKey.currentState?.validate() ?? true;

    print(
        "integrants $integrants, category $category, currency $currency, and validate $validate");
    return validate && integrants && category && currency;
  }

  bool isValidTypePaidSpent() {
    if (formValues["total_spent"] == null) return false;

    if (formValues["total_spent"] is String) {
      var parsedValue = double.tryParse(formValues["total_spent"]);
      if (parsedValue != null) {
        formValues["total_spent"] = parsedValue;
      } else {
        return false;
      }
    } else if (formValues["total_spent"] is! double) {
      return false;
    }
    final checkedIntegrants = _integrants.where((integrant) {
      return integrant["check"] == true;
    }).toList();

    for (var integrant in checkedIntegrants) {
      if (integrant["spent"] == null || integrant["paid"] == null) return false;

      double? parsedValueSpent;
      try {
        if (integrant["spent"].runtimeType == String) {
          parsedValueSpent = double.tryParse(integrant["spent"]);
          if (parsedValueSpent != null) {
            integrant["spent"] = parsedValueSpent;
          } else {
            return false;
          }
        } else if (integrant["spent"].runtimeType == int) {
          integrant["spent"] = integrant["spent"].toDouble();
        }
        if (integrant["paid"].runtimeType == String) {
          parsedValueSpent = double.tryParse(integrant["paid"]);
          if (parsedValueSpent != null) {
            integrant["paid"] = parsedValueSpent;
            continue;
          } else {
            return false;
          }
        }
        if (integrant["paid"].runtimeType == int) {
          integrant["paid"] = integrant["paid"].toDouble();
        }
      } catch (e) {
        print("error $e");
        return false;
      }
    }
    return true;
  }

  bool isValidPaid() {
    var totalSpent = formValues["total_spent"];
    int totalPaid = 0;
    for (var integrant in integrants) {
      totalPaid += double.parse(integrant["paid"].toString()).round();
    }
    final totalSpentDouble = (totalSpent.runtimeType == String)
        ? double.parse(totalSpent)
        : totalSpent;
    return totalPaid == totalSpentDouble;
  }

  bool isValidForm() {
    return formLoginKey.currentState?.validate() ?? false;
  }
}
