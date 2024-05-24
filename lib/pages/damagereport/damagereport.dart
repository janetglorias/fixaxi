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
  const DamageReport({Key? key}) : super(key: key);

  @override
  State<DamageReport> createState() => _DamageReportState();
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildTextField("Taxi ID", taxiIdController),
            buildDropdown(),
            buildTextField("Description of Events", descriptionController),
            buildImagePicker(),
            buildTimePicker(),
            buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String hintText, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: hintText,
      ),
    );
  }

  Widget buildDropdown() {
    return DropdownButton<String>(
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
    );
  }

  Widget buildImagePicker() {
    return ElevatedButton(
      onPressed: () async {
        images = await ImagePicker().pickMultiImage();
        setState(() {});
      },
      child: const Text("Upload Images"),
    );
  }

  Widget buildTimePicker() {
    return ElevatedButton(
      onPressed: () async {
        final TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (selectedTime != null) {
          time = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, selectedTime.hour, selectedTime.minute);
        }
        setState(() {});
      },
      child: const Text("Select Time"),
    );
  }

  Widget buildSubmitButton() {
    return ElevatedButton(
      onPressed: submitReport,
      child: const Text("Submit Report"),
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
      // For mobile, use flutter_image_compress
      return await FlutterImageCompress.compressWithList(
        imageData,
        minWidth: 800,
        minHeight: 600,
        quality: 50,
      );
    }
  }

  Future<void> submitReport() async {
    final String taxiId = taxiIdController.text.trim();
    final String description = descriptionController.text.trim();

    if (taxiId.isEmpty || description.isEmpty || images == null || images!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill all fields and upload images"),
      ));
      return;
    }

    try {
      User user = FirebaseAuth.instance.currentUser!;
      List<String> imageBase64Strings = [];
      for (var image in images!) {
        Uint8List imageBytes;
        if (kIsWeb) {
          final data = await image.readAsBytes();
          imageBytes = data;
        } else {
          final File file = File(image.path);
          imageBytes = await file.readAsBytes();
        }
       print('Original image size: ${imageBytes.length} bytes');

        Uint8List compressedBytes = await compressImage(imageBytes);

        print('Compressed image size: ${compressedBytes.length} bytes');
        
        if (compressedBytes.length > 1048487) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("One of the images is too large even after compression"),
          ));
          return;
        }

        String base64String = base64Encode(compressedBytes);
        imageBase64Strings.add(base64String);
      }
      await FirebaseFirestore.instance.collection('reports').add({
        'userId': user.uid,
        'taxiId': taxiId,
        'damageType': damageType,
        'description': description,
        'images': imageBase64Strings,
        'time': time,
        'status': "Posted",
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Report Submitted"),
      ));
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }
  }
}
