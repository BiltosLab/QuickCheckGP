/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */

import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quickcheck/Screens/Lecturer_info.dart';
import 'package:quickcheck/components/Buttons.dart';
import 'package:quickcheck/main.dart';
import 'package:quickcheck/utils/GlobalFunctions.dart';

class LecturersList extends StatefulWidget {
  const LecturersList({super.key});

  @override
  State<LecturersList> createState() => _LecturersListState();
}

class _LecturersListState extends State<LecturersList> {
  bool isloading = true;
  var datab = <Map<String, dynamic>>[];

  Future<void> fetchData() async {
    try {
      final res = await supabase.rest
          .from('students')
          .select('student_id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .single();
      final stdId = res['student_id'];
      final data = await enrolledclassessrec(stdId.toString());

      for (var e in data) {
        var lecturername;
        var dat = await supabase.rest
            .from('classes')
            .select('classname,classtime,classlecturer_profile_id')
            .eq('id', e['class_id'])
            .single();

        lecturername = await supabase.rest
            .from('user_profiles')
            .select('first_name,last_name')
            .eq('id', dat['classlecturer_profile_id'])
            .single();

        var exists = datab.any((element) =>
            element['lecrID'] == dat['classlecturer_profile_id'].toString());

        if (exists) {
          continue;
        }
        datab.add({
          'classname': dat['classname'].toString(),
          'classtime': dat['classtime'].toString(),
          'lecname':
              '${lecturername['first_name'].toString()} ${lecturername['last_name'].toString()}',
          'lecrID': dat['classlecturer_profile_id'].toString(),
        });
      }

      if (datab.isNotEmpty) {
        if (mounted) {
          setState(() {
            this.datab = datab;
            isloading = false;
          });
        }
      }
    } catch (e) {
      print('error');
      Exceptionsnackbar(context, "Error,please check with admins");
    }
  }

  Future<void> _fetchData() async {
    await fetchData();
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return isloading
        ? const Center(
            child: const CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: const Color.fromARGB(255, 36, 39, 70),
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 51, 54, 97),
              leading: const Back_Button(),
              title: const Text(
                "Lecturers",
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
            body: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: ListView.builder(
                itemCount: datab.length,
                itemBuilder: (context, index) {
                  final lecturerdatab = datab[index];
                  return LecturerlilWidget(
                    LecturerName: lecturerdatab['lecname'],
                    LecturerID: lecturerdatab['lecrID'],
                  );
                },
              ),
            ),
          );
  }
}

class LecturerlilWidget extends StatelessWidget {
  final LecturerName;
  final LecturerID;
  const LecturerlilWidget(
      {super.key, required this.LecturerName, required this.LecturerID});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LecturerInfoScreen(
                        LecturerID: LecturerID,
                      )));
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: 45,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 64, 66, 115),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${LecturerName}",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500),
              ),
              Container(
                child: Transform.flip(
                  flipX: true,
                  child: SvgPicture.asset(
                    'assets/icons/backbutton.svg',
                    width: 20,
                    height: 20,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
