/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:quickcheck/Screens/ID_check_screen.dart';
import 'package:quickcheck/components/Buttons.dart';
import 'dart:async';
import 'dart:io';

import 'package:quickcheck/main.dart';
import 'package:quickcheck/utils/GlobalFunctions.dart';

class BarcodeScannerScreen extends StatefulWidget {
  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool isScanning = false;
  String scannedBarcode = "No barcode scanned";

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      cameras[1],
      ResolutionPreset.ultraHigh,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> scanBarcode() async {
    if (!_controller.value.isInitialized) {
      return;
    }

    try {
      final image = await _controller.takePicture();
      await detectBarcode(image.path);
    } catch (e) {
      Exceptionsnackbar(context, "Error occurred while taking picture: $e");
    }
  }

  Future<void> detectBarcode(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final barcodeScanner =
        BarcodeScanner(formats: <BarcodeFormat>[BarcodeFormat.all]);
    try {
      final List<Barcode> barcodes =
          await barcodeScanner.processImage(inputImage);
      if (barcodes.isNotEmpty) {
        // Check if the first barcode is numeric
        String rawValue = barcodes.first.displayValue ?? "";
        if (RegExp(r'^\d+$').hasMatch(rawValue)) {
          // It's all digits
          setState(() {
            scannedBarcode = rawValue;
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IDcheckScreen(
                    search: scannedBarcode,
                  ),
                ));
          });
        } else {
          setState(() {
            scannedBarcode = "Barcode is not numeric";
          });
        }
      } else {
        setState(() {
          scannedBarcode = "No barcode detected";
        });
      }
    } catch (e) {
      Exceptionsnackbar(context,"Failed to recognize barcode: $e");
      setState(() {
        scannedBarcode = "Error scanning barcode";
      });
    } finally {
      barcodeScanner.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 36, 39, 70),
        leading: const Back_Button(),
        title: const Text(
          "ID Scanner",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
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
        onPressed: scanBarcode,
        tooltip: 'Scan Barcode',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
