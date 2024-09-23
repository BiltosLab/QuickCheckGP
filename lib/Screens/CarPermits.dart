/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:quickcheck/Screens/Lecturer_info.dart';
import 'package:quickcheck/Screens/Students_Info_Screen.dart';
import 'package:quickcheck/Screens/main_screen.dart';
import 'package:quickcheck/components/Buttons.dart';
import 'package:quickcheck/main.dart';
import 'package:quickcheck/utils/GlobalFunctions.dart';

class CarPermitsScreen extends StatefulWidget {
  final String search;
  const CarPermitsScreen({super.key, this.search = ''});

  @override
  State<CarPermitsScreen> createState() => _CarPermitsScreenState();
}

class _CarPermitsScreenState extends State<CarPermitsScreen> {
  List<Map<String, dynamic>> searchResults = [];
  String searchQuery = '';
  final _searchcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      searchQuery = widget.search;
      if (widget.search.isNotEmpty) {
        _searchcontroller.text = searchQuery;
        _searchuser(searchQuery);
      }
    });
  }

  Future<void> _searchuser(String chars) async {
    searchuser(chars);
  }

  Future<void> searchuser(String chars) async {
    try {
      final response = await supabase.rest
          .from('carpermits')
          .select('user_id,license_plate')
          .ilike('licplate', '%${chars.toString()}%');

      if (response.isNotEmpty) {
        if (mounted) {
          setState(() {
            searchResults = response as List<Map<String, dynamic>>;
            print("search ${searchResults.toString()}");
          });
        }
      } else {
        print('Error searching users: ${response.toString()}');
      }
    } catch (e) {
      Exceptionsnackbar(context, "Error searching users,please check with admins");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 39, 70),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 36, 39, 70),
        leading: const Back_Button(),
        title: const Text(
          "License Plate Check",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchcontroller,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  if (mounted) {
                    setState(() {
                      searchQuery = value;
                    });
                  }
                  searchuser(value);
                },
                decoration: const InputDecoration(
                  labelText: 'Search by name',
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final user = searchResults[index];
                  return ListTile(
                    title: Text(
                      (user['license_plate'].toString()),
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      final res = await supabase.rest
                          .from('user_profiles')
                          .select('user_type_id')
                          .eq('user_id', user['user_id'])
                          .single();
                      if (res['user_type_id'] == 1) {
                        final ap = await supabase.rest
                            .from('students')
                            .select('student_id')
                            .eq('user_id', user['user_id'])
                            .single();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StudentsInfoScreen(
                                      ClassID: '0',
                                      StudentID: ap['student_id'],
                                      permit: true,
                                    )));
                      } else if (res['user_type_id'] == 2) {
                        final data = await supabase.rest
                            .from('user_profiles')
                            .select('id')
                            .eq('user_id', '${user['user_id']}')
                            .single();
                            Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LecturerInfoScreen(LecturerID: data['id'].toString())));
                      } else if (res['user_type_id'] == 3) {
                            Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ErrorPage(errorstr: "Contact Admin Something is wrong with DB.")));
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
