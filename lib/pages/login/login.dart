import 'package:fixaxi/pages/dashboard/dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fixaxi/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixaxi/pages/register/register.dart'; // import the register.dart file

class SignInPage extends StatefulWidget {
  SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _email, _password;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
            top: 300,
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Welcome Text
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          fontFamily: "Cupertino"),
                    ),
                    //SizedBox
                    const SizedBox(height: 10),
                    //Sign in credentials Text
                    const Text(
                      "Please sign in with the credentials below",
                    ),
                    //SizedBox
                    const SizedBox(
                      height: 20,
                    ),
                    //Email Input Field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextFormField(
                            obscureText: false, // make this false
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Email",
                            ),
                            validator: (input) {
                              if(input!.isEmpty){
                                return 'Please type an email';
                              }
                              return null;
                            },
                            onSaved: (input) => _email = input!,
                          ),
                        ),
                      ),
                    ),
                    //SizedBox
                    const SizedBox(
                      height: 10,
                    ),
                    //Password Input Field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Password",
                            ),
                            validator: (input) {
                              if(input!.length < 6){
                                return 'Your password needs to be at least 6 characters';
                              }
                              return null;
                            },
                            onSaved: (input) => _password = input!,
                            obscureText: true,
                          ),
                        ),
                      ),
                    ),
                    //SizedBox
                    const SizedBox(height: 10.0),
                    //Sign in Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        child: Padding(
  padding: const EdgeInsets.symmetric(horizontal: 25),
  child: GestureDetector(
    onTap: signIn,
    child: Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF2E86AB), // Same color as the Sign Up button
            Color(0xFF36D1DC), // Same color as the Sign Up button
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          "Sign in",
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
      ),
    ),
  ),
),
                      ),
                    ),
                    //SizedBox
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Not a member?",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUpPage()),
                            );
                          },
                          child: Text(
                            "Sign Up Now",
                            style: TextStyle(
                                color: Colors.blue[300],
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Future<void> signIn() async {
  final formState = _formKey.currentState;
  if(formState!.validate()){
    formState.save();
    try{
      // ignore: unused_local_variable
      UserCredential user = await _auth.signInWithEmailAndPassword(email: _email, password: _password);
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
    } catch(e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to sign in. Please check your credentials."),
      ));
    }
  }
}}
