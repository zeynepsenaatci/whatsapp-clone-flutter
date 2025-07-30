import 'package:flutter/material.dart';
import 'package:whatsappnew/common/theme/dark_theme.dart';
import 'package:whatsappnew/common/theme/light_theme.dart';
import 'package:whatsappnew/feature/auth/pages/home_page.dart';
//import 'package:whatsappnew/feature/auth/pages/verification_page.dart';
//import 'package:whatsappnew/feature/auth/pages/login_page.dart';
//import 'package:whatsappnew/feature/auth/pages/user_info_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WhatsApp Clone',
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: ThemeMode.system,

      home: HomePage(),
    );
  }
}
