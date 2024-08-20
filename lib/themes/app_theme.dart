import 'package:flutter/material.dart';

class AppTheme {
  static Color primary = const Color(0xff2E305F);

  static const Color letterColor = Colors.white;
  static const Color letterColorDark = Colors.black;
  static const Color backgroundContainerDark = Colors.black;
  static const Color backgroundContainer = Color.fromARGB(255, 20, 3, 42);
  static Color letterColorRegistration = Colors.deepPurple[300]!;
  static const Color appBarColor = Color(0xff2E305F);
  static Color gradientContainerLeft =
      Color.fromARGB(255, 9, 107, 187).withOpacity(0.8);
  static Color gradientContainerRight =
      Color.fromARGB(255, 77, 3, 237).withOpacity(0.8);
  static const Color secondaryBackgroundContainer =
      Color.fromARGB(255, 40, 17, 89);

  static const Color registerCollorContainerLetter =
      Color.fromARGB(255, 89, 116, 167);

  static const Color negativeValue = Color.fromARGB(255, 148, 42, 34);
  static const Color positiveValue = Color.fromARGB(255, 34, 148, 42);

  static final ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color(0xFFF9F8FD),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primaryColor: primary,
    appBarTheme: const AppBarTheme(color: appBarColor),
    inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.withOpacity(0.5),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(5),
        )),
    hintColor: Colors.grey.withOpacity(0.5),
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: primary,
        selectionColor: primary.withOpacity(0.5),
        selectionHandleColor: primary),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.grey[800],
    ),
    iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(primary),
      foregroundColor: MaterialStateProperty.all(Colors.grey[800]),
      iconColor: MaterialStateProperty.all(Colors.grey[800]),
    )),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(primary),
      foregroundColor: MaterialStateProperty.all(Colors.grey[800]),
      iconColor: MaterialStateProperty.all(Colors.grey[800]),
    )),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(primary),
      foregroundColor: MaterialStateProperty.all(Colors.grey[800]),
      iconColor: MaterialStateProperty.all(Colors.grey[800]),
    )),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(primary),
      foregroundColor: MaterialStateProperty.all(Colors.grey[800]),
      iconColor: MaterialStateProperty.all(Colors.grey[800]),
    )),
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: primary,
    appBarTheme: const AppBarTheme(color: appBarColor),
    inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.indigo,
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(5))),
  );
}
