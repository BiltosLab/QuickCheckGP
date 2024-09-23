/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */

import 'dart:ffi';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickcheck/Screens/Students_Info_Screen.dart';
import 'package:quickcheck/components/Buttons.dart';
import 'package:quickcheck/main.dart';
import 'package:quickcheck/utils/GlobalFunctions.dart';

class IDcheckScreen extends StatefulWidget {
    final String search;

  const IDcheckScreen({super.key,this.search = ''});

  @override
  State<IDcheckScreen> createState() => _IDcheckScreenState();
}

class _IDcheckScreenState extends State<IDcheckScreen> {
  List<Map<String, dynamic>> searchResults = [];
  String searchQuery = '';
    final _searchcontroller= TextEditingController();





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
    final response = await supabase
        .from('students')
        .select('user_id,student_id')
        .ilike('studentidstr', '%${chars.toString()}%');
    
    if (response.isNotEmpty) {
      if (mounted) {
        setState(() {
          searchResults = response as List<Map<String, dynamic>>;
        });
      }
    } else {
      print('Error searching users: ${response.toString()}');
    }
    } catch (e) {
      Exceptionsnackbar(context, "Error,please check with admins");

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
          "ID Check",
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
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                      (user['student_id'].toString()),
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => ChatScreen(
                      //               currentUserId:
                      //                   supabase.auth.currentUser!.id,
                      //               otherUserId: user['user_id'],
                      //             )));
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StudentsInfoScreen(
                                    ClassID: '0',
                                    StudentID: user['student_id'],
                                    permit: false,
                                  )));
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
