/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */

import 'dart:io';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:quickcheck/main.dart';
import 'package:quickcheck/components/Buttons.dart';
import 'package:quickcheck/utils/GlobalFunctions.dart';

class FacialRetrainScreen extends StatefulWidget {
  // TODOO HERE IS TO JUST USE THE ORIGINAL CODE FOR FACIAL DETECTION AND JUST STOP USING CAMERAAWESOME
  // FIX THIS SOON.
  const FacialRetrainScreen({super.key});

  @override
  State<FacialRetrainScreen> createState() => _FacialRetrainScreenState();
}

class _FacialRetrainScreenState extends State<FacialRetrainScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool isDetecting = false;
  bool _isProcessing = false;
  Timer? timer;
  Timer? checkt;

  int currentstdid = 0;
  bool recognitionDone = true;

  Future<void> loadstdid() async {
    final usersid = supabase.auth.currentUser?.id;
    final studentsid = await supabase.rest
        .from('students')
        .select('student_id')
        .eq('user_id', '$usersid') as List<Map<String, dynamic>>;
    currentstdid =
        studentsid.isNotEmpty ? studentsid[0]['student_id'] as int : 0;
    print("STDIDIDID $currentstdid");
  }

  @override
  void initState() {
    super.initState();
    loadstdid();
    _controller = CameraController(
      cameras[1],
      ResolutionPreset.ultraHigh,
    );
    _initializeControllerFuture = _controller.initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShowtipDialog(
          context);
    });
  }

  Future<void> ShowtipDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Optimal Scanning Guidance'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      "Please Keep your hands steady and make sure you have good lighting to make sure the facial retrain goes smoothly."),
                ],
              ),
            ),
            actions: <Widget>[
              // SizedBox(
              //   width: MediaQuery.of(context).size.width * 0.182574,
              // ),
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Future<void> checkRecognitionStatus() async {
    // This whole thing needs debugging
    var url = Uri.parse('http://$ipaddress:5000/recognition_status');
    var response =
        await http.get(url);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("reco data ${data.toString()}");

      if (!data['isRecognizing']) {
        if (mounted) {
          setState(() {
            recognitionDone = true;
          });
          timer?.cancel();
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    timer?.cancel();
    checkt?.cancel();
    super.dispose();
  }

  void toggleCapture() {
    if (mounted) {
      setState(() {
        isDetecting = !isDetecting;
        print("TIMER switch press");
      });
    }

    if (isDetecting) {
      timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
        await startDetection();
      });
    } else {
      timer?.cancel();
      checkt = Timer.periodic(const Duration(seconds: 6), (Timer checkt) async {
        await checkRecognitionStatus();
      });
      if (recognitionDone) {
        // keep eyes on this
        checkt?.cancel();
      }
    }

    if (!isDetecting) {
      // Timer.periodic(Duration(seconds: 5), (Timer a) {
      //   print("TIMER MAKE THIS FALSE 2 ");
      //   if (mounted) {
      //     setState(() {
      //       _isProcessing = false;
      //     });
      //   }
      //   a.cancel();
      // });
    }
  }

  Future<void> startDetection() async {
    if (!_controller.value.isInitialized || _isProcessing) {
      return;
    }
    recognitionDone = false;

    _isProcessing = true;
    try {
      final XFile image = await _controller.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final options =
          FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate);

      final faceDetector = FaceDetector(options: options);
      final List<Face> faces = await faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        for (var face in faces) {
          await cropAndSaveFace(image, face);
        }
      }
    } catch (e) {
      Exceptionsnackbar(context, "Failed to detect and process image: $e");
    } finally {
      print("TIMER MAKE THIS FALSE");
      _isProcessing = false; // Reset processing flag
    }
  }

  Future<void> cropAndSaveFace(XFile file, Face face) async {
    imglib.Image? originalImage =
        imglib.decodeImage(File(file.path).readAsBytesSync());
    imglib.Image croppedImage = imglib.copyCrop(
      originalImage!,
      x: face.boundingBox.left.toInt(),
      y: face.boundingBox.top.toInt(),
      width: face.boundingBox.width.toInt(),
      height: face.boundingBox.height.toInt(),
    );

    final directory = await getApplicationDocumentsDirectory();
    final String filePath =
        '${directory.path}/face_${DateTime.now().millisecondsSinceEpoch}.png';
    File(filePath).writeAsBytesSync(imglib.encodePng(croppedImage));
    await saveStudentFace(filePath, currentstdid.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: const Color.fromARGB(
                255, 74, 76, 133),
            height: 1.0,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 51, 54, 97),
        title: const Text(
          "Face Detection",
          style: TextStyle(color: Colors.white),
        ),
        leading: const Back_Button(),
        actions: [
          GestureDetector(
            onTap: () {
              if (!isDetecting && recognitionDone) {
                navigatorKey.currentState?.maybePop();
              }
              else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(milliseconds: 800),
                  content: const Text("Recognition is ongoing , please wait!"),
                  backgroundColor: Theme.of(context).primaryColorDark,
                ));
              }
            },
            child: const Attendancetakebutton(),
          )
        ],
      ),
      body: (!isDetecting && !recognitionDone)
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 136, 90, 222),
        onPressed: toggleCapture,
        tooltip: 'Start/Stop Detection',
        child: Icon(isDetecting ? Icons.stop : Icons.camera_alt),
      ),
    );
  }

  Future<void> saveStudentFace(String filePath, String studentId) async {
    _isProcessing = true;
    final url = Uri.parse(
        'http://$ipaddress:5000/addfacedata');
    final file = File(filePath);
    final fileName = filePath.split('/').last;

    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = '${dotenv.env['SECRETKEY']}';

    request.fields['student_id'] = studentId; 
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      filename: fileName,
    ));

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 800),
        content: const Text("Face Saved Successfully"),
        backgroundColor: Theme.of(context).primaryColorDark,
      ));
      print('Image uploaded and saved successfully: ${response.statusCode}');
      var responseData = json.decode(response.body);
      print(responseData['message']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 800),
        content: const Text("Error uploading file"),
        backgroundColor: Theme.of(context).primaryColorDark,
      ));
      print('Error uploading file: ${response.statusCode} - ${response.body}');
    }
    _isProcessing = false;
  }
}

class ErrorPage extends StatelessWidget {
  String errorstr;
  ErrorPage({super.key, required this.errorstr});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(
            "$errorstr",
            style: const TextStyle(
                color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          SignOut()
        ],
      ),
    );
  }
}
