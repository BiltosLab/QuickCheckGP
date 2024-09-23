/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */
 
import 'package:flutter/material.dart';
import 'package:quickcheck/Screens/login_screen.dart';
import 'package:quickcheck/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> recordattendanceaspresent(List<int> studentids, int classID) async {
  List<int> studentIDs = [];
  for (var stdid in studentIDs) {
    takesinglepresetatt(stdid, classID);
  }
}
Future<void> signoutcurrentsession(BuildContext context) async {
    await supabase.auth.signOut(scope: SignOutScope.local);
    print("Signed Out Successfully");
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: const Text("Signed out successfully"),
      backgroundColor: Colors.amber,
    ));
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false, 
      );
    } else {
      print("Context not mounted");
    }
  }


List<String> divideString(String? input) {
  if (input == null || input.isEmpty) {
    return ["", ""];
  }

  List<String> parts = input.split(' ');

  if (parts.length == 1) {
    return [input, ""];
  }

  return parts;
}

Future<void> takesinglepresetatt(int std_id, int classID) async {
  await supabase.rest
      .from('attendance')
      .insert({'student_id': std_id, 'class_id': classID,'date':DateTime.now().toIso8601String().substring(0, 10),'attendance_status':'present'});
  print("Present att taken $std_id for $classID");
}
Future<void> recordattendanceasAbsent(List<int> studentids, int classID) async {
  List<int> studentIDs = [];
  for (var stdid in studentIDs) {
    takesinglepresetatt(stdid, classID);
  }
}

Future<void> takesingleAbsentatt(int std_id, int classID) async {
  await supabase.rest
      .from('attendance')
      .insert({'student_id': std_id, 'class_id': classID,'date':DateTime.now().toIso8601String().substring(0, 10),'attendance_status':'absent'});
  print("Absent att taken $std_id for $classID");
}

Future<String> getstudentnamefromid(int studentId) async {
  // 1. Fetch user_id from students table
  final studentResult = await supabase.from('students').select('user_id').eq('student_id', studentId).single();
  if (studentResult.isEmpty) {
    throw studentResult; // Handle database errors appropriately
  }
  final userId = studentResult['user_id'] as String; // Access user_id from the result

  // 2. Fetch first_name and last_name from user_profiles table
  final nameResult = await supabase.from('user_profiles').select('first_name, last_name').eq('user_id', userId).single();
  if (nameResult.isEmpty) {
    throw nameResult; // Handle database errors
  }
  final fullName = nameResult['first_name'].toString() + ' ' + nameResult['last_name'].toString(); // Combine first and last name

  return fullName;
}


 Future<List<dynamic>> enrolledstdsrec(String classId) async {
    final enrolledResponse = await supabase.rest
        .from('enrollments')
        .select('student_id')
        .filter('class_id', 'eq', '${classId}');

    final enrollmentData = enrolledResponse as List<dynamic>;
    return enrollmentData.isEmpty
        ? ['0']
        : enrollmentData;
  }



  Future<int> calculateAttendanceDays(int studentId, int classId) async {
    if (studentId == 0 || classId == 0) {
      return 0;
    }
    final attendanceResponse = await supabase.rest
        .from('attendance')
        .select('date')
        .filter('student_id', 'eq', '$studentId')
        .filter('class_id', 'eq', '$classId')
        .filter('attendance_status', 'eq', 'present');

    final attendanceData = attendanceResponse as List<dynamic>;
    return attendanceData.isEmpty
        ? 0
        : attendanceData.length;
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


Future<String> getMajorfromID(int stdid) async{
  final res = await supabase.rest.from('students').select('major').eq('student_id', stdid.toString()).single();
  final major = res['major'] as String;

  return major.isNotEmpty ? major : "No Students";


}

Future<String> getClassNamefromID(String classid) async{
   String name;
  try {
      final data = await supabase.rest.from('classes').select('classname').eq('id', classid).single();
      name = data['classname'] as String;

  }
  on PostgrestException {
    print("PostgrestException getClassNamefromID $classid");
    return "";
  }
  return name.isNotEmpty ? name : "";
}


 Future<List<dynamic>> enrolledclassessrec(String StudentID) async {
    final enrolledResponse = await supabase.rest
        .from('enrollments')
        .select('class_id')
        .filter('student_id', 'eq', '${StudentID}');

    final enrollmentData = enrolledResponse as List<dynamic>;
    return enrollmentData.isEmpty
        ? ['0']
        : enrollmentData;
  }

 Future<List<dynamic>> enrolledclassesforlec(String classlecid) async {
    final enrolledResponse = await supabase.rest.from('classes').select('id').eq('classlecturer_profile_id', '${classlecid}');

    final enrollmentData = enrolledResponse as List<dynamic>;
    return enrollmentData.isEmpty
        ? ['0']
        : enrollmentData;
  }

void Exceptionsnackbar(context,String stringex) { // Implement this with all try catchs on every await/db query

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 1000),
        content:  Text(stringex),
        backgroundColor: Color.fromARGB(255, 115, 64, 64),
      ));
}



double responsiveFontSize(BuildContext context, double size) {
  // Obtain the screen width
  double screenWidth = MediaQuery.of(context).size.width;
  print("Screen width = ${screenWidth}");
  // Base width used during development (e.g., the width of your typical device screen)
  double baseWidth = screenWidth >= 410 ? 380 : 392.72727272727275; // You can adjust this value based on your design

  // Calculate the scale ratio
  double scaleRatio = screenWidth / baseWidth;

  // Return the adjusted font size
  return size * scaleRatio;
}



double responsiveWidgetSize(BuildContext context, double size) {
  // Obtain the screen width
  double screenHeight = MediaQuery.of(context).size.height;

  print("Screen Height = ${screenHeight}");
  // Base width used during development (e.g., the width of your typical device screen)
  double baseHeight = screenHeight >=820 ? 950 : 783.2727272727273; // You can adjust this value based on your design

  // Calculate the scale ratio
  double scaleRatio = screenHeight / baseHeight;

  // Return the adjusted font size
  return size * scaleRatio;
}


String replaceBaseUrl(String originalUrl) {
  String newBaseUrl = '${ipaddress}';
  // Parse the original URL
  Uri uri = Uri.parse(originalUrl);

  // Create a new URI using the original components but replacing the host
  Uri newUri = uri.replace(host: newBaseUrl);

  // Return the new URL as a string
  return newUri.toString();
}