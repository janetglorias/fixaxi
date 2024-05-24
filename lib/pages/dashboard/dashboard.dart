import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fixaxi/constants/colors.dart';
import 'package:fixaxi/pages/damagehistory/damagehistory.dart';
import 'package:fixaxi/pages/damagereport/damagereport.dart';
import 'package:fixaxi/pages/profile/profile.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for the authentication state, display a loading indicator
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.hasData && snapshot.data != null) {
            // User is logged in, show the dashboard
            return _buildDashboard(context);
          } else {
            // User is not logged in, navigate to the login page
            // You can replace `LoginPage()` with your actual login page
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text('Sign in'),
                ),
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.blue4,
        ),
        width: screenWidth,
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.25,
              decoration: const BoxDecoration(
                color: AppColors.blue4,
              ),
            ),
            Center(
              child: Container(
                width: screenWidth,
                height: screenHeight * 0.75,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Row One
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DamageReport()),
                            );
                          },
                          child: Container(
                            height: screenHeight * 0.22,
                            width: screenHeight * 0.22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.blue0,
                            ),
                            child: const Center(
                              child: Text(
                                "Report Damages",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 40,),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DamageHistory()),
                            );
                          },
                          child: Container(
                            height: screenHeight * 0.22,
                            width: screenHeight * 0.22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.blue0,
                            ),
                            child: const Center(
                              child: Text(
                                "Damage History",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20,),
                    //Row Two
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProfilePage()),
                            );
                          },
                          child: Container(
                            height: screenHeight * 0.22,
                            width: screenHeight * 0.22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.blue0,
                            ),
                            child: const Center(
                              child: Text(
                                "My Profile",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}