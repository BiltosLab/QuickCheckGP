/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */
 
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quickcheck/Screens/EditProfileScreenLecturer.dart';
import 'package:quickcheck/Screens/EditProfileScreenSecurity.dart';
import 'package:quickcheck/Screens/EditProfileScreenStudent.dart';
import 'package:quickcheck/components/Buttons.dart';
import 'package:quickcheck/main.dart';
import 'package:quickcheck/Screens/change_pass_screen.dart';
import 'package:quickcheck/utils/GlobalFunctions.dart';

class Settings_Screen extends StatefulWidget {
  const Settings_Screen({super.key});

  @override
  State<Settings_Screen> createState() => _Settings_ScreenState();
}

class _Settings_ScreenState extends State<Settings_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 39, 70),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 51, 54, 97),
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: const Back_Button(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: const Color.fromARGB(
                255, 74, 76, 133),
            height: 1.0,
          ),
        ),
      ),
      body: Container(
          child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            currentloggedinusertype == 1
                ? retrainfacerecbutton()
                : const SizedBox(
                    width: 0,
                    height: 0,
                  ),
            
            if(currentloggedinusertype == 1)
            EditProfileButtonStudent()
            else if(currentloggedinusertype ==  2)
            EditProfileButtonLecturer()
            else if(currentloggedinusertype == 3)
            EditProfileButtonSecurity()
            ,
            SignOutButton(),
            Aboutus(),
          ],
        ),
      )),
    );
  }
}

class Change_Passbutton extends StatelessWidget {
  const Change_Passbutton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: GestureDetector(
        onTap: () {
          //Navigator.pushNamed(context, '/changepasswd');
          navigatorKey.currentState?.pushNamed('/changepasswd');
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 136, 90, 222)),
          height: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Change Password",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
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

class retrainfacerecbutton extends StatelessWidget {
  retrainfacerecbutton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
      child: GestureDetector(
        onTap: () {
          //Navigator.pushNamed(context, '/changepasswd');
          navigatorKey.currentState?.pushNamed('/retrain');
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 136, 90, 222)),
          height: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Retrain Face Model",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
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

class Aboutus extends StatelessWidget {
  Aboutus({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Aboutpage(),
              ));
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 136, 90, 222)),
          height: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "About us",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
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

class Aboutpage extends StatelessWidget {
  const Aboutpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 39, 70),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 36, 39, 70),
        leading: const Back_Button(),
        title: const Text(
          "About us",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "App version 0.9.9 RC1",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            Row(
              children: [
                Text("Developed by Laith Shishani",
                    style: TextStyle(color: Colors.white)),
              ],
            ),
            Row(
              children: [
                Text("Documentation by Ossama Safi",
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SignOutButton extends StatelessWidget {
  SignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
      child: GestureDetector(
        onTap: () async {
          await signoutcurrentsession(context);
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 136, 90, 222)),
          height: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Sign Out",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
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

class EditProfileButtonSecurity extends StatelessWidget {
  EditProfileButtonSecurity({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreenSecurity(),
              ));
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 136, 90, 222)),
          height: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Edit Profile",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
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


class EditProfileButtonStudent extends StatelessWidget {
  EditProfileButtonStudent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreenStudent(),
              ));
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 136, 90, 222)),
          height: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Edit Profile",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
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


class EditProfileButtonLecturer extends StatelessWidget {
  EditProfileButtonLecturer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreenLecturer(),
              ));
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 136, 90, 222)),
          height: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Edit Profile",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
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
