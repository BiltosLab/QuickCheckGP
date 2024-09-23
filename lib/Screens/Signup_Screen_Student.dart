/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */
 
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quickcheck/main.dart';
import 'package:quickcheck/utils/GlobalFunctions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum Gender {
  male('Male'),
  female('Female');

  const Gender(this.name);
  final String name;
}


class StudentSignUpScreen extends StatefulWidget {
  const StudentSignUpScreen({super.key});

  @override
  State<StudentSignUpScreen> createState() => _StudentSignUpScreenState();
}

class _StudentSignUpScreenState extends State<StudentSignUpScreen> {
  final _signupfullname = TextEditingController();

  final _signupstudentID = TextEditingController();

  Gender? _selectedGender;

  final _signuppassword = TextEditingController();

  final _signupemail = TextEditingController();

  final _signupconfirmpassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 36, 39, 70),
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Padding(padding: EdgeInsets.only(top: 100)),
                const Center(
                  child: Text(
                    "Sign up",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Center(
                  child: Text(
                    "Create your account",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Padding(
                    padding:
                        const EdgeInsets.only(top: 15, right: 20, left: 20),
                    child: TextField(
                        controller: _signupfullname,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(
                              color: Color.fromARGB(255, 180, 180, 180)),
                          border: OutlineInputBorder(),
                          hintText: 'Name',
                        ))),
                Padding(
                    padding:
                        const EdgeInsets.only(top: 15, right: 20, left: 20),
                    child: TextField(
                        controller: _signupstudentID,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(
                              color: Color.fromARGB(255, 180, 180, 180)),
                          border: OutlineInputBorder(),
                          hintText: 'Student ID',
                        ))),
                Padding(
                    padding:
                        const EdgeInsets.only(top: 15, right: 20, left: 20),
                    child: TextField(
                        style: const TextStyle(color: Colors.white),
                        controller: _signupemail,
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(
                              color: Color.fromARGB(255, 180, 180, 180)),
                          border: OutlineInputBorder(),
                          hintText: 'Email',
                        ))),
                Padding(
                    padding:
                        const EdgeInsets.only(top: 15, right: 20, left: 20),
                    child: TextField(
                        obscureText: true,
                        controller: _signuppassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(
                              color: Color.fromARGB(255, 180, 180, 180)),
                          border: OutlineInputBorder(),
                          hintText: 'Password',
                        ))),
                Padding(
                    padding:
                        const EdgeInsets.only(top: 15, right: 20, left: 20),
                    child: TextField(
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        controller: _signupconfirmpassword,
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(
                              color: Color.fromARGB(255, 180, 180, 180)),
                          border: OutlineInputBorder(),
                          hintText: 'Confirm Password',
                        ))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 15),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 80, 64, 153),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color.fromARGB(255, 104, 86,
                                173),
                            width: 2,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Gender>(
                            hint: const Text(
                              "Select Gender",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            dropdownColor: const Color.fromARGB(255, 80, 64, 153),
                            value: _selectedGender,
                            onChanged: (Gender? newValue) {
                              if (mounted) {
                                setState(() {
                                  _selectedGender = newValue;
                                });
                              }
                            },
                            items: getDropdownMenuItemsG(),
                            iconEnabledColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        fixedSize: MaterialStatePropertyAll(
                            Size(MediaQuery.of(context).size.width * 0.90, 45)),
                        backgroundColor: const MaterialStatePropertyAll(
                            Color.fromARGB(255, 64, 66, 115))),
                    onPressed: () async {
                      if (_signuppassword.text == _signupconfirmpassword.text) {
                        if (_signuppassword.text.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text("Password is too short"),
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                          ));
                          return;
                        }

                        try {
                          final AuthResponse res = await supabase.auth.signUp(
                            email: _signupemail.text,
                            password: _signuppassword.text,
                          );

                          final User? user = res.user;
                          final name = divideString(_signupfullname.text);
                      if (name.length < 2) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(milliseconds: 800),
                          content: const Text(
                              "Please enter your name as two parts: first and last name."),
                          backgroundColor: Theme.of(context).primaryColorDark,
                        ));
                        return;
                      }
                      final firstname = name[0];
                      final lastname = name[1];

                          if (_selectedGender != null) {
                            if (_selectedGender == Gender.male) {
                              await supabase.rest.from('user_profiles').insert({
                                'user_type_id': 1,
                                'user_id': user!.id,
                                'first_name': firstname,
                                'last_name': lastname,
                                'gender': 'male'
                              });
                            }
                            else if (_selectedGender == Gender.female) {
                              await supabase.rest.from('user_profiles').insert({
                                'user_type_id': 1,
                                'user_id': user!.id,
                                'first_name': firstname,
                                'last_name': lastname,
                                'gender': 'female'
                              });
                            }
                          }
                          else if (_selectedGender == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              duration: const Duration(milliseconds: 800),
                              content: const Text("Enter your Gender!"),
                              backgroundColor:
                                  Theme.of(context).primaryColorDark,
                            ));
                            return;
                          }

                          await supabase.from('students').insert({
                            'student_id': _signupstudentID.text,
                            'user_id': user!.id,
                          });

                          await supabase.auth.signOut(scope: SignOutScope.local);
                          Navigator.pop(context);

                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                  "Something went wrong please try again later."),
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                "Please enter the same password in both fields."),
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                          ),
                        );
                        return;
                      }
                    },
                    child: const Text(
                      "Sign Up",
                      style:
                          TextStyle(color: Color.fromARGB(255, 241, 246, 249)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  List<DropdownMenuItem<Gender>> getDropdownMenuItemsG() {
    List<DropdownMenuItem<Gender>> items = [];
    for (Gender type in Gender.values) {
      items.add(
        DropdownMenuItem(
          value: type,
          child: Text(
            type.name,
            style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
        ),
      );
    }
    return items;
  }
}
