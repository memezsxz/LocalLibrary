import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'app_palette.dart';

class AppTheme {
  // static _inputBorder([Color color = AppPalette.borderColor]) =>
  //     OutlineInputBorder(
  //       borderSide: BorderSide(color: color, width: 3),
  //       borderRadius: BorderRadius.all(Radius.circular(10)),
  //     );
  //
  static final base = ThemeData.light();

  static final paragraphsStyle =  Style(
    margin: Margins.zero,
    // remove default <p> margins
    padding: HtmlPaddings.zero,
    lineHeight: LineHeight.rem(1.4),
    fontSize: FontSize.larger,
    color: Colors.black,
    // direction: p.direction.toTextDirection,
  );

  static final lightMode = base.copyWith(
    scaffoldBackgroundColor: AppPalette.background,
    primaryTextTheme: base.primaryTextTheme.apply(fontFamily: 'CherrySwash'),

    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppPalette.primary,
      selectionColor: AppPalette.primary.withOpacity(0.2),
      selectionHandleColor: AppPalette.primary,
    ),

    textTheme: ThemeData.dark().textTheme
        .apply(fontFamily: 'CherrySwash', decoration: TextDecoration.none)
        .copyWith(
          titleLarge: ThemeData.dark().textTheme.titleLarge?.copyWith(
            fontFamily: 'Courier New',
            color: AppPalette.primary,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),

      titleMedium: ThemeData.dark().textTheme.titleLarge?.copyWith(
        fontFamily: 'CherrySwash',
        color: AppPalette.primary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),

      labelLarge: TextStyle(
            fontFamily: 'CherrySwash',
            // color: AppPalette.primary,
            // fontSize: 22,
          ),

          labelMedium: TextStyle(
            fontFamily: 'Courier New',
            color: Colors.black,
            // fontSize: 22,
          ),
        ),

    // style: TextStyle(
    //   color: AppPalette.primary,
    //   fontFamily: "CherrySwash",
    //   decoration: TextDecoration.none,
    //   fontSize: 30,
    //   fontWeight: FontWeight.bold,
    // ),

    //
    //   appBarTheme: AppBarTheme(color: AppPalette.backgroundColor),
    //
    //   textTheme: ThemeData.dark().textTheme.copyWith(
    //     titleLarge: ThemeData.dark().textTheme.titleLarge?.copyWith(
    //       fontSize: 50,
    //       fontWeight: FontWeight.bold,
    //     ),
    //   ),
    //
    //   inputDecorationTheme: InputDecorationTheme(
    //     contentPadding: EdgeInsets.all(25),
    //     enabledBorder: _inputBorder(),
    //     focusedBorder: _inputBorder(AppPalette.gradient2),
    //   ),
  );
}
