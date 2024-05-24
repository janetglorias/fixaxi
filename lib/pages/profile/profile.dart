import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; 

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

    if (currentUser == null) {
      // Handle the case where the user is not authenticated
      return const Center(
        child: Text('Please sign in to view profile'),
      );
    }

    DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        actions: [
          IconButton(
            onPressed: () {
              // Reset password functionality
              if (currentUser.email != null) {
                FirebaseAuth.instance.sendPasswordResetEmail(email: currentUser.email!);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Password Reset'),
                      content: const Text('Password reset email sent successfully.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Error'),
                      content: const Text('No email address associated with this account.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            icon: const Icon(Icons.lock),
            tooltip: 'Reset Password',
          ),
        ],
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