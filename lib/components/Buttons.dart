/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:quickcheck/main.dart';
import 'package:quickcheck/utils/GlobalFunctions.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Settingsbutton extends StatelessWidget {
  const Settingsbutton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 30,
        alignment: Alignment.center,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 136, 90, 222),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/settingsbuttonnew.svg',
              width: 30,
              height: 30,
                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),

            ),
            const Expanded(
              child: Center(
                child: Text(
                  "Settings",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16,color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
      onTap: () {
        navigatorKey.currentState?.pushNamed('/settings');
      },
    );
  }
}

class Sendbutton extends StatelessWidget {
  const Sendbutton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: const ButtonStyle(
          fixedSize: MaterialStatePropertyAll(Size(75, 75)),
          backgroundColor:
              MaterialStatePropertyAll(Color.fromARGB(255, 27, 27, 27))),
      onPressed: () {
        //Navigator.pushReplacementNamed(context, '/signup');
        navigatorKey.currentState?.pushReplacementNamed('/signup');
      },
      child: const Text(
        "Send",
        style: TextStyle(
            color: Color.fromARGB(255, 241, 246, 249), fontSize: 11),
      ),
    );
  }
}

/*class s extends StatelessWidget {
   SignOut({
    super.key,
  });
final Widget svg = SvgPicture.asset(
  'assets/backbutton.svg',
  semanticsLabel: 'Acme Logo'
);
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          fixedSize: MaterialStatePropertyAll(Size(90, 50)),
          backgroundColor:
              MaterialStatePropertyAll(Color.fromARGB(255, 57, 72, 103))),
      onPressed: () async {
        await supabase.auth.signOut(scope: SignOutScope.global);
        print("Signed Out Successfully");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Signed out successfully"),
          backgroundColor: Colors.amber,
        ));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Loginpage()));
      },
      child: SvgPicture.asset('assets/icons/signoutbutton.svg'),
    );
  }
}*/

class SignOut extends StatelessWidget {
  SignOut({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await signoutcurrentsession(context);
      },
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 136, 90, 222),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
                padding: EdgeInsets.only(
                    left:
                        5)), // because settings icon has 30x30 and this one has to be 25x25 so we add 5 to make it even
            SvgPicture.asset(
              'assets/icons/signoutbutton.svg',
              width: 25,
              height: 25,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  "Sign Out",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16,color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}

class Back_Button extends StatelessWidget {
  const Back_Button({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(0, 36, 39, 70),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SvgPicture.asset(
            'assets/icons/backbutton.svg',
            width: 25,
            height: 25,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        onTap: () {
          //Navigator.maybePop(context);
          navigatorKey.currentState?.maybePop();
        });
  }
}

class mp4sendertest extends StatelessWidget {
  const mp4sendertest({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xffF7F8F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SvgPicture.asset(
        'assets/icons/sendbutton.svg',
        width: 25,
        height: 25,
      ),
    );
  }
}

class Attendancetakebutton extends StatelessWidget {
  const Attendancetakebutton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SvgPicture.asset(
        'assets/icons/donebutton.svg',
        width: 35,
        height: 35,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}

class MessagesAddButton extends StatelessWidget {
  const MessagesAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SvgPicture.asset(
        'assets/icons/plus.svg',
        width: 25,
        height: 25,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}
