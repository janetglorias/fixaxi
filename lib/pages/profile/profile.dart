import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import DateFormat

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userDoc.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          DateTime dob = (data['dob'] as Timestamp).toDate(); // Convert timestamp to DateTime
          String formattedDOB = DateFormat.yMMMMd().format(dob); // Format DateTime to desired string representation

          return ListTile(
            title: Text('First Name: ${data['firstName']}, Last Name: ${data['lastName']}'),
            subtitle: Text('Email: ${data['email']}\nDOB: $formattedDOB'), // Use formatted date
          );
        },
      ),
    );
  }
}