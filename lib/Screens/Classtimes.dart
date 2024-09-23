/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */
 
import 'package:flutter/material.dart';
import 'package:quickcheck/components/Buttons.dart';

class Classtimes extends StatelessWidget {
  List<DataRow> classestimes;
  Classtimes({super.key,required this.classestimes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 51, 54, 97),
        title: const Text(
          "Class Times",
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white,fontSize: 20),
        ),
        leading: const Back_Button(),
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
      backgroundColor: const Color.fromARGB(255, 36, 39, 70),
      body: Container(
        child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: SingleChildScrollView(
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
                      rows: classestimes,
                    ),
                  ),
                ),
      ),
    );
  }
}