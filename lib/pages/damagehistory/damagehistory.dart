import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DamageHistory extends StatelessWidget {
  const DamageHistory({Key? key}) : super(key: key);

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

                DateTime? time;
                String formattedTime;
                try {
                  time = (data['time'] as Timestamp?)?.toDate();
                  formattedTime = time != null ? DateFormat.yMMMMd().add_jm().format(time) : 'No time data';
                } catch (e) {
                  formattedTime = 'No time data';
                }

                List<dynamic>? imageBase64Strings = data['images'] as List<dynamic>?;
                String status = data['status'] ?? 'No status';
                String damageType = data['damageType'] ?? 'No damage type';
                String description = data['description'] ?? 'No description';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: ListTile(
                    title: Text(damageType),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(description),
                        Text('Status: $status'),
                      ],
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(formattedTime),
                        if (imageBase64Strings != null && imageBase64Strings.isNotEmpty)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PhotoGridPage(images: imageBase64Strings),
                                ),
                              );
                            },
                            child: const Text('View Photos'),
                          )
                        else
                          const Text('No images available'),
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


//DISPLAY PHOTOS PAGE HERE

class PhotoGridPage extends StatelessWidget {
  final List<dynamic> images;

  const PhotoGridPage({Key? key, required this.images}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GridView.builder(
        itemCount: images.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          if (images[index] != null) {
            try {
              String base64String = images[index];
              if (base64String.startsWith('data:image/jpeg;base64,')) {
                base64String = base64String.substring('data:image/jpeg;base64,'.length);
              }
              Uint8List bytes = base64Decode(base64String);
              return Image.memory(
                bytes,
                fit: BoxFit.contain,
              );
            } catch (e) {
              print('Failed to decode image: $e');
              return const Text('Invalid image data');
            }
          } else {
            return const Text('No image');
          }
        },
      ),
    );
  }
}