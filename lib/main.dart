import 'package:fixaxi/pages/damagehistory/damagehistory.dart';
import 'package:fixaxi/pages/damagereport/damagereport.dart';
import 'package:fixaxi/pages/dashboard/dashboard.dart';
import 'package:fixaxi/pages/profile/profile.dart';
import 'package:fixaxi/pages/register/register.dart';
import 'package:fixaxi/pages/splashscreen/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:fixaxi/pages/login/login.dart';
import 'pages/landing/landingPage.dart';

//Firebase stuff
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Firebase stuff too
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/landingPage': (context) => const landingPage(),
        '/signIn':(context) => SignInPage(),
        '/signUp':(context) => SignUpPage(),
        '/dashboard':(context) => const DashboardPage(),
        '/profile':(context) => const ProfilePage(),
        '/damagereport':(context) => const DamageReport(),
        '/damagehistory':(context) => const DamageHistory(),
      },
    );
  }
}
