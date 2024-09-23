/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */
 
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:quickcheck/Screens/CarPermits.dart';
import 'package:quickcheck/components/Buttons.dart';
import 'dart:async';
import 'package:quickcheck/main.dart';
import 'package:quickcheck/utils/GlobalFunctions.dart';

class LicensePlateScannerScreen extends StatefulWidget {
  @override
  _LicensePlateScannerScreenState createState() =>
      _LicensePlateScannerScreenState();
}

class _LicensePlateScannerScreenState extends State<LicensePlateScannerScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool isDetecting = false;
  String detectedPlate = "";

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      cameras[selectcamera], // CHANGE TO 0 IF REAR ON REAL PHONE
      ResolutionPreset.ultraHigh,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> scanLicensePlate() async {
    if (!_controller.value.isInitialized) {
      return;
    }
    try {
      final image = await _controller.takePicture();
      await detectLicensePlate(image.path);
    } catch (e) {
      print('Error occurred while taking picture: $e');
      Exceptionsnackbar(context, "Error occurred while taking picture");
    }
  }

  Future<void> detectLicensePlate(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      String plate = extractLicensePlate(recognizedText.text);
      setState(() {
        detectedPlate = plate;
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CarPermitsScreen(
                search: plate.isNotEmpty ? plate : '',
              ),
            ));
      });
    } catch (e) {
      print('Failed to recognize text from the image: $e');
      Exceptionsnackbar(context, "Failed to recognize text from the image");
    } finally {
      textRecognizer.close();
    }
  }

  String extractLicensePlate(String rawText) {
    RegExp regExp = RegExp(r'\b\d{1,2}-\d{1,5}\b'); // Jordanian plate format
    Iterable<Match> matches = regExp.allMatches(rawText);
    if (matches.isNotEmpty) {
      return matches.first.group(0) ?? "";
    }
    return "No valid plate detected";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 51, 54, 97),
        title: const Text(
          "License Plate Scanner",
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        ),
        leading: const Back_Button(),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: const Color.fromARGB(255, 74, 76, 133),
            height: 1.0,
          ),
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(
                  child: CameraPreview(_controller),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: scanLicensePlate,
        tooltip: 'Detect License Plate',
        child: const Icon(Icons.camera),
      ),
    );
  }
}
