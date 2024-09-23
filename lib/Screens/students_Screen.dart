/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */

import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quickcheck/Screens/Classtimes.dart';
import 'package:quickcheck/Screens/Lecturers_List_Screen.dart';
import 'package:quickcheck/Screens/Marks_Screen.dart';
import 'package:quickcheck/Screens/Messages_Screen.dart';
import 'package:quickcheck/main.dart';
import 'package:quickcheck/Screens/main_screen.dart';
import 'package:quickcheck/Screens/student_attendance.dart';
import 'package:quickcheck/utils/GlobalFunctions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  var userfullname = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(
        height: 20,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
              onTap: () async {
                final usersid = supabase.auth.currentUser?.id;

                final studentsid = await supabase.rest
                    .from('students')
                    .select('student_id')
                    .eq('user_id', '$usersid');
                final studentId = studentsid.isNotEmpty
                    ? studentsid[0]['student_id'] as int
                    : 0;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MarksTableScreen(
                        studentId: studentId,
                      ),
                    ));
              },
              child: Clickablebox(
                  pic: 'assets/icons/marksicon.svg',
                  picw: 0.35,
                  pich: 0.35,
                  text: "Grades",
                  picpadding: 0.05,
                  textpadding: 0.14)),
          GestureDetector(
            onTap: () async {
              final response = await supabase.rest
                  .from('user_profiles')
                  .select('user_id')
                  .eq('id', '1')
                  .single();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MessagesScreen(),
                  ));
            },
            child: Clickablebox(
              pic: 'assets/icons/chat1.svg',
              text: "Messages",
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
                    builder: (context) => const LecturersList(),
                  ));
            },
            child: Clickablebox(
              pic: 'assets/icons/classpicnetwork.svg',
              text: "Lecturers",
              picw: 0.5,
              pich: 0.5,
              picpadding: 0.0,
              textpadding: 0.05,
            ),
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(top: 13.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () async {
                try {
                  List<DataRow> dataRows;
                  final stdid = await supabase.rest
                      .from('students')
                      .select('student_id')
                      .eq('user_id', '${supabase.auth.currentUser!.id}')
                      .single();
                  final StudentID = stdid['student_id'].toString();
                  final cdata = <Map<String, dynamic>>[];
                  final usersid = supabase.auth.currentUser!.id as String;
                  final enr = await enrolledclassessrec(StudentID.toString());

                  if (enr.isNotEmpty) {
                    for (var classid in enr) {
                      final cname = await getClassNamefromID(
                          classid['class_id'].toString());
                      final dbres = await supabase.rest
                          .from('classes')
                          .select(
                              'classname,classtime,classlocation,classlecturer_profile_id')
                          .eq('id', '${classid['class_id']}')
                          .single();

                      cdata.add({
                        'classname': cname,
                        'classtime': dbres['classtime'],
                        'classlocation': dbres['classlocation'],
                        'classlecturer_profile_id':
                            dbres['classlecturer_profile_id'],
                      });
                    }
                  }
                  dataRows = cdata
                      .map((data) => DataRow(
                            cells: [
                              DataCell(Text(
                                data['classname'],
                              )),
                              DataCell(Text(
                                data['classtime'].toString(),
                              )),
                              DataCell(Text(
                                data['classlocation'].toString(),
                              ))
                            ],
                            onLongPress: () {
                              print("data ${data.toString()}");
                            },
                          ))
                      .toList();

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Classtimes(
                          classestimes: dataRows,
                        ),
                      ));
                } catch (e) {
                  Exceptionsnackbar(context, "Error fetching data $e");
                }
              },
              child: Clickablebox(
                pic: 'assets/icons/clockicon.svg',
                text: "Class Time",
                picw: 0.4,
                pich: 0.4,
                picpadding: 0.05,
                textpadding: 0.1,
              ),
            ),
            FillerClickablebox(),
            FillerClickablebox()
          ],
        ),
      ),
    ]);
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
      this.bottextpadding = 0.0,
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
            padding: EdgeInsets.only(
                top: height * picpadding, bottom: botpicpadding * height),
            child: SvgPicture.asset(
              pic,
              width: width * picw,
              height: pich * height,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: height * textpadding, bottom: bottextpadding * height),
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
