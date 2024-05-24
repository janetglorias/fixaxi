import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DamageHistory extends StatelessWidget {
  const DamageHistory({Key? key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Please sign in to view damage history'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Damage History'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No damage reports found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot document = snapshot.data!.docs[index];
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                DateTime time = (data['time'] as Timestamp).toDate();
                String formattedTime = DateFormat.yMMMMd().add_jm().format(time);
                
                List<dynamic> imageBase64Strings = data['images'];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: ListTile(
                    title: Text(data['damageType']),
                    subtitle: Text(data['description']),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(formattedTime),
                        ElevatedButton(
                          onPressed: () {
                            // Handle button press to display image
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageViewPage(
                                  imageBase64Strings: imageBase64Strings,
                                ),
                              ),
                            );
                          },
                          child: const Text('View Image'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ImageViewPage extends StatelessWidget {
  final List<dynamic> imageBase64Strings;

  const ImageViewPage({Key? key, required this.imageBase64Strings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image View'),
      ),
      body: ListView.builder(
        itemCount: imageBase64Strings.length,
        itemBuilder: (context, index) {
          String base64String = imageBase64Strings[index];
          Uint8List bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            fit: BoxFit.contain,
          );
        },
      ),
    );
  }
}