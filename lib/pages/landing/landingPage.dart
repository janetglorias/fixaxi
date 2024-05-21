import 'package:fixaxi/pages/login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fixaxi/constants/colors.dart';

class landingPage extends StatelessWidget {
  const landingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // image: DecorationImage(image: AssetImage('assets/LoginPageBG.jpg'), fit: BoxFit.cover)
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.blue4,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 200,
          ),
          child: Center(
            child: Container(
              width: screenWidth,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Welcome Text
                  Container(
                    height: 150,
                    width: 150,
                    child: Image.asset('assets/images/fixaxiLogo.png'),
                  ),
                  //Text
                  const Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      "Fixaxi is a mobile application designed exclusively for taxi drivers. Our mission is to streamline the insurance claim process when their vehicles are damaged. With Fixaxi, drivers can easily report incidents, upload photos, and submit claims directly from their phones. Trust Fixaxi to be your reliable partner in times of need.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  //SizedBox
                  const SizedBox(
                    height: 20,
                  ),
                  //Sign in Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/signIn');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          color: AppColors.blue8,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  //SizedBox
                  const SizedBox(height: 10),
                  //Sign up Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/signUp');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          color: AppColors.blue8,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  //SizedBox
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
