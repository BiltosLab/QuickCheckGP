/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */

import 'dart:io';
import 'dart:async';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quickcheck/main.dart';
import 'package:quickcheck/Screens/Lecturer_classes_screen.dart';
import 'package:quickcheck/Screens/Lecturers_Screen.dart';
import 'package:quickcheck/Screens/Security_Guard_Screen.dart';
import 'package:quickcheck/Screens/profile_screen.dart';
import 'package:quickcheck/Screens/student_attendance.dart';
import 'package:quickcheck/Screens/students_Screen.dart';
import 'package:quickcheck/components/Buttons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:quickcheck/utils/GlobalFunctions.dart';

import 'Camera_Screen.dart';

class MainScreen extends StatefulWidget {
  // String holder = '';
  // This is Mainscreen for lecturers
  MainScreen({super.key,});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentPageIndex = 0;
  Color classescolor = Colors.white;

  @override
  void initState() {
    super.initState();
    if (currentloggedinusertype == 3) {
      classescolor = Colors.grey;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var destinations = <Widget>[
      NavigationDestination(
        icon: SvgPicture.asset(
          currentPageIndex == 0
              ? 'assets/icons/homebuttonf.svg'
              : 'assets/icons/homebutton.svg',
          width: 25,
          height: 25,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        label: 'Home',
      ),
      NavigationDestination(
        icon: SvgPicture.asset(
          currentPageIndex == 1
              ? 'assets/icons/classiconf.svg'
              : 'assets/icons/classicon.svg',
          width: 25,
          height: 25,
          colorFilter: ColorFilter.mode(classescolor, BlendMode.srcIn),
        ),
        label: 'Classes',
      ),
      NavigationDestination(
        icon: SvgPicture.asset(
          currentPageIndex == 2
              ? 'assets/icons/profilebuttonf.svg'
              : 'assets/icons/profilebutton.svg',
          width: 30,
          height: 30,
        ),
        label: 'Profile',
      ),
    ];
    var secdestinations = <Widget>[
      NavigationDestination(
        icon: SvgPicture.asset(
          currentPageIndex == 0
              ? 'assets/icons/homebuttonf.svg'
              : 'assets/icons/homebutton.svg',
          width: 25,
          height: 25,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        label: 'Home',
      ),
      NavigationDestination(
        icon: SvgPicture.asset(
          currentPageIndex == 1
              ? 'assets/icons/Settingsnav2.svg'
              : 'assets/icons/Settingsnav1.svg',
          width: 40,
          height: 40,

        ),
        label: 'Settings',
      ),
    ];
    var mainlist = <Widget>[
      if (currentloggedinusertype == 1)
        const StudentsScreen()
      else if (currentloggedinusertype == 2)
        const Lecturer_Screen()
      else
        ErrorPage(
          errorstr: "WRONG USER_TYPE, PLEASE CHECK WITH ADMINISTRATION",
        ),
      if (currentloggedinusertype == 1)
        const StudentAttendanceScreen()
      else if (currentloggedinusertype == 2)
        const Lecturerclasses()
      else
        ErrorPage(
          errorstr: "WRONG USER_TYPE, PLEASE CHECK WITH ADMINISTRATION",
        ),
      if (currentloggedinusertype == 1)
        StudentProfileScreen()
      else if (currentloggedinusertype == 2)
        LecturerProfileScreen()
    ];
    var seclist = <Widget>[
        const Sec_guard_screen(),
      SecurityProfileScreen()
    ];
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 39, 70),
      appBar: AppBar(
        actions: [
          currentPageIndex == 2
              ? GestureDetector(
                  onTap: () =>
                      navigatorKey.currentState?.pushNamed('/settings'),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: SvgPicture.asset(
                        'assets/icons/settingsbuttonnew.svg',
                        width: 30,
                        height: 30,
                        colorFilter:
                            const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                  ),
                )
              : const SizedBox(
                  width: 0,
                  height: 0,
                ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 51, 54, 97),
        title: const Text(
          "QuickCheck",
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: const Color.fromARGB(255, 74, 76, 133),
            height: 1.0,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.transparent,
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(color: Colors.white),
          ),
        ),
        child: NavigationBar(
          elevation: 0.1,
          backgroundColor: const Color.fromARGB(255, 51, 54, 97),
          destinations:
              currentloggedinusertype == 3 ? secdestinations : destinations,
          selectedIndex: currentPageIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (int index) {
            if (mounted) {
              setState(() {
                currentPageIndex = index;
              });
            }
          },
        ),
      ),
      body: currentloggedinusertype == 3
          ? seclist[currentPageIndex]
          : mainlist[currentPageIndex],
    );
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
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          SignOut()
        ],
      ),
    );
  }
}

Container nextclasswidget(String nextclass) {
  return Container(
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color.fromARGB(255, 230, 252, 249)),
    padding:
        const EdgeInsets.all(10),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.start,
          children: [
            Text(
              "$nextclass",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const Row(
          mainAxisAlignment:
              MainAxisAlignment.start,
          children: [
            Text(
              "",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        )
      ],
    ),
  );
}

// Future<String> getNextClass() async {
//   var now = DateTime.now();
//   var todayShort = DateFormat('E').format(now).substring(0, 1);

//   // Adjust the query as needed to fit your table and column names
//   var response = await supabase
//       .from('classes')
//       .select('classname, classtime');

//   if (response.isEmpty) {
//     return 'Error: ${response.toString()}';
//   }

//   var classes = response as List<Map<String, dynamic>>;
//   var upcomingClasses = classes.map((classData) {
//     var times = classData['classtime'].split(' ');
//     var hours = times[0].split('-').map((time) => DateFormat('h:mm').parse(time.trim())).toList();
//     var days = times[1];

//     return {
//       'classname': classData['classname'],
//       'startTime': DateTime(now.year, now.month, now.day, hours[0].hour, hours[0].minute),
//       'endTime': DateTime(now.year, now.month, now.day, hours[1].hour, hours[1].minute),
//       'days': days
//     };
//   }).where((classData) => classData['days'].contains(todayShort) &&
//       classData['startTime'].isAfter(now))
//     .toList();

//   upcomingClasses.sort((a, b) => a['startTime'].compareTo(b['startTime']));

//   return upcomingClasses.isNotEmpty ? '${upcomingClasses.first['classname']} at ${DateFormat('h:mm a').format(upcomingClasses.first['startTime'])}' : 'No classes today';
// }

Future<String> getNextClass() async {
  var now = DateTime.now();
  var todayShort = DateFormat('E').format(now).substring(0, 1);

  // Adjust the query as needed to fit your table and column names
  var response = await supabase.from('classes').select('classname, classtime');

  print("GETNEXTCLASS ${response.toList().toString()}");
  if (response.isEmpty) {
    return 'Error fetching data: ${response ?? 'No data available'}';
  }

  var classes = response as List<dynamic>;
  List<Map<String, dynamic>> upcomingClasses = [];

  for (var classData in classes) {
    var classtime = classData['classtime'] ?? '';
    var parts = classtime.split(' ');
    print("PARTSXD $parts");
    if (parts.length < 2) continue;
    print("PARTSXD $parts");

    var times = parts[0].split('-');
    print("TIMESXD $times");

    if (times.length < 2) continue;

    var days = parts[1];
    print("DAYSXD $days");
    List<DateTime> hours;
    try {
      hours = times.map((time) => DateFormat('h:mm').parse(time.trim(), true));

      print("Hourrs XD ${hours.toList()}");
    } catch (e) {
            // Exceptionsnackbar(e,"Failed to recognize text from the image"); // todo check this garbage
      
      continue; // Skip if time parsing fails
    }

    var startTime =
        DateTime(now.year, now.month, now.day, hours[0].hour, hours[0].minute);
    var endTime =
        DateTime(now.year, now.month, now.day, hours[1].hour, hours[1].minute);
    print("STARTTIMEXD ${startTime}");
    print("ENDTIMEXD ${endTime}");

    if (days.contains(todayShort) && startTime.isAfter(now)) {
      upcomingClasses.add({
        'classname': classData['classname'],
        'startTime': startTime,
        'endTime': endTime,
        'days': days
      });
    }
  }

  upcomingClasses.sort((a, b) => a['startTime'].compareTo(b['startTime']));

  return upcomingClasses.isNotEmpty
      ? '${upcomingClasses.first['classname']} at ${DateFormat('h:mm a').format(upcomingClasses.first['startTime'])}'
      : 'No classes today';
}
