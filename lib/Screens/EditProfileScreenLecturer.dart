/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */
 
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quickcheck/components/Buttons.dart';
import 'package:quickcheck/main.dart';
import 'package:quickcheck/utils/GlobalFunctions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum Gender {
  male('Male'),
  female('Female');

  const Gender(this.name);
  final String name;
}

class EditProfileScreenLecturer extends StatefulWidget {
  const EditProfileScreenLecturer({super.key});

  @override
  State<EditProfileScreenLecturer> createState() =>
      _EditProfileScreenLecturerState();
}

class _EditProfileScreenLecturerState extends State<EditProfileScreenLecturer> {
  Gender? _selectedGender;

  final _fullnamecontroller = TextEditingController();

  final _officehourscontroller = TextEditingController();

  final _emailcontroller = TextEditingController();

  final _facultycontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 36, 39, 70),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 51, 54, 97),
          title: const Text(
            "Edit Profile",
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          leading: const Back_Button(),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: const Color.fromARGB(
                  255, 74, 76, 133), // Choose any color you like
              height: 1.0, // Control the thickness of the bar
            ),
          ),
        ),
        body: Container(
            child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.only(top: 50)),
              const Center(
                child: Text(
                  "Leave the field empty if you dont want to change",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 15, right: 20, left: 20),
                  child: TextField(
                      controller: _fullnamecontroller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(
                            color: Color.fromARGB(255, 180, 180, 180)),
                        border: OutlineInputBorder(),
                        hintText: 'Name',
                      ))),
              Padding(
                  padding: const EdgeInsets.only(top: 15, right: 20, left: 20),
                  child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _emailcontroller,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(
                            color: Color.fromARGB(255, 180, 180, 180)),
                        border: OutlineInputBorder(),
                        hintText: 'Email',
                      ))),
              Padding(
                  padding: const EdgeInsets.only(top: 15, right: 20, left: 20),
                  child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _officehourscontroller,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(
                            color: Color.fromARGB(255, 180, 180, 180)),
                        border: OutlineInputBorder(),
                        hintText: 'Office Hours eg (10:00 - 11:00 Sunday)',
                      ))),
              Padding(
                  padding: const EdgeInsets.only(top: 15, right: 20, left: 20),
                  child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _facultycontroller,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(
                            color: Color.fromARGB(255, 180, 180, 180)),
                        border: OutlineInputBorder(),
                        hintText: 'Faculty eg (Information Technology)',
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
                            style: TextStyle(color: Colors.white, fontSize: 14),
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
                    navigatorKey.currentState?.pushNamed('/changepasswd');
                  },
                  child: const Text(
                    "Change Password",
                    style: TextStyle(color: Color.fromARGB(255, 241, 246, 249)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  style: ButtonStyle(
                      fixedSize: MaterialStatePropertyAll(
                          Size(MediaQuery.of(context).size.width * 0.90, 45)),
                      backgroundColor: const MaterialStatePropertyAll(
                          Color.fromARGB(255, 64, 66, 115))),
                  onPressed: () async {
                    ShowtipDialog(context);
                  },
                  child: const Text(
                    "Confirm",
                    style: TextStyle(color: Color.fromARGB(255, 241, 246, 249)),
                  ),
                ),
              ),
            ],
          ),
        )));
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

  Future<void> ShowtipDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Warning'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text("Are you sure?"),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              // SizedBox(
              //   width: MediaQuery.of(context).size.width * 0.305,
              // ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () async {
                  final userid = supabase.auth.currentUser?.id;
                  try {
                    if (_fullnamecontroller.text.isNotEmpty) {
                      final name = divideString(_fullnamecontroller.text);
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
                      await supabase.rest.from('user_profiles').update({
                        'first_name': firstname,
                        'last_name': lastname
                      }).eq('user_id', userid!);
                    }
                    if (_emailcontroller.text.isNotEmpty) {
                      final UserResponse res = await supabase.auth.updateUser(
                        UserAttributes(
                          email: _emailcontroller.text,
                        ),
                      );
                    }
                    if (_selectedGender != null) {
                      if (_selectedGender == Gender.male) {
                        await supabase.rest
                            .from('user_profiles')
                            .update({'gender': 'male'}).eq('user_id', userid!);
                      }
                      if (_selectedGender == Gender.female) {
                        await supabase.rest.from('user_profiles').update(
                            {'gender': 'female'}).eq('user_id', userid!);
                      }
                    }
                    if (_officehourscontroller.text.isNotEmpty) {
                      await supabase.rest.from('user_profiles').update({
                        'officehours': _officehourscontroller.text
                      }).eq('user_id', userid!);
                    }
                    if (_facultycontroller.text.isNotEmpty) {
                      await supabase.rest
                          .from('user_profiles')
                          .update({'faculty': _facultycontroller.text}).eq(
                              'user_id', userid!);
                    }
                  } catch (e) {
                    print('erroe $e');
                    Exceptionsnackbar(
                        context, "Error,please check with admins");
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
