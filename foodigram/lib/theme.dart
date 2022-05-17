import 'package:flutter/material.dart';

ThemeData customTheme() {
  return ThemeData(
    fontFamily: "Open Sans",
    textTheme: const TextTheme(
      headline6: TextStyle(
          color: Color(0xfff1f5f8),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: "Open Sans"),
      headline5: TextStyle(
          color: Color(0xfff1f5f8),
          fontSize: 17,
          fontWeight: FontWeight.normal,
          fontFamily: "Open Sans"),
      headline4: TextStyle(
          color: Color(0xfff1f5f8),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: "Open Sans"),
      headline3: TextStyle(
          color: Color(0xfff1f5f8),
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: "Open Sans"),
      headline2: TextStyle(
          color: Color(0xfff1f5f8),
          fontSize: 14,
          fontWeight: FontWeight.w300,
          fontFamily: "Open Sans"),
      subtitle2: TextStyle(
          color: Color(0xFF8C8C8C),
          fontSize: 13,
          fontWeight: FontWeight.normal,
          fontFamily: "Open Sans"),
      headline1: TextStyle(
          color: Color(0xfff1f5f8),
          fontSize: 13,
          fontWeight: FontWeight.normal,
          fontFamily: "Open Sans"),
      subtitle1: TextStyle(
          color: Color(0xFF8C8C8C),
          fontSize: 13,
          fontWeight: FontWeight.normal,
          fontFamily: "Open Sans"),
      button: TextStyle(
          color: Color(0xff76dce3),
          fontSize: 15,
          fontWeight: FontWeight.bold,
          fontFamily: "Open Sans"),
    ),
    appBarTheme: const AppBarTheme(
      color: Color(0xFFa9b5a9),
      titleTextStyle: TextStyle(
        color: Color(0xFFf1f5f8),
        fontSize: 25,
        fontWeight: FontWeight.normal,
        fontFamily: "Chewy",
      ),
    ),
    buttonTheme: ButtonThemeData(
        buttonColor: const Color(0xFF0CE8CE),
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
    primaryColor: const Color(0xFFf1f5f8),
    canvasColor: Colors.grey,
    cardColor: const Color(0xffa9b5a9),
    unselectedWidgetColor: Colors.white,
    scaffoldBackgroundColor: const Color(0xFFc89b9b),
    backgroundColor: const Color(0xFFc89b9b),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Colors.red,
      actionTextColor: Colors.white,
      contentTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          fontFamily: "Open Sans"),
    ),
    bottomSheetTheme:
        const BottomSheetThemeData(backgroundColor: Color(0xFF1C2028)),
    inputDecorationTheme: const InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(horizontal: 13, vertical: 5),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        borderSide: BorderSide(width: 1, color: Color(0xFFcbd1cf)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        borderSide: BorderSide(
          width: 2,
          color: Color(0xFFcbd1cf),
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        borderSide: BorderSide(
          width: 1,
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        borderSide: BorderSide(width: 2, color: Colors.red),
      ),
      labelStyle: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.normal,
        fontFamily: "Open Sans",
      ),
      hintStyle: TextStyle(color: Color(0xFFf1f5f8)),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: const Color(0xFFa9b5a9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    colorScheme: const ColorScheme(
      primary: Color(0xFFa9b5a9),
      secondary: Color(0xFFcbd1cf),
      surface: Colors.transparent,
      background: Color(0xFFFAFAFA),
      error: Colors.red,
      onPrimary: Color(0xFFf1f5f8),
      onSecondary: Color(0xFFf1f5f8),
      onSurface: Colors.transparent,
      onBackground: Colors.transparent,
      onError: Colors.red,
      brightness: Brightness.light,
    ),
    textSelectionTheme:
        const TextSelectionThemeData(cursorColor: Color(0xFFf1f5f8)),
  );
}
