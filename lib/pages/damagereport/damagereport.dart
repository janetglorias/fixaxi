import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' show File, Platform;
import 'dart:html' as html;

class DamageReport extends StatefulWidget {
  @override
  _DamageReportState createState() => _DamageReportState();
}

class _DamageReportState extends State<DamageReport> {
  final TextEditingController taxiIdController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String damageType = "My Accident";
  late DateTime time = DateTime.now();
  List<XFile> images = [];

  @override
  void dispose() {
    taxiIdController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
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
          child: Padding(
            padding: const EdgeInsets.only(
              top: 150,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Report your Damages",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          fontFamily: "Cupertino"),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "The HQ will handle them for you",
                    ),
                    const SizedBox(height: 20),
                    buildTextField("Taxi ID", taxiIdController),
                    const SizedBox(height: 10),
                    buildDropdown(),
                    const SizedBox(height: 10),
                    buildTextField("Description of Events", descriptionController),
                    const SizedBox(height: 10),
                    buildImagePicker(),
                    const SizedBox(height: 10),
                    buildImagePreview(),
                    const SizedBox(height: 10),
                    buildTimePicker(),
                    const SizedBox(height: 10),
                    buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hintText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: DropdownButton<String>(
            value: damageType,
            items: <String>["My Accident", "Road Accident", "Passenger Accident", "Received Condition"]
              .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                damageType = newValue!;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: GestureDetector(
        onTap: () async {
          final List<XFile>? selectedImages = await ImagePicker().pickMultiImage(
            maxHeight: 800,
            maxWidth: 800,
            imageQuality: 85,
          );
          if (selectedImages != null) {
            setState(() {
              images.addAll(selectedImages);
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF2E86AB), 
                Color(0xFF36D1DC),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              "Upload Images",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImagePreview() {
    return images.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return FutureBuilder<String>(
                  future: _readImageData(images[index]),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Stack(
                        children: [
                          Image.network(snapshot.data!),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  images.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                );
              },
            ),
          )
        : Container();
  }

Future<String> _readImageData(XFile file) async {
  final bytes = await file.readAsBytes();
  final base64Image = base64Encode(bytes);
  return 'data:image/png;base64,$base64Image';
}

  Widget buildTimePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: GestureDetector(
        onTap: () async {
          final TimeOfDay? selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (selectedTime != null) {
            time = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, selectedTime.hour, selectedTime.minute);
          }
          setState(() {});
        },
        child: Container(
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF2E86AB), 
                Color(0xFF36D1DC), 
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              "Select Time",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: GestureDetector(
        onTap: submitReport,
        child: Container(
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF2E86AB), 
                Color(0xFF36D1DC), 
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              "Submit Report",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Future<Uint8List> compressImage(Uint8List imageData) async {
    if (kIsWeb) {
      final html.CanvasElement canvas = html.CanvasElement();
      final html.ImageElement img = html.ImageElement();
      final html.CanvasRenderingContext2D ctx = canvas.context2D;

      final completer = Completer<Uint8List>();
      img.onLoad.listen((event) {
        canvas.width = img.width;
        canvas.height = img.height;
        ctx.drawImage(img, 0, 0);
        final dataUrl = canvas.toDataUrl('image/jpeg', 0.8);
        final base64Data = dataUrl.replaceFirst(RegExp(r'data:image/jpeg;base64,'), '');
        final compressedData = base64Decode(base64Data);
        completer.complete(compressedData);
      });
      img.src = 'data:image/jpeg;base64,${base64Encode(imageData)}';

      return completer.future;
    } else {
      return FlutterImageCompress.compressWithList(
        imageData,
        quality: 85,
        format: CompressFormat.jpeg,
      );
    }
  }

Future<void> submitReport() async {
  try {
    final String taxiId = taxiIdController.text;
    final String description = descriptionController.text;
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final List<String> imageUrls = [];

    for (final image in images) {
      final bytes = await image.readAsBytes();
      final compressedBytes = await compressImage(bytes);
      final base64Image = base64Encode(compressedBytes);
      imageUrls.add('data:image/jpeg;base64,$base64Image');
    }

    final report = {
      'taxiId': taxiId,
      'description': description,
      'damageType': damageType,
      'time': time,
      'userId': userId,
      'images': imageUrls,
      'status': 'Posted', // Add this line
    };

    await FirebaseFirestore.instance.collection('reports').add(report);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data sent to Firebase successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to send data to Firebase.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

}