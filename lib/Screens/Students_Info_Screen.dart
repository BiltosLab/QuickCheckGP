/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */
 
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quickcheck/Screens/Lecturers_Screen.dart';
import 'package:quickcheck/Screens/Marks_Screen.dart';
import 'package:quickcheck/components/Buttons.dart';
import 'package:quickcheck/main.dart';
import 'package:quickcheck/utils/GlobalFunctions.dart';

class StudentsInfoScreen extends StatefulWidget {
  final ClassID;
  final StudentID;
  final permit;
  StudentsInfoScreen(
      {super.key, required this.ClassID, required this.StudentID,required this.permit});

  @override
  State<StudentsInfoScreen> createState() => _StudentsInfoScreenState();
}

class _StudentsInfoScreenState extends State<StudentsInfoScreen> {
  late String fullname = '';
  late String major = '';
  late Map<String, dynamic> user_profiles = {};
  late Map<String, dynamic> studentdata = {};
  late List<dynamic> enrolledc = [];

  late String imageUrl = '';
  bool isinitalizing = true;
  List<DataRow> dataRows = [];

  @override
  void initState() {
    super.initState();
    _getfullinfo().whenComplete(() => null);
  }

  Future<void> _getfullinfo() async {
    await getfullinfo();
  }

  Future<void> getfullinfo() async {
    final data = await supabase.rest
        .from('students')
        .select()
        .eq('student_id', '${widget.StudentID.toString()}')
        .single();
    final cdata = <Map<String, dynamic>>[];
    final usersid = data['user_id'] as String;
    final res = await supabase.rest
        .from('user_profiles')
        .select()
        .eq('user_id', usersid)
        .single();
    final enr = await enrolledclassessrec(widget.StudentID.toString());

    if (enr.isNotEmpty) {
      for (var classid in enr) {
        final cname = await getClassNamefromID(classid['class_id'].toString());
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
          'classlecturer_profile_id': dbres['classlecturer_profile_id'],
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
    if (mounted) {
      setState(() {
        imageUrl = res['avatar_url'].toString();
        user_profiles = res;
        studentdata = data;
      });
    }
    if (res.isNotEmpty) {
      if (mounted) {
        setState(() {
          isinitalizing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isinitalizing
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: const Color.fromARGB(255, 36, 39, 70),
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 51, 54, 97),
              leading: const Back_Button(),
              title: const Text(
                "Student Info",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: Container(
                  color: const Color.fromARGB(
                      255, 74, 76, 133),
                  height: 1.0,
                ),
              ),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 15, right: 15, left: 15, top: 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: MediaQuery.of(context).size.height * 0.20,
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10.0,
                                spreadRadius: 2.0,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: (imageUrl.isEmpty || imageUrl == null)
                                ? SvgPicture.asset(
                                    'assets/icons/malev.svg',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    replaceBaseUrl(imageUrl),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment
                                  .center,
                              children: [
                                Text(
                                  'Name: ${user_profiles['first_name']} ${user_profiles['last_name']}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                    height:
                                        5),
                                Text(
                                  'ID: ${widget.StudentID}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                    height:
                                        5),
                                Text(
                                  'Major: ${studentdata['major']}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                    height:
                                        5),
                                widget.permit ? const Text(
                                  'Car Permit : Allowed',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ) : const SizedBox(),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        "Courses",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: Divider(
                    color: Colors.grey[600],
                    thickness: 1,
                  ),
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
                    columns: [
                      const DataColumn(
                          label: Text(
                        'Course',
                        textAlign: TextAlign.start,
                      )),
                      const DataColumn(
                          label: Text(
                        'Time',
                        textAlign: TextAlign.start,
                      )),
                      const DataColumn(
                          label: Text(
                        'Location',
                        textAlign: TextAlign.start,
                      )),
                    ],
                    rows: dataRows,
                  ),
                ),
              ],
            ),
          );
  }
}

class StudentSelectionScreeninfo extends StatefulWidget {
  final ClassID;
  final enrolledStudents;
  StudentSelectionScreeninfo(
      {super.key, required this.ClassID, required this.enrolledStudents});

  @override
  State<StudentSelectionScreeninfo> createState() =>
      _StudentSelectionScreeninfoState();
}

class _StudentSelectionScreeninfoState
    extends State<StudentSelectionScreeninfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 39, 70),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 51, 54, 97),
        leading: const Back_Button(),
        title: const Text(
          "Select Student",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: const Color.fromARGB(
                255, 74, 76, 133),
            height: 1.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: ListView.builder(
          itemCount: widget.enrolledStudents.length,
          itemBuilder: (context, index) {
            final studentsdata = widget.enrolledStudents[index];
            return StudentlilWidget(
              student_name: studentsdata['name'],
              student_id: studentsdata['student_id'],
              class_id: widget.ClassID,
              marks: false,
            );
          },
        ),
      ),
    );
  }
}
