/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */
 
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quickcheck/Screens/Signup_Screen_LecAndSecurity.dart';
import 'package:quickcheck/main.dart';
import 'package:quickcheck/Screens/main_screen.dart';
import 'package:quickcheck/Screens/settings_screen.dart';
import 'package:quickcheck/Screens/Signup_Screen_Student.dart';
import 'package:quickcheck/Screens/student_attendance.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  Future<int> getUserType() async {
    int userType = 0;
    final user = supabase.auth.currentUser?.id;
    final userProfiles = supabase.from('user_profiles');
    final snapshot = await userProfiles.select().eq('user_id', user!);

    if (snapshot.isEmpty) {
      print('Error fetching user profile: ${snapshot}');
    } else {
      final data = snapshot as List;
      userType = data[0]['user_type_id'];
      print("USERTYPE IN snapshot $snapshot");
      print("USERTYPE IN DATA $data");
      print("USERTYPE IN userType $userType");
    }

    return userType;
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Choose Your Role'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'Select the role that best describes your intended use of the platform.'),
                  Text(''),
                  Text(
                      'This will customize your registration process and available features.'),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              TextButton(
                child: const Text('Lecturer'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LecturerSignUpScreen(
                          security: false,
                        ),
                      ));
                },
              ),
              TextButton(
                child: const Text('Security'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LecturerSignUpScreen(
                          security: true,
                        ),
                      ));
                },
              ),
              TextButton(
                child: const Text('Student'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentSignUpScreen(),
                      ));
                },
              )
            ],
          );
        });
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final holder = data.session?.user.id;
      if (event== AuthChangeEvent.signedIn && supabase.auth.currentSession!.expiresIn!.toInt() <= 0){
        await supabase.auth.signOut(scope: SignOutScope.local);
      }
      else if (event == AuthChangeEvent.signedIn ||
          (supabase.auth.currentUser?.aud == "authenticated")) {
            print("User session expires in : ${supabase.auth.currentSession!.expiresIn}");
        final typeofuser = await getUserType();

        if (kDebugMode) {
          print("TYPE OF USER LOGGED IN ? : $typeofuser");
        } // DEBUGGING
        currentloggedinusertype = typeofuser;
        navigatorKey.currentState?.pushReplacementNamed('/main',
            arguments:
                holder); // IMPLEMENT ARGS DATA HERE TO MAKE A NEW INSTANCE INCASE OF SIGN OUT AND SIGN IN AGAIN IN THE SAME SESSION.
        //await Future.delayed(Duration(milliseconds: 200)); // Short delay
      } 
    });
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 36, 39, 70),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.17)),
                Center(
                  child: SvgPicture.asset(
                    'assets/icons/QuickCheckIcon.svg',
                    width: MediaQuery.of(context).size.height * 0.279017,
                    height: MediaQuery.of(context).size.height * 0.128429,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.015)),
                const Text(
                  "QuickCheck",
                  style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(
                            color: Color.fromARGB(255, 180, 180, 180)),
                        border: OutlineInputBorder(),
                        hintText: 'Username',
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(
                            color: Color.fromARGB(255, 180, 180, 180)),
                        border: OutlineInputBorder(),
                        hintText: 'Password',
                      )),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                ElevatedButton(
                  style: ButtonStyle(
                      elevation: const MaterialStatePropertyAll(5),
                      fixedSize: MaterialStatePropertyAll(
                          Size(MediaQuery.of(context).size.width * 0.90, 45)),
                      backgroundColor: const MaterialStatePropertyAll(
                          Color.fromARGB(255, 64, 66, 115))),
                  onPressed: () async {
                    try {
                      /*String username = _usernameController.text;
                      String password = _passwordController.text;*/
                      final AuthResponse res =
                          await supabase.auth.signInWithPassword(
                        email: _usernameController.text,
                        password: _passwordController.text,
                      );
                      if (res.session != Null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text("Success !!!!!!!!!!!"),
                          backgroundColor: Theme.of(context).highlightColor,
                        ));
                      }
                    } on AuthException {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Wrong password/username"),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Error Please try again later."),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Log In",
                    style: TextStyle(color: Color.fromARGB(255, 241, 246, 249)),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ButtonStyle(
                      elevation: const MaterialStatePropertyAll(5),
                      fixedSize: MaterialStatePropertyAll(
                          Size(MediaQuery.of(context).size.width * 0.90, 45)),
                      backgroundColor: const MaterialStatePropertyAll(
                          Color.fromARGB(255, 64, 66, 115))),
                  onPressed: () async {
                    _showMyDialog(context);
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: Color.fromARGB(255, 241, 246, 249)),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 15)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        //TODO add redirect link here?
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
