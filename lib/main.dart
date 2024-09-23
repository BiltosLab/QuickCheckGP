/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickcheck/Screens/change_pass_screen.dart';
import 'package:quickcheck/Screens/main_screen.dart';
import 'package:quickcheck/Screens/settings_screen.dart';
import 'package:quickcheck/Screens/Signup_Screen_Student.dart';
import 'package:quickcheck/Screens/student_attendance.dart';
import 'package:quickcheck/Screens/train_faces_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quickcheck/Screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final Map<String, Widget Function(BuildContext)> routes = {
  '/': (context) => const LoginScreen(),
  '/settings': (context) => const Settings_Screen(),
  '/main': (context) => MainScreen(),
  '/signup': (context) => const StudentSignUpScreen(),
  '/changepasswd': (context) => Change_Pass_Screen(),
  '/stdatt': (context) => const StudentAttendanceScreen(),
  '/attendedcal': (context) => const attendance_cal(
        dataRows: [],
      ),
  '/retrain': (context) => const FacialRetrainScreen()
};

List<CameraDescription> cameras = [];
String? ipaddress = '';
int selectcamera = 0;
Future<void> main() async {
  await dotenv.load(fileName: ".env");
  String? surl = dotenv.env['SUPABASEURL'];
  String? sanonkey = dotenv.env['SUPABASEANONKEY'];
  ipaddress = dotenv.env['IPADDRESS'];
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  cameras = await availableCameras();
  await Supabase.initialize(
    url: '$surl',
    anonKey: '$sanonkey'

  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
  runApp(MaterialApp(
    theme: ThemeData(
      fontFamily: 'Poppins',
    ),
    navigatorKey: navigatorKey,
    navigatorObservers: [NavigatorObserver()],
    routes: routes,
    initialRoute: '/',
    debugShowCheckedModeBanner: false,
  ));});
    FlutterNativeSplash.remove();
}

int currentloggedinusertype = 9;
final supabase = Supabase.instance.client;

Future<String> getfullname(String userId) async {
  String fullName = '';
  final response = await supabase.rest
      .from('user_profiles')
      .select('first_name,last_name')
      .filter('user_id', 'eq', userId);

  final data = response as List<Map<String, dynamic>>;
  for (var item in data) {
    final firstName = item['first_name'] as String;
    final lastName = item['last_name'] as String;
    fullName = firstName + ' ' + lastName;
  }
  print("DATA OF USER : $data");
  print("fullName OF USER : $fullName");
  return fullName;
}
