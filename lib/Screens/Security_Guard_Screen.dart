/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */
 
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/material.dart';
import 'package:quickcheck/Screens/CarPermits.dart';
import 'package:quickcheck/Screens/ID_check_screen.dart';
import 'package:quickcheck/Screens/Lecturers_Screen.dart';
import 'package:quickcheck/Screens/LicensePlateReader.dart';
import 'package:quickcheck/Screens/Messages_Screen.dart';
import 'package:quickcheck/Screens/University_ID_Scanner.dart';
import 'package:quickcheck/components/Buttons.dart';
import 'package:quickcheck/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as imglib;
import 'package:quickcheck/utils/GlobalFunctions.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class Sec_guard_screen extends StatefulWidget {
  const Sec_guard_screen({super.key});

  @override
  State<Sec_guard_screen> createState() => _Sec_guard_screenState();
}

class _Sec_guard_screenState extends State<Sec_guard_screen> {
  var userfullname = '';
  late String carplate;
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final fetchedData = await getfullname(supabase.auth.currentUser!.id);
    if (mounted) {
      setState(() {
        userfullname = fetchedData;
      });
    }
  }

  String _formatText(String text) {
    RegExp regExp = RegExp(r'\b\d{1,2}-\d{1,5}\b');
    Iterable<Match> matches = regExp.allMatches(text);
    return matches.map((m) => m.group(0)).join(', ');
  }

  Future<void> ShowCarCheckDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select License Plate Checking Method'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'Choose the method you would like to use for checking attendance.'),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              TextButton(
                child: const Text('Automatic'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LicensePlateScannerScreen()));
                },
              ),
              // SizedBox(
              //   width: MediaQuery.of(context).size.width * 0.182574,
              // ),
              TextButton(
                child: const Text('Manual'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CarPermitsScreen(),
                      ));
                },
              ),
            ],
          );
        });
  }

  Future<void> ShowIDCheckDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select ID Card Checking Method'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'Choose the method you would like to use for checking ID card.'),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              TextButton(
                child: const Text('Automatic'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BarcodeScannerScreen()));
                },
              ),
              // SizedBox(
              //   width: MediaQuery.of(context).size.width * 0.182574,
              // ),
              TextButton(
                child: const Text('Manual'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const IDcheckScreen(),
                      ));
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Security_Camera_Screen(),
                    ));
              },
              child: Clickablebox(
                pic: 'assets/icons/classpicnetwork.svg',
                text: "Facial Check",
                picw: 0.5,
                pich: 0.5,
                picpadding: 0.0,
                textpadding: 0.05,
              ),
            ),
            GestureDetector(
              onTap: () {
                ShowIDCheckDialog(context);
              },
              child: Clickablebox(
                pic: 'assets/icons/idcard.svg',
                text: "ID Check",
                picw: 0.5,
                pich: 0.5,
                botpicpadding: 0.05,
                picpadding: 0.0,
                textpadding: 0.1,
                bottextpadding: 0.09,
              ),
            ),
            GestureDetector(
              onTap: () async {
                final response = await supabase.rest
                    .from('user_profiles')
                    .select('user_id')
                    .eq('id', '1')
                    .single();
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MessagesScreen()
                        // ChatScreen(
                        //   currentUserId: supabase.auth.currentUser!.id,otherUserId: response['user_id'],
                        // ),
                        ));
              },
              child: Clickablebox(
                pic: 'assets/icons/chat1.svg',
                text: "Messages",
                picw: 0.5,
                pich: 0.5,
                picpadding: 0.0,
                botpicpadding: 0.0,
                textpadding: 0.05,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () async {
                  ShowCarCheckDialog(context);
                },
                child: Clickablebox(
                  pic: 'assets/icons/car.svg',
                  text: "Car Permits",
                  picw: 0.5,
                  pich: 0.5,
                  picpadding: 0.0,
                  botpicpadding: 0.0,
                  textpadding: 0.05,
                ),
              ),
              FillerClickablebox(),
              FillerClickablebox()
            ],
          ),
        )
      ],
    );
  }
}

class Security_Camera_Screen extends StatefulWidget {
  Security_Camera_Screen({super.key});

  @override
  _Security_Camera_ScreenState createState() => _Security_Camera_ScreenState();
}

class _Security_Camera_ScreenState extends State<Security_Camera_Screen> {
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

  Future<String> getfullnameasync(int id) async {
    final res = await getstudentnamefromid(id);

    return res;
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
      _isProcessing = false;
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
        backgroundColor: const Color.fromARGB(255, 36, 39, 70),
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
                        builder: (context) => Student_Security_List(
                              studentids: checkedids,
                            )));
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
    final url = Uri.parse(
        'http://$ipaddress:5000/checkface');
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

    // Convert the streamed response to a normal response
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      print('JPG file uploaded successfully: ${response.statusCode}');

      // Decode the JSON response
      var responseData = json.decode(response.body);
      if (responseData['recognized_ids'] != null) {
        List<dynamic> recognizedIds = responseData['recognized_ids'];
        print('Recognized IDs: $recognizedIds');
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
      } else {
        print('No recognized IDs returned from the server.');
      }
    } else {
      print('Error uploading file: ${response.statusCode} - ${response.body}');
    }
  }
}

class Student_Security_List extends StatefulWidget {
  final List<int> studentids;
  const Student_Security_List({super.key, required this.studentids});

  @override
  State<Student_Security_List> createState() => _Student_Security_ListState();
}

class _Student_Security_ListState extends State<Student_Security_List> {
  late List<DataRow> dataRows = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final Rows = await fetchdata();
    if (mounted) {
      setState(() {
        dataRows = Rows;
      });
    }
  }

  Future<List<DataRow>> fetchdata() async {
    final seenStudentIDs = Set<int>();
    final attendanceData = <Map<String, dynamic>>[];
    final studentNames = <String>[];
    final studentMajors = <String>[];

    for (final sid in widget.studentids) {
      if (!seenStudentIDs.contains(sid)) {
        seenStudentIDs.add(sid);
        final name = await getstudentnamefromid(sid);
        final major = await getMajorfromID(sid);
        studentNames.add(name);
        studentMajors.add(major);
      }
      else{
        continue;
      }
    }

    if(seenStudentIDs.length == studentNames.length){
      for (int i = 0; i < seenStudentIDs.length; i++) {
      attendanceData.add({
        'name': studentNames[i],
        'student_ids': seenStudentIDs.elementAt(i),
        'major': studentMajors[i]
      });
    }
    }

    var dataRow = attendanceData
        .map((data) => DataRow(
              cells: [
                DataCell(Text(
                  data['name'],
                  style: const TextStyle(color: Colors.white),
                )),
                DataCell(Text(
                  data['student_ids'].toString(),
                  style: const TextStyle(color: Colors.white),
                )),
                DataCell(Text(
                  data['major'].toString(),
                  style: const TextStyle(color: Colors.white),
                ))
              ],
            ))
        .toList();

    return dataRow;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 39, 70),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 36, 39, 70),
        leading: const Back_Button(),
        centerTitle: true,
        title: const Text(
          "Student Check",
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.95,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Center(
                            child: Text(
                      "Students count: ${dataRows.length}",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    )))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DataTable(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      columns: [
                        const DataColumn(
                            label: Text(
                          style: TextStyle(color: Colors.white),
                          'Name',
                          textAlign: TextAlign.start,
                        )),
                        const DataColumn(
                            label: Text(
                          style: TextStyle(color: Colors.white),
                          'ID',
                          textAlign: TextAlign.start,
                        )),
                        const DataColumn(
                            label: Text(
                          style: TextStyle(color: Colors.white),
                          'Major',
                          textAlign: TextAlign.start,
                        ))
                      ],
                      rows: dataRows),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FillerClickablebox extends StatelessWidget {
  // I just discovered a hack in my mind to make the second row behave exactly like the first row
// simply we can create a version of this box with the same dimensions and everything but make it fully transparent and we can make it so every row that has a real clickableboxes less than 3
// automatically have filler transparent versions of it

  FillerClickablebox({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.288194;
    double height = MediaQuery.of(context).size.height * 0.125;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(0, 64, 66, 115),
      ),
      width: width,
      height: height,
    );
  }
}
