import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:nb_utils/nb_utils.dart';

class AppTheme {
  //
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    //primarySwatch: createMaterialColor(kPrimary),
    tabBarTheme: TabBarThemeData(
        labelStyle: primaryTextStyle(color: kPrimary), labelColor: kPrimary),
    primaryColor: kPrimary,
    scaffoldBackgroundColor: mobileBackgroundColor,
    fontFamily: GoogleFonts.roboto().fontFamily,
    bottomNavigationBarTheme:
        const BottomNavigationBarThemeData(backgroundColor: Colors.white),
    iconTheme: const IconThemeData(color: scaffoldSecondaryDark),
    textTheme: TextTheme(titleLarge: boldTextStyle()),
    dialogBackgroundColor: Colors.white,
    unselectedWidgetColor: Colors.black,
    dividerColor: viewLineColor,
    cardColor: mobileBackgroundColor2,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: mobileBackgroundColor),
    ),
    dialogTheme: DialogThemeData(shape: dialogShape()),
  ).copyWith(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    // primarySwatch: createMaterialColor(kPrimary),
    tabBarTheme: TabBarThemeData(
        labelStyle: primaryTextStyle(color: kPrimary), labelColor: kPrimary),
    primaryColor: kPrimary,
    scaffoldBackgroundColor: scaffoldColorDark,
    fontFamily: GoogleFonts.roboto().fontFamily,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: scaffoldSecondaryDark),
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme:
        const TextTheme(titleLarge: TextStyle(color: textSecondaryColor)),
    dialogBackgroundColor: scaffoldSecondaryDark,
    unselectedWidgetColor: Colors.white60,
    dividerColor: Colors.white12,
    cardColor: scaffoldSecondaryDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: scaffoldColorDark,
      systemOverlayStyle:
          SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
    ),
    dialogTheme: DialogThemeData(shape: dialogShape()),
  ).copyWith(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
