import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:convert';
import 'dart:typed_data';
// ignore: unused_shown_name
import 'dart:io' show File, Platform;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  late DateTime dob = DateTime.now();
  String? profilePictureBase64;

  @override
  void initState() {
    super.initState();
    fetchProfilePicture();
  }

  Future<void> fetchProfilePicture() async {
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      setState(() {
        profilePictureBase64 = userDoc['profilePicture'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (currentUser == null) {
      return const Center(
        child: Text('Please sign in to view profile'),
      );
    }

    DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(currentUser?.uid);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF4A90E2), 
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(''),
          backgroundColor: Colors.transparent.withOpacity(0),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 150),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: screenWidth,
                    margin: const EdgeInsets.only(top: 50),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: Colors.white,
                    ),
                    child: SizedBox(
                      height: screenHeight - 260,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: userDoc.snapshots(),
                            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return const Text('Something went wrong');
                              }

                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }

                              Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                              dob = (data['dob'] as Timestamp).toDate();
                              String formattedDOB = DateFormat.yMMMMd().format(dob);

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 60),
                                  Text(
                                    "${data['firstName']} ${data['lastName']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                      fontFamily: "Cupertino",
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text("Date of Birth: $formattedDOB"),
                                  const SizedBox(height: 10),
                                  Text("Email: ${data['email']}"),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (currentUser?.email != null) {
                                        FirebaseAuth.instance.sendPasswordResetEmail(email: currentUser!.email!);
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
                                    child: const Text('Reset Password'),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
                                      if (image != null) {
                                        Uint8List imageBytes;
                                        if (kIsWeb) {
                                          final data = await image.readAsBytes();
                                          imageBytes = data;
                                        } else {
                                          final File file = File(image.path);
                                          imageBytes = await file.readAsBytes();
                                        }
                                        Uint8List compressedBytes = await compressImage(imageBytes);
                                        profilePictureBase64 = base64Encode(compressedBytes);
                                        setState(() {});

                                        if (currentUser != null) {
                                          FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
                                            'profilePicture': profilePictureBase64,
                                          });
                                        }
                                      }
                                    },
                                    child: const Text('Upload Profile Picture'),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profilePictureBase64 != null
                        ? MemoryImage(base64Decode(profilePictureBase64!)) as ImageProvider<Object>
                        : const NetworkImage(
                            'https://i.pinimg.com/564x/16/63/b1/1663b133812be974e04c421809ab5a37.jpg'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> compressImage(Uint8List imageData) async {
    // For web, use HTML canvas to compress the image
    if (kIsWeb) {
      final html.CanvasElement canvas = html.CanvasElement();
      final html.ImageElement img = html.ImageElement();
      final html.CanvasRenderingContext2D ctx = canvas.context2D;

      final completer = Completer<Uint8List>();
      img.src = 'data:image/jpeg;base64,${base64Encode(imageData)}';

      img.onLoad.listen((event) {
        canvas.width = (img.width ?? 0) ~/ 2;
        canvas.height = (img.height ?? 0) ~/ 2;

        ctx.drawImageScaled(img, 0, 0, canvas.width!, canvas.height!);
        final compressedDataUrl = canvas.toDataUrl('image/jpeg', 0.5);

        final compressedData = base64Decode(compressedDataUrl.split(',').last);
        completer.complete(compressedData);
      });

      img.onError.listen((event) {
        completer.completeError('Image compression failed');
      });

      return completer.future;
    } else {
      return await FlutterImageCompress.compressWithList(
        imageData,
        minWidth: 800,
        minHeight: 600,
        quality: 50,
      );
    }
  }
}