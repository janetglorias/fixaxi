import 'package:fixaxi/pages/dashboard/dashboard.dart';
import 'package:fixaxi/pages/register/register.dart';
import 'package:flutter/material.dart';
import 'package:fixaxi/pages/login/login.dart';
import 'pages/landing/landingPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => const landingPage(),
        '/signIn':(context) => SignInPage(),
        '/signUp':(context) => SignUpPage(),
        '/dashboard':(context) => DashboardPage(),
      },
    );
  }
}


