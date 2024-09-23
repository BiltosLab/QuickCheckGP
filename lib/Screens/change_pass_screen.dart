/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quickcheck/components/Buttons.dart';
import 'package:quickcheck/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Change_Pass_Screen extends StatelessWidget {
  Change_Pass_Screen({super.key});
  final _changepasswordtx = TextEditingController();
  final _changepasswordtxconfirm = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 39, 70),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 36, 39, 70),
        /*title: Text("Change Password"),
        centerTitle: true,*/
        leading: const Back_Button(),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Center(
                child: Text(
                  "Create New Password",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: const Color.fromARGB(255, 80, 64, 153),
                          width: 3),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: TextField(
                        obscureText: true,
                        controller: _changepasswordtx,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Password',
                        )),
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: const Color.fromARGB(255, 80, 64, 153),
                          width: 3),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: TextField(
                        obscureText: true,
                        controller: _changepasswordtxconfirm,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Confirm Password',
                        )),
                  )),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: const ButtonStyle(
                      fixedSize: MaterialStatePropertyAll(Size(360, 45)),
                      backgroundColor: MaterialStatePropertyAll(
                          Color.fromARGB(255, 64, 66, 115))),
                  onPressed: () async {
                    if (_changepasswordtx.text ==
                        _changepasswordtxconfirm.text) {
                      if (_changepasswordtx.text.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text("Password is too short"),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ));
                        return;
                      }
                      try {
                        final UserResponse res = await supabase.auth.updateUser(
                          UserAttributes(
                            password: _changepasswordtx.text,
                          ),
                        );
                        final UserResponse updatedUser = res;
                        if (kDebugMode) {
                          print("USER PRINT$updatedUser");
                        }
                        /*if (res.user. != null){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Success! ,You can log in with your new password now"),
                            backgroundColor:
                                Theme.of(context).highlightColor,
                          ));
                      } */
                      } catch (e) {
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
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                      return;
                    }
                  },
                  child: const Text(
                    "Change Password",
                    style: TextStyle(
                        color: Color.fromARGB(255, 241, 246, 249)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
