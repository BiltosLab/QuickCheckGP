/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */

import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quickcheck/Screens/Marks_Screen.dart';
import 'package:quickcheck/Screens/Messages_Screen.dart';
import 'package:quickcheck/Screens/Students_Info_Screen.dart';
import 'package:quickcheck/Screens/students_Screen.dart';
import 'package:quickcheck/components/Buttons.dart';
import 'package:quickcheck/main.dart';
import 'package:quickcheck/Screens/main_screen.dart';
import 'package:quickcheck/Screens/student_attendance.dart';
import 'package:quickcheck/utils/GlobalFunctions.dart';

import 'Camera_Screen.dart';

class Lecturer_Screen extends StatefulWidget {
  const Lecturer_Screen({super.key});

  @override
  State<Lecturer_Screen> createState() => _Lecturer_ScreenState();
}

class _Lecturer_ScreenState extends State<Lecturer_Screen> {
  String nextclass = 'No Classes today';
  var userfullname = '';
  late List<Map<String, dynamic>> enrolledStudents;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<List<Map<String, dynamic>>> fetchstddata(int classid) async {
    final enrollmentResults = await supabase
        .from('enrollments')
        .select('student_id')
        .eq('class_id', classid);
    if (enrollmentResults.isEmpty) {
      throw enrollmentResults;
    }

    final studentList = enrollmentResults as List<dynamic>;
    final studentInfo = await Future.wait(studentList.map((enrollment) async {
      final studentId = enrollment['student_id'] as int;
      final studentName = await getstudentnamefromid(studentId);
      return {'name': studentName, 'student_id': studentId};
    }));

    return studentInfo;
  }

  Future<void> _fetchData() async {
    final fetchedclassdata = await getNextClass();
    final fetchedData = await getfullname(supabase.auth.currentUser!.id);
    print("THIS IS DEBUG NOW FETCHDATA $fetchedData");
    if (mounted) {
      setState(() {
        userfullname = fetchedData;
        nextclass = fetchedclassdata;
      });
    }
  }

 Future<void> ShowAttDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Attendance Checking Method'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Choose the method you would like to use for checking attendance.'),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Text('Automatic'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClassesListselection(
                            grades: false,
                            auto: true,
                            StudentInfo: false,
                          ),
                        ));
              },
            ),
            TextButton(
              child: const Text('Manual'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClassesListselection(
                          grades: false,
                          auto: false,
                          StudentInfo: false,
                        ),
                      ));
              },
            ),
          ],
        );
 });}

// SvgPicture.asset(
//                     'assets/icons/classpicnetwork.svg',
//                     width: 50,
//                     height: 50,
//                   ),

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 36, 39, 70),
      child: Column(
        children: [
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: ()async{ShowAttDialog(context);},
                child: Clickablebox(
                  pic: 'assets/icons/classpicnetwork.svg',
                  text: "Attendance",
                  picw: 0.5,
                  pich: 0.5,
                  picpadding: 0.0,
                  textpadding: 0.05,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClassesListselection(
                          grades: true,
                          auto: false,
                          StudentInfo: false,
                        ),
                      ));
                },// marks wid 38.7% of total wid height pic and now text is 51.02% of total wid height
                child: Clickablebox(
                    pic: 'assets/icons/marksicon.svg',
                      picw: 0.35,
                      pich: 0.35,
                    
                    text: "Grades",
                    picpadding:  0.05 ,
                    textpadding: 0.14),
              ),
              GestureDetector(
                onTap:() async{
                   Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        MessagesScreen() 
                      ));},
                child: Clickablebox(
                    pic:'assets/icons/chat1.svg',
                    pich: 0.5,
                    picw: 0.5,
                    text: "Messages",
                    picpadding: 0.05,
                    textpadding: 0.0),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top:13.0,left: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClassesListselection(auto: false, grades: false,StudentInfo: true,),
                      )),
                  child: Clickablebox(
                    pic: 'assets/icons/studenticon.svg',
                    text: "Students",
                    pich: 0.4,
                    picw: 0.4,
                    picpadding: 0.03,
                    textpadding: 0.12,
                  ),
                ),
                FillerClickablebox(),
                FillerClickablebox()
              ],
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////
class Classes_sel {
  final String classID;
  final String className;
  final String classlecturer_profile_id;

  Classes_sel({
    required this.classID,
    required this.className,
    required this.classlecturer_profile_id,
  });

  factory Classes_sel.fromJson(Map<String, dynamic> json) {
    print("json print ${json.toString()}");
    return Classes_sel(
      classID: json['id'].toString(),
      className: json['classname'].toString(),
      classlecturer_profile_id: json['classlecturer_profile_id'].toString(),
    );
  }
}

class ClassesListselection extends StatefulWidget {
  bool auto;
  bool grades;
  bool StudentInfo;

  ClassesListselection({super.key, required this.auto, required this.grades,required this.StudentInfo});

  @override
  State<ClassesListselection> createState() => _ClassesListselectionState();
}

class _ClassesListselectionState extends State<ClassesListselection> {
  @override
  void dispose() {
    super.dispose();
  }

  List<Classes_sel> classes = [];
  var userid = 0;

  Future<List<Classes_sel>> fetchdata() async {
    final usersid = supabase.auth.currentUser?.id;
    final iduser = await supabase.rest
        .from('user_profiles')
        .select('id')
        .filter('user_id', 'eq', usersid);
    final data = iduser as List;
    final lecid = data[0]['id'];
    final classestaut = await supabase.rest
        .from('classes')
        .select('id')
        .eq('classlecturer_profile_id', '$lecid') as List<Map<String, dynamic>>;

    final classIds = (classestaut.isNotEmpty
        ? classestaut.map((classData) => classData['id'] as int).toList()
        : [0]) as List;

    final enrolledClassIds = classIds;

    final response = await supabase.rest
        .from("classes")
        .select("id,classname,classlecturer_profile_id")
        .filter('id', 'in', enrolledClassIds);

    print("ENROLLED CLASSSES DEBUG $response");
    if (response.isEmpty) {
      print("ERROR : $response");
    }
    final classesData = response as List<dynamic>;
    final classes = classesData.map((e) async {
      final classMap = e as Map<String, dynamic>;
      final classId = classMap['id'] as int;
      print("CLASS ID TEST HERE $classId");
      final lecturerId = classMap['classlecturer_profile_id'] as int;
      return Classes_sel.fromJson(classMap);
    }).toList();
    return await Future.wait(classes);
  }

  Future<int> calculateMissedDays(int studentId, int classId) async {
    if (studentId == 0 || classId == 0) {
      return 0;
    }
    final attendanceResponse = await supabase.rest
        .from('attendance')
        .select('date')
        .filter('student_id', 'eq', '$studentId')
        .filter('class_id', 'eq', '$classId')
        .filter('attendance_status', 'eq', 'absent');

    final attendanceData = attendanceResponse as List<dynamic>;
    return attendanceData.isEmpty
        ? 0
        : attendanceData.length;
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final fetchedClasses = await fetchdata();
    if (mounted) {
      setState(() {
        classes = fetchedClasses;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Poppins',
        ),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 51, 54, 97),
            leading: const Back_Button(),
            title: const Text("Select Class", style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w600)),
            centerTitle: true,
            bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: const Color.fromARGB(255, 74, 76, 133),
              height: 1.0,
            ),
          ),
          ),
          backgroundColor: const Color.fromARGB(255, 36, 39, 70),
          body: ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classData = classes[index];
              return Lec_Classes_Widget(
                classID: classData.classID,
                className: classData.className,
                classLecturer: classData.classlecturer_profile_id,
                auto: widget.auto,
                grades: widget.grades,
                student_info: widget.StudentInfo,

              );
            },
          ),
        ));
  }
}

class Lec_Classes_Widget extends StatefulWidget {
  // Change height to media query it looks longer on my phone than on emulator
  final String
      classID; // Add Section to the DB make sure we can have 2 classes different section and also modify enrollments.
  final String className;
  final String classLecturer;
  final bool auto;
  final bool grades;
  final bool student_info;

  Lec_Classes_Widget(
      {super.key,
      required this.classID,
      required this.className,
      required this.classLecturer,
      required this.auto,
      required this.grades,
      required this.student_info});

  @override
  State<Lec_Classes_Widget> createState() => _Lec_Classes_WidgetState();
}

class _Lec_Classes_WidgetState extends State<Lec_Classes_Widget> {
  late List<Map<String, dynamic>> enrolledStudents;
  @override
  void initState() {
    super.initState();
    _fetchData().whenComplete(() => null);
  }

  Future<void> _fetchData() async {
    final fetchednames = await fetchstddata(int.parse(widget.classID));
    print("THIS IS DEBUG NOW FETCHEDNAMES lastestststs ${fetchednames}");
    if (mounted) {
      setState(() {
        enrolledStudents = fetchednames;
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchstddata(int classid) async {
    final enrollmentResults = await supabase
        .from('enrollments')
        .select('student_id')
        .eq('class_id', classid);
    if (enrollmentResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("List Empty !"),
        backgroundColor: Theme.of(context).highlightColor,
      ));
    }

    // 2. Fetch student names using student_ids
    final studentList = enrollmentResults as List<dynamic>;
    final studentInfo = await Future.wait(studentList.map((enrollment) async {
      final studentId = enrollment['student_id'] as int;
      final studentName = await getstudentnamefromid(studentId);
      return {'name': studentName, 'student_id': studentId};
    }));

    return studentInfo;
  }

  final textcolor = const Color.fromARGB(255, 232, 240, 255);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Enrolled Student${enrolledStudents}");
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => widget.auto
                  ? CameraScreen(
                      ClassID: widget.classID,
                      enrolledStudents: enrolledStudents,
                    )
                  : widget.grades
                      ? StudentSelectionScreen(
                          ClassID: widget.classID,
                          enrolledStudents: enrolledStudents,
                        )
                      : widget.student_info ? StudentSelectionScreeninfo(
                        ClassID: widget.classID,
                          enrolledStudents: enrolledStudents,
                      ) : AttendanceListMark(
                          listofcheckedstds: [],
                          enrolledStudents: enrolledStudents,
                          classid: widget.classID,
                        ),
            ));
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0,right: 8.0,top: 10),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: 40,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 64, 66, 115),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    widget.className +
                        " " +
                        widget.classID.substring(0, widget.classID.length - 1) +
                        " Section ${widget.classID.substring(widget.classID.length - 1)}",
                    style: TextStyle(
                        color: textcolor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class Clickablebox extends StatelessWidget {
  // I just discovered a hack in my mind to make the second row behave exactly like the first row
// simply we can create a version of this box with the same dimensions and everything but make it fully transparent and we can make it so every row that has a real clickableboxes less than 3
// automatically have filler transparent versions of it
  final String pic;
  final String text;
  final double picpadding;
  final double botpicpadding;

  final double textpadding;
  final double bottextpadding;

  final double picw;
  final double pich;
  Clickablebox(
      {super.key,
      required this.pic,
      required this.text,
      required this.picpadding,
      this.botpicpadding = 0.0,
      required this.textpadding,
      this.bottextpadding=0.0,
      required this.picw,
      required this.pich});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.288194;
    double height = MediaQuery.of(context).size.height * 0.125;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(255, 64, 66, 115),
      ),
      width: width,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: height * picpadding,bottom: botpicpadding * height),
            child: SvgPicture.asset(
              pic,
              width: width * picw,
              height: pich * height,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: height * textpadding,bottom: bottextpadding*height),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
