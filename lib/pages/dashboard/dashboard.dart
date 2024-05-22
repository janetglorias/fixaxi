import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fixaxi/constants/colors.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
                // image: DecorationImage(image: AssetImage('assets/LoginPageBG.jpg'), fit: BoxFit.cover)
                color: AppColors.blue4,
              ),
        width: screenWidth,
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.25,
              decoration: const BoxDecoration(
                // image: DecorationImage(image: AssetImage('assets/LoginPageBG.jpg'), fit: BoxFit.cover)
                color: AppColors.blue4,
              ),
            ),
            //Main Dashboard Content
            Center(
              child: Container(
              width: screenWidth,
              height: screenHeight * 0.75,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                color: Colors.white,
              ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Row One
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: screenHeight * 0.22,
                          width: screenHeight * 0.22,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.blue0,
                          ),
                          child: const Center(
                            child: Text("Testing"),
                          ),
                        ),
                        const SizedBox(width: 40,),
                        Container(
                          height: screenHeight * 0.22,
                          width: screenHeight * 0.22,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.blue0,
                          ),
                          child: const Center(
                            child: Text("Testing"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20,),
                    //Row TWo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: screenHeight * 0.22,
                          width: screenHeight * 0.22,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.blue0,
                          ),
                          child: const Center(
                            child: Text("Testing"),
                          ),
                        ),
                        const SizedBox(width: 40,),
                        Container(
                          height: screenHeight * 0.22,
                          width: screenHeight * 0.22,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.blue0,
                          ),
                          child: const Center(
                            child: Text("Testing"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: screenHeight * 0.22,
                          width: screenHeight * 0.22,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.blue0,
                          ),
                          child: const Center(
                            child: Text("Testing"),
                          ),
                        ),
                        const SizedBox(width: 40,),
                        Container(
                          height: screenHeight * 0.22,
                          width: screenHeight * 0.22,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.blue0,
                          ),
                          child: const Center(
                            child: Text("Testing"),
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
