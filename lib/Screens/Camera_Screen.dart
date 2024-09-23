/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:quickcheck/Screens/student_attendance.dart';
import 'package:quickcheck/components/Buttons.dart';
import 'package:quickcheck/main.dart';
import 'package:quickcheck/utils/GlobalFunctions.dart';

class CameraScreen extends StatefulWidget {
  final List<Map<String, dynamic>> enrolledStudents;
  final String ClassID;

  const CameraScreen(
      {super.key, required this.ClassID, required this.enrolledStudents});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<int> checkedids = [];
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool isDetecting = false;
  bool _isProcessing = false;
  bool recognitionDone = true;
  Timer? timer;
  Timer? checkt;
  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      cameras[selectcamera],
      ResolutionPreset.ultraHigh,
    );
    _initializeControllerFuture = _controller.initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShowtipDialog(
          context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    timer?.cancel();
    checkt?.cancel();
    super.dispose();
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
                      "Please walk slowly among the students and maintain a steady hand to ensure optimal face recognition. This will help us accurately process each student's attendance."),
                  //Text(''),
                  //Text('Each method offers different benefits and fits different scenarios.'),
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

  Future<String> getfullnameasync(int id) async {
    final res = await getstudentnamefromid(id);

    return res;
  }

/**
 * Exception has occurred.
_ClientSocketException (ClientException with SocketException: Connection timed out (OS Error: Connection timed out, errno = 110), address = 10.0.2.2, port = 59428, uri=http://10.0.2.2:5000/recognition_status)
 */
  Future<void> checkRecognitionStatus() async {
    // This whole thing needs debugging
    var url = Uri.parse('http://$ipaddress:5000/recognition_status');
    var response =
        await http.get(url); // try catch here and everywhere we do http stuff
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("reco data ${data.toString()}");

      if (!data['isRecognizing']) {
        if (mounted) {
          setState(() {
            recognitionDone = true;
          });
          timer?.cancel(); // Stop the timer if recognition is done
        }
      }
    }
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
  }

  Future<void> startDetection() async {
    if (!_controller.value.isInitialized || _isProcessing) {
      return; // Check if the camera is ready and not already processing
    }
    recognitionDone = false;
    _isProcessing = true; // Set processing flag to true
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
      print("Failed to detect and process image: $e");
      Exceptionsnackbar(context,"Failed to detect and process image");
    } finally {
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
    await sendjpgFile(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 39, 70),
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: const Color.fromARGB(
                255, 74, 76, 133), // Choose any color you like
            height: 1.0, // Control the thickness of the bar
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttendanceListMark(
                          enrolledStudents: widget.enrolledStudents,
                          classid: widget.ClassID,
                          listofcheckedstds: checkedids),
                    ));
              } else {
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
              // TODO TEST THIS IRL
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

  Future<void> sendjpgFile(String filePath) async {
    _isProcessing = true;
    try {
      final url = Uri.parse('http://$ipaddress:5000/checkface');
    final file = File(filePath);
    final fileName = filePath.split('/').last;
    final request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = '${dotenv.env['SECRETKEY']}';

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      filename: fileName,
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      print('JPG file uploaded successfully: ${response.statusCode}');

      var responseData = json.decode(response.body);
      if (responseData['recognized_ids'] != null) {
        List<dynamic> recognizedIds = responseData['recognized_ids'];
        print('Recognized IDs: $recognizedIds');
        print('Recognized IDs length ${recognizedIds.length}');
        if (checkedids.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(milliseconds: 800),
            content:
                Text("Recognized ${await getfullnameasync(checkedids.last)}"),
            backgroundColor: Theme.of(context).primaryColorDark,
          ));
        } else if (checkedids.length == 1) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(milliseconds: 800),
            content:
                Text("Recognized ${await getfullnameasync(checkedids.first)}"),
            backgroundColor: Theme.of(context).primaryColorDark,
          ));
        }

        checkedids.addAll(
            recognizedIds.map<int>((id) => int.parse(id.toString())).toList());
        print('Updated checked IDs: $checkedids');
        print('Checked IDS Length ${checkedids.length}');
      } else {
        print('No recognized IDs returned from the server.');
      }
    } else {
      print('Error uploading file: ${response.statusCode} - ${response.body}');
    }
    } catch (e) {
     Exceptionsnackbar(context,"Facial Recognition error please check your internet"); 
    }
    _isProcessing = false;
  }
}
