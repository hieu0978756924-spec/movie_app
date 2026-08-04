import 'package:flutter/material.dart';



class AppTheme {

  static ThemeData darkTheme = ThemeData(

    useMaterial3: true,



    brightness: Brightness.dark,



    colorScheme: ColorScheme.fromSeed(

      seedColor: Colors.red,

      brightness: Brightness.dark,

    ),



    scaffoldBackgroundColor: const Color(0xFF121212),



    appBarTheme: const AppBarTheme(

      backgroundColor: Color(0xFF121212),

      foregroundColor: Colors.white,

      centerTitle: true,

      elevation: 0,

    ),



    cardTheme: CardThemeData(

      color: const Color(0xFF1E1E1E),

      elevation: 5,

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(20),

      ),

    ),



    elevatedButtonTheme: ElevatedButtonThemeData(

      style: ElevatedButton.styleFrom(

        backgroundColor: Colors.red,

        foregroundColor: Colors.white,

        shape: RoundedRectangleBorder(

          borderRadius: BorderRadius.circular(12),

        ),

      ),

    ),



    bottomNavigationBarTheme: const BottomNavigationBarThemeData(

      backgroundColor: Color(0xFF121212),

      selectedItemColor: Colors.red,

      unselectedItemColor: Colors.grey,

      type: BottomNavigationBarType.fixed,

    ),



    chipTheme: ChipThemeData(

      backgroundColor: Colors.grey.shade900,

      selectedColor: Colors.red,

      labelStyle: const TextStyle(

        color: Colors.white,

      ),

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(25),

      ),

    ),

  );

} 