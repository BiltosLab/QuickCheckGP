/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */
 
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quickcheck/Screens/settings_screen.dart';
import 'package:quickcheck/components/Buttons.dart';
import 'package:quickcheck/components/avatar.dart';
import 'package:quickcheck/main.dart';
import 'package:quickcheck/utils/GlobalFunctions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentProfileScreen extends StatefulWidget {

  StudentProfileScreen(
      {super.key,});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  late String fullname = '';
  late String major = '';
  late Map<String, dynamic> user_profiles = {};
  late Map<String, dynamic> studentdata = {};
  late List<dynamic> enrolledc = [];
  late String StudentID;
  late String imageUrl = '';
  bool isinitalizing = true;
  List<DataRow> dataRows = [];

  @override
  void initState() {
    super.initState();
    _getfullinfo().whenComplete(() => null);
  }

  Future<void> _getfullinfo() async {
    await getfullinfo();
  }

  Future<void> getfullinfo() async { 
    try {
      final userid = supabase.auth.currentUser?.id;
    final data = await supabase.rest
        .from('students')
        .select()
        .eq('user_id', '${userid}')
        .single();
    final cdata = <Map<String, dynamic>>[];
    final res = await supabase.rest
        .from('user_profiles')
        .select()
        .eq('user_id', userid!)
        .single();
    StudentID = data['student_id'].toString();
    final enr = await enrolledclassessrec(data['student_id'].toString());

    if (enr.isNotEmpty) {
      for (var classid in enr) {
        final cname = await getClassNamefromID(classid['class_id'].toString());
        final dbres = await supabase.rest
            .from('classes')
            .select(
                'classname,classtime,classlocation,classlecturer_profile_id')
            .eq('id', '${classid['class_id']}')
            .single();

        cdata.add({
          'classname': cname,
          'classtime': dbres['classtime'],
          'classlocation': dbres['classlocation'],
          'classlecturer_profile_id': dbres['classlecturer_profile_id'],
        });
      }
    }
    dataRows = cdata
        .map((data) => DataRow(
              cells: [
                DataCell(Text(
                  data['classname'],
                )),
                DataCell(Text(
                  data['classtime'].toString(),
                )),
                DataCell(Text(
                  data['classlocation'].toString(),
                ))
              ],
              onLongPress: () {
                print("data ${data.toString()}");
              },
            ))
        .toList();
    if (mounted) {
      setState(() {
        imageUrl = res['avatar_url'].toString();
        user_profiles = res;
        studentdata = data;
      });
    }
    if (res.isNotEmpty) {
      if (mounted) {
        setState(() {
          isinitalizing = false;
        });
      }
    }
    } catch (e) {
            Exceptionsnackbar(context,"Error fetching data");

    }
  }
  Future<void> _onUpload(String imageUrl) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('user_profiles').insert({'avatar_url':imageUrl}).eq('id', userId);
      if (mounted) {
        print("SNACKBAR");
        const SnackBar(
          content: Text('Updated your profile image!'),
        );
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        SnackBar(
          content: Text(error.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    } catch (error) {
      if (mounted) {
        SnackBar(
          content: const Text('Unexpected error occurred'),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    }
    if (!mounted) {
      return;
    }

    if (mounted) {
      setState(() {
      this.imageUrl = imageUrl;
    });
    }
  }


  @override
  Widget build(BuildContext context) {
    return isinitalizing
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 15, right: 15, left: 15, top: 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: MediaQuery.of(context).size.height * 0.20,
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10.0,
                                spreadRadius: 2.0,
                              ),
                            ],
                          ),
                          child: Avatar(imageUrl: imageUrl, onUpload: _onUpload)
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment
                                  .center,
                              children: [
                                Text(
                                  'Name: ${user_profiles['first_name']} ${user_profiles['last_name']}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                    height:
                                        5),
                                Text(
                                  'ID: ${StudentID}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                    height:
                                        5),
                                Text(
                                  'Major: ${studentdata['major']}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        "Courses",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: Divider(
                    color: Colors.grey[600],
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
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
                    rows: dataRows,
                  ),
                ),
              ],
          );
  }
}







class LecturerProfileScreen extends StatefulWidget {
  LecturerProfileScreen(
      {super.key,});

  @override
  State<LecturerProfileScreen> createState() => _LecturerProfileScreenState();
}

class _LecturerProfileScreenState extends State<LecturerProfileScreen> {
  late String fullname = '';
  late String major = '';
  late Map<String, dynamic> user_profiles = {};
  late Map<String, dynamic> studentdata = {};
  late List<dynamic> enrolledc = [];

  late String imageUrl = '';
  bool isinitalizing = true;
  List<DataRow> dataRows = [];

  @override
  void initState() {
    super.initState();
    _getfullinfo().whenComplete(() => null);
  }

  Future<void> _getfullinfo() async {
    await getfullinfo();
  }

  Future<void> getfullinfo() async {
    final userid=supabase.auth.currentUser?.id;
    final cdata = <Map<String, dynamic>>[];
    final data = await supabase.rest
        .from('user_profiles')
        .select()
        .eq('user_id', '${userid}')
        .single();
    final enr = await enrolledclassesforlec(data['id'].toString());

    if (enr.isNotEmpty) {
      for (var classid in enr) {
        final cname = await getClassNamefromID(classid['id'].toString());
        final dbres = await supabase.rest
            .from('classes')
            .select(
                'classname,classtime,classlocation,classlecturer_profile_id')
            .eq('id', '${classid['id']}')
            .single();

        cdata.add({
          'classname': cname,
          'classtime': dbres['classtime'],
          'classlocation': dbres['classlocation'],
          'classlecturer_profile_id': dbres['classlecturer_profile_id'],
        });
      }
    }
    dataRows = cdata
        .map((data) => DataRow(
              cells: [
                DataCell(Text(
                  data['classname'],
                )),
                DataCell(Text(
                  data['classtime'].toString(),
                )),
                DataCell(Text(
                  data['classlocation'].toString(),
                ))
              ],
              onLongPress: () {
                print("data ${data.toString()}");
              },
            ))
        .toList();
    if (mounted) {
      setState(() {
        imageUrl = data['avatar_url'].toString();
        user_profiles = data;
        studentdata = data;
      });
    }
    if (data.isNotEmpty) {
      if (mounted) {
        setState(() {
          isinitalizing = false;
        });
      }
    }
  }
  Future<void> _onUpload(String imageUrl) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('user_profiles').insert({'avatar_url':imageUrl}).eq('id', userId);
      if (mounted) {
        print("SNACKBAR");
        const SnackBar(
          content: Text('Updated your profile image!'),
        );
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        SnackBar(
          content: Text(error.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    } catch (error) {
      if (mounted) {
        SnackBar(
          content: const Text('Unexpected error occurred'),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    }
    if (!mounted) {
      return;
    }

    if (mounted) {
      setState(() {
      this.imageUrl = imageUrl;
    });
    }
  }
  @override
  Widget build(BuildContext context) {
    return isinitalizing
        ? const Center(
            child: CircularProgressIndicator(),
          )
        :  Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 15, right: 15, left: 15, top: 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: MediaQuery.of(context).size.height * 0.20,
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10.0,
                                spreadRadius: 2.0,
                              ),
                            ],
                          ),
                          child: Avatar(imageUrl: imageUrl, onUpload: _onUpload)
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment
                                  .center,
                              children: [
                                Text(
                                  'Name: ${user_profiles['first_name']} ${user_profiles['last_name']}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                    height:
                                        5),
                                Text(
                                  'Faculty: ${studentdata['faculty']}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                    height:
                                        5),
                                Text(
                                  'Office Hours: ${studentdata['officehours']}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        "Courses",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: Divider(
                    color: Colors.grey[600],
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DataTable(
                    columnSpacing: 30.0,
                  horizontalMargin: 20.0,
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
                    rows: dataRows,
                  ),
                ),
              ],
          );
  }
}



class SecurityProfileScreen extends StatefulWidget {
  SecurityProfileScreen(
      {super.key,});

  @override
  State<SecurityProfileScreen> createState() => _SecurityProfileScreenState();
}

class _SecurityProfileScreenState extends State<SecurityProfileScreen> {
  late String fullname = '';
  late String major = '';
  late Map<String, dynamic> user_profiles = {};
  late List<dynamic> enrolledc = [];

  late String imageUrl = '';
  bool isinitalizing = true;
  List<DataRow> dataRows = [];

  @override
  void initState() {
    super.initState();
    _getfullinfo().whenComplete(() => null);
  }

  Future<void> _getfullinfo() async {
    await getfullinfo();
  }

  Future<void> getfullinfo() async {
    final userid=supabase.auth.currentUser?.id;
    final cdata = <Map<String, dynamic>>[];
    final data = await supabase.rest
        .from('user_profiles')
        .select()
        .eq('user_id', '${userid}')
        .single();

    if (mounted) {
      setState(() {
        imageUrl = data['avatar_url'].toString();
        user_profiles = data;
      });
    }
    if (data.isNotEmpty) {
      if (mounted) {
        setState(() {
          isinitalizing = false;
        });
      }
    }
  }
  Future<void> _onUpload(String imageUrl) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      // await supabase.from('user_profiles').upsert({
      //   'id': userId,
      //   'avatar_url': imageUrl,
      // });
      await supabase.from('user_profiles').insert({'avatar_url':imageUrl}).eq('id', userId);
      if (mounted) {
        print("SNACKBAR");
        const SnackBar(
          content: Text('Updated your profile image!'),
        );
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        SnackBar(
          content: Text(error.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    } catch (error) {
      if (mounted) {
        SnackBar(
          content: const Text('Unexpected error occurred'),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    }
    if (!mounted) {
      return;
    }

    if (mounted) {
      setState(() {
      this.imageUrl = imageUrl;
    });
    }
  }
  @override
  Widget build(BuildContext context) {
    return isinitalizing
        ? const Center(
            child: CircularProgressIndicator(),
          )
        :  Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 15, right: 15, left: 15, top: 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: MediaQuery.of(context).size.height * 0.20,
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10.0,
                                spreadRadius: 2.0,
                              ),
                            ],
                          ),
                          child: Avatar(imageUrl: imageUrl, onUpload: _onUpload)
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25.0, vertical: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment
                                  .center,
                              children: [
                                Text(
                                  'Name: ${user_profiles['first_name']} ${user_profiles['last_name']}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    children: [Row(mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Settings",style: TextStyle(color: Colors.grey,fontSize: 10),),
                      ],
                    ),
                      Divider(thickness: 0.0,),
                    ],
                  ),
                ),
                Container(
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
              ],
          );
  }
}