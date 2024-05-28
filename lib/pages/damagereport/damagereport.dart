// import 'dart:async';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'dart:io' show File, Platform;
// import 'dart:html' as html;

// class DamageReport extends StatefulWidget {
//   const DamageReport({Key? key}) : super(key: key);

//   @override
//   State<DamageReport> createState() => _DamageReportState();
// }

// class _DamageReportState extends State<DamageReport> {
//   final TextEditingController taxiIdController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   String damageType = "My Accident";
//   late DateTime time = DateTime.now();
//   List<XFile>? images;

//   @override
//   void dispose() {
//     taxiIdController.dispose();
//     descriptionController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             buildTextField("Taxi ID", taxiIdController),
//             buildDropdown(),
//             buildTextField("Description of Events", descriptionController),
//             buildImagePicker(),
//             buildTimePicker(),
//             buildSubmitButton(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildTextField(String hintText, TextEditingController controller) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(
//         border: const OutlineInputBorder(),
//         hintText: hintText,
//       ),
//     );
//   }

//   Widget buildDropdown() {
//     return DropdownButton<String>(
//       value: damageType,
//       items: <String>["My Accident", "Road Accident", "Passenger Accident", "Received Condition"]
//         .map<DropdownMenuItem<String>>((String value) {
//           return DropdownMenuItem<String>(
//             value: value,
//             child: Text(value),
//           );
//         }).toList(),
//       onChanged: (String? newValue) {
//         setState(() {
//           damageType = newValue!;
//         });
//       },
//     );
//   }

//   Widget buildImagePicker() {
//     return ElevatedButton(
//       onPressed: () async {
//         images = await ImagePicker().pickMultiImage();
//         setState(() {});
//       },
//       child: const Text("Upload Images"),
//     );
//   }

//   Widget buildTimePicker() {
//     return ElevatedButton(
//       onPressed: () async {
//         final TimeOfDay? selectedTime = await showTimePicker(
//           context: context,
//           initialTime: TimeOfDay.now(),
//         );
//         if (selectedTime != null) {
//           time = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, selectedTime.hour, selectedTime.minute);
//         }
//         setState(() {});
//       },
//       child: const Text("Select Time"),
//     );
//   }

//   Widget buildSubmitButton() {
//     return ElevatedButton(
//       onPressed: submitReport,
//       child: const Text("Submit Report"),
//     );
//   }

//   Future<Uint8List> compressImage(Uint8List imageData) async {
//     // For web, use HTML canvas to compress the image
//     if (kIsWeb) {
//       final html.CanvasElement canvas = html.CanvasElement();
//       final html.ImageElement img = html.ImageElement();
//       final html.CanvasRenderingContext2D ctx = canvas.context2D;

//       final completer = Completer<Uint8List>();
//       img.src = 'data:image/jpeg;base64,${base64Encode(imageData)}';

//       img.onLoad.listen((event) {
//         canvas.width = (img.width ?? 0) ~/ 2; 
//         canvas.height = (img.height ?? 0) ~/ 2;  

//         ctx.drawImageScaled(img, 0, 0, canvas.width!, canvas.height!);
//         final compressedDataUrl = canvas.toDataUrl('image/jpeg', 0.5);  

//         final compressedData = base64Decode(compressedDataUrl.split(',').last);
//         completer.complete(compressedData);
//       });

//       img.onError.listen((event) {
//         completer.completeError('Image compression failed');
//       });

//       return completer.future;
//     } else {
//       // For mobile, use flutter_image_compress
//       return await FlutterImageCompress.compressWithList(
//         imageData,
//         minWidth: 800,
//         minHeight: 600,
//         quality: 50,
//       );
//     }
//   }

//   Future<void> submitReport() async {
//     final String taxiId = taxiIdController.text.trim();
//     final String description = descriptionController.text.trim();

//     if (taxiId.isEmpty || description.isEmpty || images == null || images!.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text("Please fill all fields and upload images"),
//       ));
//       return;
//     }

//     try {
//       User user = FirebaseAuth.instance.currentUser!;
//       List<String> imageBase64Strings = [];
//       for (var image in images!) {
//         Uint8List imageBytes;
//         if (kIsWeb) {
//           final data = await image.readAsBytes();
//           imageBytes = data;
//         } else {
//           final File file = File(image.path);
//           imageBytes = await file.readAsBytes();
//         }
//        print('Original image size: ${imageBytes.length} bytes');

//         Uint8List compressedBytes = await compressImage(imageBytes);

//         print('Compressed image size: ${compressedBytes.length} bytes');
        
//         if (compressedBytes.length > 1048487) {
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//             content: Text("One of the images is too large even after compression"),
//           ));
//           return;
//         }

//         String base64String = base64Encode(compressedBytes);
//         imageBase64Strings.add(base64String);
//       }
//       await FirebaseFirestore.instance.collection('reports').add({
//         'userId': user.uid,
//         'taxiId': taxiId,
//         'damageType': damageType,
//         'description': description,
//         'images': imageBase64Strings,
//         'time': time,
//         'status': "Posted",
//       });

//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text("Report Submitted"),
//       ));
//     } catch (e) {
//       print('Error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Error: $e'),
//       ));
//     }
//   }
// }

import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
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
  List<XFile>? images;

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
          images = await ImagePicker().pickMultiImage();
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
  return images != null && images!.isNotEmpty
      ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: images!.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return FutureBuilder<String>(
                future: _readImageData(images![index]),
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
                                images!.removeAt(index);
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
      img.src = 'data:image/jpeg;base64,' + base64Encode(imageData);
      img.onLoad.listen((event) {
        canvas.width = img.width!;
        canvas.height = img.height!;
        ctx.drawImage(img, 0, 0);
        final String dataUrl = canvas.toDataUrl('image/jpeg', 0.5);
        final String base64 = dataUrl.split(',').last;
        completer.complete(base64Decode(base64));
      });
      return completer.future;
    } else {
      final result = await FlutterImageCompress.compressWithList(
        imageData,
        minWidth: 600,
        minHeight: 600,
        quality: 88,
      );
      return result;
    }
  }

  Future<void> submitReport() async {
    if (taxiIdController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        images == null ||
        images!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and upload at least one image.')),
      );
      return;
    }

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are not logged in.')),
        );
        return;
      }

      final List<String> base64Images = [];
      for (final image in images!) {
        final Uint8List imageData = await image.readAsBytes();
        final Uint8List compressedImage = await compressImage(imageData);
        base64Images.add(base64Encode(compressedImage));
      }

      await FirebaseFirestore.instance.collection('reports').add({
        'taxiId': taxiIdController.text,
        'description': descriptionController.text,
        'damageType': damageType,
        'time': time,
        'images': base64Images,
        'userId': user.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit report: $e')),
      );
    }
  }
}
