import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html;
import 'dart:io' show File, Platform;

class DamageReport extends StatefulWidget {
  const DamageReport({super.key});

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
      List<String> imageUrls = [];
      for (var image in images!) {
        final Reference ref = FirebaseStorage.instance.ref().child('images/${DateTime.now().toIso8601String()}.jpg');
        UploadTask uploadTask;
        if (kIsWeb) {
          try {
            final data = await image.readAsBytes();
            uploadTask = ref.putData(data);
          } catch (e) {
            print('Error reading image as bytes: $e');
            return;
          }
        } else {
          final File file = File(image.path);
          uploadTask = ref.putFile(file);
        }
        final TaskSnapshot snapshot = await uploadTask;
        final String url = await snapshot.ref.getDownloadURL();
        imageUrls.add(url);
      }
      await FirebaseFirestore.instance.collection('reports').add({
        'userId': user.uid,
        'taxiId': taxiId,
        'damageType': damageType,
        'description': description,
        'images': imageUrls,
        'time': time,
        'status': "Posted",
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Report Submitted"),
      ));
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }
}