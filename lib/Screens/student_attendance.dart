/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */

import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quickcheck/components/Buttons.dart';
import 'package:quickcheck/main.dart';
import 'package:quickcheck/Screens/main_screen.dart';
import 'package:quickcheck/utils/GlobalFunctions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  List<ClassData> classes = [];
  var userid = 0;
  Future<List<ClassData>> fetchdata() async {
    //final response = await supabase.rest.from("classes").select("id,classname,classtime,classlocation,classlecturer_profile_id");
    final usersid = supabase.auth.currentUser?.id;
    final studentsid = await supabase.rest
        .from('students')
        .select('student_id')
        .eq('user_id', '$usersid') as List<Map<String, dynamic>>;
    final studentId =
        studentsid.isNotEmpty ? studentsid[0]['student_id'] as int : 0;

    print("STDIDIDID ${studentId}");
    final attres = await supabase.rest
        .from("enrollments")
        .select("class_id")
        .filter('student_id', 'eq', '$studentId');
    print("ATTRES   ${attres}");
    final enrolledClassIds =
        attres.map((row) => row['class_id'] as int).toList();
    //final enrolledclassid = attres.isNotEmpty ? attres[0]['class_id'] as int : '0'; // remove * later but for now it serves good purpose .....
    print("enrolledclassid   ${enrolledClassIds}");

    final response = await supabase.rest
        .from("classes")
        .select("id,classname,classtime,classlocation,classlecturer_profile_id")
        .filter('id', 'in', enrolledClassIds);

    print("ENROLLED CLASSSES DEBUG $response");
    if (response.isEmpty) {
      print("ERROR : $response");
    }
    final classesData = response as List<dynamic>;
    final classes = classesData.map((e) async {
      final classMap = e as Map<String, dynamic>;
      final classId = classMap['id'] as int;
      final attend = await calculateAttendanceDays(studentId, classId);
      final absent = await calculateMissedDays(studentId, classId);
      print("CLASS ID TEST HERE $classId");
      print("STD ABB TEST HERE $attend");
      final warnings = absent >= 5 ? absent - 5 : 0;
      print("STD ATT TEST HERE $absent");
      classMap.addAll({
        'attendeddays': attend,
        'misseddays': absent,
        'warnings': warnings,
        'std_id': studentId
      });
      final lecturerId = classMap['classlecturer_profile_id'] as int;
      final lecturerName = await getfullname(lecturerId);
      classMap['classlecturer_profile_id'] =
          lecturerName;
      return ClassData.fromJson(classMap);
    }).toList();
    print("DDDD ${classes.toString()}");
    return await Future.wait(classes);
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

  Future<String> getfullname(int userId) async {
    String fullName = '';
    final response = await supabase.rest
        .from('user_profiles')
        .select('first_name,last_name')
        .filter('id', 'eq', '$userId');

    final data = response as List<Map<String, dynamic>>;
    for (var item in data) {
      final firstName = item['first_name'] as String;
      final lastName = item['last_name'] as String;
      fullName = firstName + ' ' + lastName;
    }
    return fullName;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            fontFamily: 'Poppins',
            textTheme: const TextTheme(
                labelSmall: TextStyle(color: Colors.white),
                labelMedium: TextStyle(color: Colors.white),
                labelLarge: TextStyle(color: Colors.white))),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color.fromARGB(255, 36, 39, 70),
          body: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: ListView.builder(
              itemCount: classes.length,
              itemBuilder: (context, index) {
                final classData =
                    classes[index];
                return ClassesSmallWidget(
                  classID: classData.classID,
                  className: classData.className,
                  classTime: classData.classTime,
                  classLocation: classData.classLocation,
                  classLecturer: classData.classlecturer_profile_id,
                  classAttendedDays: classData.classAttendedDays,
                  classMissedDays: classData.classMissedDays,
                  warnings: classData.warnings,
                  std_id: int.parse(classData.studentid),
                );
              },
            ),
          ),
        ));
  }
}

class ClassData {
  final String studentid;
  final String classID;
  final String className;
  final String classTime;
  final String classLocation;
  final String classLecturer;
  final String classlecturer_profile_id;
  final String classAttendedDays;
  final String classMissedDays;
  final String warnings;

  ClassData({
    required this.classID,
    required this.className,
    required this.classTime,
    required this.classLocation,
    required this.classlecturer_profile_id,
    required this.classLecturer,
    required this.classAttendedDays,
    required this.classMissedDays,
    required this.warnings,
    required this.studentid,
  });

  factory ClassData.fromJson(Map<String, dynamic> json) {
    print("json print ${json.toString()}");
    return ClassData(
      classID: json['id'].toString(),
      className: json['classname'].toString(),
      classTime: json['classtime'].toString(),
      classLocation: json['classlocation'].toString(),
      classlecturer_profile_id: json['classlecturer_profile_id'].toString(),
      classLecturer: json['classlecturer'].toString(),
      classAttendedDays: json['attendeddays'].toString(),
      classMissedDays: json['misseddays'].toString(),
      warnings: json['warnings'].toString(),
      studentid: json['std_id'].toString(),
    );
  }
}

class ClassesSmallWidget extends StatelessWidget {
  // Change height to media query it looks longer on my phone than on emulator
  final warningtxt =
      "REACH TO YOUR LECTURER IMMEDIATELY"; // "GO TO YOUR LECTURERS OFFICE IMMEDIATELY" , "REACH TO YOUR LECTURER IMMEDIATELY"
  final String classID;
  final String className;
  final String classTime;
  final String classLocation;
  final String classLecturer;
  final String classAttendedDays;
  final String classMissedDays;
  final String warnings;
  final int std_id;
  ClassesSmallWidget(
      {super.key,
      required this.classID,
      required this.className,
      required this.classTime,
      required this.classLocation,
      required this.classLecturer,
      required this.classAttendedDays,
      required this.classMissedDays,
      required this.warnings,
      required this.std_id});
  final textcolor = const Color.fromARGB(255, 232, 240, 255);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final attendanceResponse = await supabase.rest
            .from('attendance')
            .select('date,attendance_status')
            .filter('student_id', 'eq', std_id)
            .filter('class_id', 'eq', classID);

        print("RECIEVED STD_ID ${std_id.toString()}");
        print("RECIEVED CLASSID ${classID}");

        List<Map<String, dynamic>> studentData = attendanceResponse;

        var dataRows = studentData
            .map((data) => DataRow(
                  cells: [
                    DataCell(Text(data['date'])),
                    DataCell(Text(data['attendance_status'])),
                  ],
                ))
            .toList();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => attendance_cal(dataRows: dataRows),
            ));
        //navigatorKey.currentState?.pushNamed('/attendedcal', arguments: {'studentData': dataRows},);
      },
      child: Padding(
        padding: const EdgeInsets.all(9.0),
        // padding: const EdgeInsets.only(left: 10,right: 10,top: 5),

        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: responsiveWidgetSize(context, 100),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (int.parse(warnings) >= 3
                ? const Color.fromARGB(255, 115, 64, 64)
                : const Color.fromARGB(255, 64, 66, 115)),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    className + " " + classID,
                    style: TextStyle(
                        color: textcolor,
                        fontSize: responsiveFontSize(context, 16),
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Lecturer : $classLecturer",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: textcolor,
                      fontSize: responsiveFontSize(context, 10),
                    ),
                  ),
                ],
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     Text(
              //       "Time : $classTime",
              //       textAlign: TextAlign.left,
              //       style: TextStyle(
              //         color: textcolor,
              //         fontSize: 10,
              //       ),
              //     ),
              //   ],
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     Text(
              //       "Class Location : $classLocation",
              //       textAlign: TextAlign.left,
              //       style: TextStyle(
              //         color: textcolor,
              //         fontSize: 10,
              //       ),
              //     ),
              //   ],
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Attended days: $classAttendedDays/32",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: textcolor,
                      fontSize: responsiveFontSize(context, 10),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Absent days: $classMissedDays/25",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: textcolor,
                      fontSize: responsiveFontSize(context, 10),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Warnings: $warnings ",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: textcolor,
                      fontSize: responsiveFontSize(context, 10),
                    ),
                  ),
                  Text(
                    "${(int.parse(warnings) >= 3 ? warningtxt : '')}",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: textcolor,
                        fontSize: responsiveFontSize(context, 10),
                        fontWeight: FontWeight.w700),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class attendance_cal extends StatefulWidget {
  final List<DataRow> dataRows;

  const attendance_cal({super.key, required this.dataRows});

  @override
  State<attendance_cal> createState() => _attendance_calState();
}

class _attendance_calState extends State<attendance_cal> {
  @override
  Widget build(BuildContext context) {
    print("DATAROW ${widget.dataRows}");
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 39, 70),
      /*appBar: AppBar(
        title: Text(
          "Attendance",
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: GestureDetector(
          child: Back_Button(),
        ),
      ),*/
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              const Row(
                children: [],
              ),
              const SizedBox(
                height: 20,
              ),
              DataTable(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: const Color.fromARGB(255, 80, 64, 153), width: 3),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                columns: [
                  const DataColumn(label: Text('Date')),
                  const DataColumn(label: Text('Status')),
                ],
                rows: widget.dataRows,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AttendanceListMark extends StatefulWidget {
  List<Map<String, dynamic>> enrolledStudents;
  List<int> listofcheckedstds;
  final classid;
  AttendanceListMark(
      {super.key,
      required this.enrolledStudents,
      required this.classid,
      required this.listofcheckedstds});

  @override
  State<AttendanceListMark> createState() => _AttendanceListMarkState();
}

class _AttendanceListMarkState extends State<AttendanceListMark> {
  List<bool> _checked = [];

  List<bool> fillchecked() {
    List<bool> checked = [];
    for (var i = 0; i < widget.enrolledStudents.length; i++) {
      if (widget.listofcheckedstds.contains(int.tryParse(
              widget.enrolledStudents[i]['student_id'].toString())) &&
          widget.listofcheckedstds.isNotEmpty) {
        checked.add(true);
        _selectedPresentStudentIds
            .add(widget.enrolledStudents[i]['student_id'].toString());
      } else {
        _selectedAbsentStudentIds
            .add(widget.enrolledStudents[i]['student_id'].toString());
        checked.add(false);
      }
    }
    return checked;
  }

  List<String> _selectedAbsentStudentIds = [];

  List<String> _selectedPresentStudentIds = [];
  @override
  void initState() {
    super.initState();
    _fillchecked();
    verifyinclass();
  }

  void _fillchecked() {
    if (mounted) {
      setState(() {
        _checked = fillchecked();
      });
    }
  }

  void _updateSelectedIds(int index, bool value) {
    if (mounted) {
      setState(() {
        _checked[index] = value;
        if (value) {
          _selectedPresentStudentIds
              .add(widget.enrolledStudents[index]['student_id'].toString());
          _selectedAbsentStudentIds
              .remove(widget.enrolledStudents[index]['student_id'].toString());
        } else {
          _selectedPresentStudentIds
              .remove(widget.enrolledStudents[index]['student_id'].toString());
          _selectedAbsentStudentIds
              .add(widget.enrolledStudents[index]['student_id'].toString());
        }
      });
    }
    print("Current Present List ${_selectedPresentStudentIds.toString()}");
    print("Current Absent List ${_selectedAbsentStudentIds.toString()}");
  }

  Future<void> ShowerrDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Alert'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      "Student records have already been logged in the database. If you encounter any issues, please consult with the administration for assistance."),
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
                  navigatorKey.currentState?.maybePop();
                },
              ),
            ],
          );
        });
  }

  Future<void> notallowedstds(BuildContext context, List<String> a) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Alert'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text("These Students do not belong in the class"),
                  Text('${a.toString()}'),
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
                  navigatorKey.currentState?.maybePop();
                },
              ),
            ],
          );
        });
  }

  Future<void> verifyinclass() async {
    List<int> notinclass = [];
    List<String> notinclassnames = [];
    for (var i = 0; i < widget.listofcheckedstds.length; i++) {
      if (!(widget.enrolledStudents.contains(widget.listofcheckedstds[i]))) {
        notinclass.add(widget.listofcheckedstds[i]);
      }
    }

    if (notinclass.isNotEmpty) {
      for (var i = 0; i < notinclass.length; i++) {
        notinclassnames.add("${getfullname(notinclass[i].toString())}");
      }
      await notallowedstds(context, notinclassnames);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 36, 39, 70),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 51, 54, 97),
          title: const Text(
            'Manual Attendance',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () async {
                final att = await supabase
                    .from('attendance')
                    .select('id')
                    .order('id', ascending: false)
                    .limit(1)
                    .single();
                int attcount = 0;
                bool done = false;
                //attcount = att['id'] + 1;
                //super hacky way of doing things but i cba fixing db for now.
                print("Pressed the leg button");
                print("DEBUG ATTLENGTH${attcount}");
                try {
                  for (var i = 0; i < _selectedPresentStudentIds.length; i++) {
                    if (widget.enrolledStudents
                        .contains(_selectedPresentStudentIds[i])) {
                      await supabase.rest.from('attendance').insert({
                        'id': ++att['id'],
                        'student_id': _selectedPresentStudentIds[i],
                        'class_id': widget.classid,
                        'date':
                            DateTime.now().toIso8601String().substring(0, 10),
                        'attendance_status': 'present'
                      });
                    }

                    print(
                        "INSERTED STD as present ${_selectedPresentStudentIds[i]}");
                  }
                  for (var i = 0; i < _selectedAbsentStudentIds.length; i++) {
                    if (widget.enrolledStudents
                        .contains(_selectedAbsentStudentIds[i])) {
                      await supabase.rest.from('attendance').insert({
                        'id': ++att['id'],
                        'student_id': _selectedAbsentStudentIds[i],
                        'class_id': widget.classid,
                        'date':
                            DateTime.now().toIso8601String().substring(0, 10),
                        'attendance_status': 'absent'
                      });
                    }

                    print(
                        "INSERTED STD as absent${_selectedAbsentStudentIds[i]}");
                  }
                  done = true;
                } catch (e) {
                  ShowerrDialog(context);
                }

                if (done) {
                  done = false;
                  navigatorKey.currentState?.pop();
                }
              },
              child: const Attendancetakebutton(),
            )
          ],
          leading: const Back_Button(),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: const Color.fromARGB(
                  255, 74, 76, 133),
              height: 1.0,
            ),
          ),
        ),
        body: ListView.builder(
          itemCount: widget.enrolledStudents.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: const BoxDecoration(),
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: CheckboxListTile(
                  // Might have to build custom checkbox tile or something idk
                  activeColor: const Color.fromARGB(255, 136, 90, 222),
                  tileColor: const Color.fromARGB(255, 36, 39, 70),
                  title: Text(
                    widget.enrolledStudents[index]['name'].toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  value: _checked[index],
                  onChanged: (value) {
                    _updateSelectedIds(index, value!);
                  },
                ),
              ),
            );
          },
        ));
  }
}
