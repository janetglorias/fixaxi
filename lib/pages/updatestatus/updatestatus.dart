import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UpdateStatus extends StatelessWidget {
  const UpdateStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Status'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('reports').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No reports found'));
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
                String taxiId = data['taxiId'] ?? 'No taxi ID';

                List<String> statusOptions = ['Posted', 'In Review', 'Approved', 'Rejected', 'Processed', 'Under Maintenance', 'Ready for Collection'];
                if (!statusOptions.contains(status)) {
                  status = statusOptions[0]; // Set to the first option as default
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: ListTile(
                    title: Text(damageType),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Taxi ID: $taxiId'),
                        Text(description),
                        Text('Status: $status'),
                        DropdownButton<String>(
                          value: status,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              FirebaseFirestore.instance
                                  .collection('reports')
                                  .doc(document.id)
                                  .update({'status': newValue});
                            }
                          },
                          items: statusOptions.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
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
