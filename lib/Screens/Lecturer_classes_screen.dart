/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */
 
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quickcheck/main.dart';
import 'package:quickcheck/utils/GlobalFunctions.dart';

class Lecturerclasses extends StatefulWidget {
  const Lecturerclasses({super.key});

  @override
  State<Lecturerclasses> createState() => _LecturerclassesState();
}

class _LecturerclassesState extends State<Lecturerclasses> {
  @override
  void dispose() {
    super.dispose();
  }

  List<Lec_Classes> classes = []; // Empty list to store Class objects
  var userid = 0;

  Future<List<Lec_Classes>> fetchdata() async {
    //final response = await supabase.rest.from("classes").select("id,classname,classtime,classlocation,classlecturer_profile_id");
    final usersid = supabase.auth.currentUser?.id;
    final iduser = await supabase.rest
        .from('user_profiles')
        .select('id')
        .filter('user_id', 'eq', usersid);
    final data = iduser as List;
    final lecid = data[0]['id'];
    if (kDebugMode) {
      print("USER ID IN LECCLASS ${lecid}");
    }

    final classestaut = await supabase.rest
        .from('classes')
        .select('id')
        .eq('classlecturer_profile_id', '$lecid') as List<Map<String, dynamic>>;

    final classIds = (classestaut.isNotEmpty
        ? classestaut.map((classData) => classData['id'] as int).toList()
        : [0]) as List;
    if (kDebugMode) {
      print("DATA CLSTAT ${classIds}");
    }

    final studentsid = await supabase.rest
        .from('students')
        .select('student_id')
        .eq('user_id', '$usersid') as List<Map<String, dynamic>>;
    final studentId =
        studentsid.isNotEmpty ? studentsid[0]['student_id'] as int : 0;

    if (kDebugMode) {
      print("STDIDIDID ${studentId}");
    }

    final enrolledClassIds = classIds;
    if (kDebugMode) {
      print("enrolledclassid   ${enrolledClassIds}");
    }

    final response = await supabase.rest
        .from("classes")
        .select("id,classname,classtime,classlocation,classlecturer_profile_id")
        .filter('id', 'in', enrolledClassIds);

    if (kDebugMode) {
      print("ENROLLED CLASSSES DEBUG $response");
    }
    if (response.isEmpty) {
      if (kDebugMode) {
        print("ERROR : $response");
      }
    }
    final classesData = response as List<dynamic>;
    final classes = classesData.map((e) async {
      final classMap = e as Map<String, dynamic>;
      final classId = classMap['id'] as int;
      final enroll = await enrolledstdsrec(classId);
      classMap.addAll({
        'attendeddays': enroll.length,
      });
      final lecturerId = classMap['classlecturer_profile_id'] as int;
      final lecturerName = await getfullname(lecturerId);
      classMap['classlecturer_profile_id'] =
          lecturerName;
      return Lec_Classes.fromJson(classMap);
    }).toList();
    return await Future.wait(classes);
  }

  Future<List> enrolledstdsrec(int classId) async {
    if (classId == 0) {
      return ['0'];
    }

    final enrolledResponse = await supabase.rest
        .from('enrollments')
        .select('student_id')
        .filter('class_id', 'eq', '${classId}');

    final enrollmentData = enrolledResponse as List<dynamic>;
    return enrollmentData.isEmpty
        ? ['0']
        : enrollmentData;
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
    if(mounted){
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
    print("DATA OF USER : $data");
    print("fullName OF USER : $fullName");
    return fullName;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          fontFamily: 'Poppins',
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color.fromARGB(255, 36, 39, 70),
          body: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: ListView.builder(
              itemCount: classes.length,
              itemBuilder: (context, index) {
                final classData = classes[index]; // Get the current Class object
                return Lec_Classes_Widget(
                  classID: classData.classID,
                  className: classData.className,
                  classTime: classData.classTime,
                  classLocation: classData.classLocation,
                  classLecturer: classData.classlecturer_profile_id,
                  classAttendedDays: classData.classAttendedDays,
                );
              },
            ),
          ),
        ));
  }
}

class Lec_Classes {
  final String classID;
  final String className;
  final String classTime;
  final String classLocation;
  final String classLecturer;
  final String classlecturer_profile_id;
  final String classAttendedDays;

  Lec_Classes({
    required this.classID,
    required this.className,
    required this.classTime,
    required this.classLocation,
    required this.classlecturer_profile_id,
    required this.classLecturer,
    required this.classAttendedDays,
  });

  factory Lec_Classes.fromJson(Map<String, dynamic> json) {
    print("json print ${json.toString()}");
    return Lec_Classes(
      classID: json['id'].toString(),
      className: json['classname'].toString(),
      classTime: json['classtime'].toString(),
      classLocation: json['classlocation'].toString(),
      classlecturer_profile_id: json['classlecturer_profile_id'].toString(),
      classLecturer: json['classlecturer'].toString(),
      classAttendedDays: json['attendeddays'].toString(),
    );
  }
}

class Lec_Classes_Widget extends StatelessWidget {
  // Change height to media query it looks longer on my phone than on emulator
  final String
      classID;
  final String className;
  final String classTime;
  final String classLocation;
  final String classLecturer;
  final String classAttendedDays;
  Lec_Classes_Widget({
    super.key,
    required this.classID,
    required this.className,
    required this.classTime,
    required this.classLocation,
    required this.classLecturer,
    required this.classAttendedDays,
  });
  final textcolor = Colors.white;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final enrolled = await enrolledstdsrec(classID);
        final studentNames = <String>[];
        final studentIds = enrolled.isNotEmpty
            ? enrolled
                .map((data) => data['student_id'] as int)
                .toList()
            : [1010101010];
        final attendanceData = <Map<String, dynamic>>[];
        for (final sid in studentIds) {
          final name = await getstudentnamefromid(sid);
          studentNames.add(name);
        }

        print("TEST ENROLL NAME ${studentNames}");
        for (int i = 0; i < studentIds.length; i++) {
          final studentId = studentIds[i];
          final name = studentNames[i];
          final studentAttendance =
              await calculateAttendanceDays(studentId, int.parse(classID));
          final studentabsence =
              await calculateMissedDays(studentId, int.parse(classID));

          attendanceData.add({
            'name': name,
            'present_days': studentAttendance,
            'absent_days': studentabsence,
            'id':studentId
          });
        }

        print("list of att data final ${attendanceData}");
        print("TEST E NROLL ${studentIds}");

        var dataRows = attendanceData
            .map((data) => DataRow(
                  cells: [
                    DataCell(Text(data['name'])),
                    DataCell(Text(data['present_days'].toString())),
                    DataCell(Text(data['absent_days'].toString()))
                  ],
                  onLongPress: () {
                    print("data ${data.toString()}");
                  },
                ))
            .toList();

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => attendance_stdname_list(dataRows: dataRows),
            ));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95, // I/flutter ( 4963): Screen width = 392.72727272727275 emulator //  Screen width = 411.42857142857144 s10 p
          height: responsiveWidgetSize(context, 100), //  I/flutter ( 5191): Screen Height = 783.2727272727273 emulator // I/flutter (29013): Screen Height = 868.5714285714286 s10 p 
          //
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
                    className + " " + classID.substring(0, classID.length - 1),
                    style: TextStyle(
                        color: textcolor,
                        fontSize: responsiveFontSize(context,16),
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Section : ${classID.substring(classID.length - 1)}",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: textcolor,
                      fontSize: responsiveFontSize(context,10),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Time : $classTime",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: textcolor,
                      fontSize: responsiveFontSize(context,10),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Class Location : $classLocation",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: textcolor,
                      fontSize: responsiveFontSize(context,10),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Enrolled Students: $classAttendedDays",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: textcolor,
                      fontSize: responsiveFontSize(context,10),
                    ),
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

class attendance_stdname_list extends StatefulWidget {
  final List<DataRow> dataRows;

  const attendance_stdname_list({super.key, required this.dataRows});

  @override
  State<attendance_stdname_list> createState() =>
      _attendance_stdname_listState();
}

class _attendance_stdname_listState extends State<attendance_stdname_list> {
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
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.95,
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DataTable(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: const Color.fromARGB(255, 80, 64, 153),
                          width: 3),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    columns: const [
                      DataColumn(
                          label: Text(
                        'Name',
                        textAlign: TextAlign.start,
                      )),
                      DataColumn(
                          label: Text(
                        'Preset',
                        textAlign: TextAlign.start,
                      )),
                      DataColumn(
                          label: Text(
                        'Absent',
                        textAlign: TextAlign.start,
                      )),
                    ],
                    rows: widget.dataRows,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
