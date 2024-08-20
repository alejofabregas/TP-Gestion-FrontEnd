class FormHelper {
  final String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  late RegExp regExp;

  final String birthdayPattern =
      r'^\d{4}\-(0[1-9]|1[012])\-(0[1-9]|[12][0-9]|3[01])$';
  late RegExp regExpBirthday;

  FormHelper() {
    regExp = RegExp(pattern);
    regExpBirthday = RegExp(birthdayPattern);
  }

  String? isValidBudget(String? value) {
    if (value!.isEmpty) {
      return "El presupuesto no puede estar vacio";
    }
    if (int.tryParse(value) == null) {
      return "El presupuesto debe ser un número";
    }
    if (int.parse(value) == 0) {
      return "El presupuesto no puede ser 0";
    }
    if (int.parse(value) < 0) {
      return "El presupuesto no puede ser negativo";
    }
    return null;
  }

  String? isValidEmail(String text) {
    return regExp.hasMatch(text) ? null : 'El email no es correcto';
  }

  String? isValidTextEmail(String text) {
    return text.isEmpty ? 'Campo Requerido' : null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    } else if (!RegExp(pattern).hasMatch(value)) {
      return 'Please enter a valid email ending with @<email>.com';
    } else {
      return null;
    }
  }

  String? isValidExpense(String? text) {
    if (text == null) {
      return 'Campo Requerido';
    } else if (double.tryParse(text) == null) {
      return 'El valor debe ser un número válido';
    } else if (double.parse(text) < 0) {
      return 'El valor no puede ser negativo';
    }
    return null;
  }

  String? isValidGroupName(String text) {
    return text.length < 5 ? 'Tamaño mínimo requerido de 5 caracteres' : null;
  }

  String? isValidGroupDescription(String text) {
    return text.length < 10 ? 'Tamaño mínimo requerido de 10 caracteres' : null;
  }

  String? isValidPassword(String text) {
    return text.length < 6 ? 'Tamaño mínimo requerido de 6 caracteres' : null;
  }

  String? isValidName(String text) {
    return text.length < 3 ? 'Tamaño mínimo requerido de 3 caracteres' : null;
  }

  String? isValidBirthday(String text) {
    return regExpBirthday.hasMatch(text) ? null : 'La fecha no es correcta';
  }

  String? isValidHeight(String text) {
    return text.length != 3 ? 'Altura inválida' : null;
  }

  String? isValidWeight(String text) {
    return text.isEmpty ? 'Campo Requerido' : null;
  }

  String? isValidPhoneValue(String text, int length) {
    return text.length != length ? 'Numero invalido' : null;
  }
}
