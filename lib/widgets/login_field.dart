import 'package:flutter/material.dart';
import 'package:splitwise/themes/app_theme.dart';

class LoginFormField extends StatefulWidget {
  const LoginFormField({
    Key? key,
    required this.isPassword,
    required this.text,
    required this.formValues,
    required this.formProperty,
    this.keyboardType,
    this.height,
    this.validator,
    this.maxLines,
    this.width,
  }) : super(key: key);
  final bool isPassword;
  final String text;
  final Map<String, dynamic> formValues;
  final String formProperty;
  final Function? validator;
  final TextInputType? keyboardType;
  final double? height;
  final int? maxLines;
  final double? width;
  @override
  State<LoginFormField> createState() => _LoginFormFieldState();
}

class _LoginFormFieldState extends State<LoginFormField> {
  bool _obscureText = true;
  bool _hasValue = false;

  final fieldText = TextEditingController();
  void clearText() {
    fieldText.clear();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
      key: Key(widget.formProperty),
      width: widget.width ?? size.width * 0.9,
      height: widget.height ?? size.height * 0.09,
      child: Stack(
        children: [
          TextFormField(
            maxLines: widget.maxLines ?? 1,
            keyboardType: widget.keyboardType,
            controller: fieldText,
            onChanged: (value) => {
              widget.formValues[widget.formProperty] = value,
              setState(() {
                _hasValue = value.isNotEmpty;
              }),
            },
            style: const TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontSize: 14,
            ),
            validator: (value) => widget.validator!(value),
            decoration: InputDecoration(
              fillColor: Colors.transparent,
              hintText: 'Ingresa su ${widget.text}',
              hintStyle: TextStyle(
                  color: AppTheme.letterColorRegistration.withOpacity(0.2),
                  fontSize: 14),
              label: Text(widget.text,
                  style: const TextStyle(
                      color: AppTheme.backgroundContainer,
                      fontSize: 14,
                      fontFamily: 'Calibri')),
            ),
            obscureText: widget.isPassword &&
                _obscureText, // Conditionally obscure text based on the state
          ),
          widget.isPassword &&
                  _hasValue // Show the icon only if it's a password field and there is a value
              ? Positioned(
                  top: size.height * 0.03,
                  right: size.width * 0.05,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    child: _obscureText == true
                        ? const Icon(Icons.visibility_off, color: Colors.black)
                        : const Icon(Icons.remove_red_eye, color: Colors.black),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}

class CustomInputField2 extends StatelessWidget {
  final String? hintText;
  final IconData? suffixIcon;
  final String? helper;
  final TextInputType? textType;
  final bool obscureText;
  final Function? validator;

  final String formProperty;
  final Map<String, String> formValues;

  const CustomInputField2({
    super.key,
    this.hintText,
    this.suffixIcon,
    this.helper,
    this.textType,
    this.obscureText = false,
    required this.formProperty,
    required this.formValues,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fieldText = TextEditingController();

    void clearText() {
      fieldText.clear();
    }

    return SizedBox(
      key: Key(formProperty),
      height: size.height * 0.1,
      child: SizedBox(
        height: size.height * 0.07,
        child: TextFormField(
          style: TextStyle(color: Colors.black.withOpacity(0.8)),
          controller: fieldText,
          autofocus: false,
          //textCapitalization: TextCapitalization.sentences, //mayuscula
          keyboardType: textType,
          obscureText: obscureText,
          onChanged: (value) {
            formValues[formProperty] = value;
          },
          validator: (value) {
            if (value == null) return 'campo requerido';

            formValues[formProperty] = value;

            if (validator == null) {
              return null;
            }
            if (validator!(value) != null) {
              clearText();
            }
            return validator!(value);
          },
          //autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            helperText: helper,
            suffixIcon: suffixIcon == null
                ? null
                : Icon(
                    suffixIcon,
                    color: Colors.white.withOpacity(0.7),
                  ),
            focusColor: Colors.grey.withOpacity(0.4),
            errorStyle: TextStyle(
                fontSize: 12,
                letterSpacing: 1,
                color: const Color.fromARGB(255, 255, 57, 43),
                backgroundColor: Colors.black.withOpacity(0.05)),
          ),
        ),
      ),
    );
  }
}
