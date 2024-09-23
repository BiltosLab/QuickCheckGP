/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */
 
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quickcheck/Screens/Lecturers_Screen.dart';
import 'package:quickcheck/Screens/Students_Info_Screen.dart';
import 'package:quickcheck/components/Buttons.dart';
import 'package:quickcheck/main.dart';
import 'package:quickcheck/utils/GlobalFunctions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum GradeType {
  Assessment('assessments'),
  mid_mark('mid_marks'),
  final_mark('final_marks');

  const GradeType(this.name);
  final String name;
}

class MarksTableScreen extends StatefulWidget {
  final studentId;

  MarksTableScreen({super.key, required this.studentId});

  @override
  State<MarksTableScreen> createState() => _MarksTableScreenState();
}

class _MarksTableScreenState extends State<MarksTableScreen> {
  List<DataRow> DataRows = [
    const DataRow(cells: [
      DataCell(Text("No Data")),
      DataCell(Text("0")),
      DataCell(Text("0")),
      DataCell(Text("0")),
    ])
  ];
  //List<DataRow> defaultmarktable =
  @override
  void initState() {
    fetchdata().whenComplete(() => null);
    super.initState();
  }

  Future<void> fetchdata() async {
    try {
      final datar = await _fetchdata();
      if (mounted) {
        setState(() {
          //DataRows = datar.isNotEmpty ? datar : defaultmarktable;
          DataRows = datar;
        });
      }
    } catch (e) {
      Exceptionsnackbar(context,"Error fetching data");
    }
  }

  Future<List<DataRow>> _fetchdata() async {
    var DataRows;
    var attres;
    try {
   attres = await supabase.rest
      .from("enrollments")
      .select("class_id")
      .filter('student_id', 'eq', '${widget.studentId}');
} on Exception catch (e) {
       Exceptionsnackbar(context,"Error fetching data");

}
    final enrolledClassIds =
        attres.map((row) => row['class_id'] as int).toList();
    if (enrolledClassIds.isNotEmpty) {
      try {
        final stData = await supabase.rest
            .from('enrollments')
            .select('class_id,mid_marks,final_marks,assessments')
            .filter('class_id', 'in', enrolledClassIds)
            .filter('student_id', 'eq', widget.studentId);
        List<Map<String, dynamic>> updatedStudentData =
            List<Map<String, dynamic>>.from(stData);

        for (var data in updatedStudentData) {
          data['classname'] =
              await getClassNamefromID(data['class_id'].toString());
        }

        DataRows = updatedStudentData
            .map((data) => DataRow(
                  cells: [
                    DataCell(Text(data['classname'].toString())),
                    DataCell(Text(data['assessments'].toString())),
                    DataCell(Text(data['mid_marks'].toString())),
                    DataCell(Text(data['final_marks'].toString())),
                  ],
                ))
            .toList();
      } catch (e) {
      Exceptionsnackbar(context,"Error fetching data");

      }
    }
    return DataRows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 51, 54, 97),
        title: const Text(
          "Grades",
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        ),
        leading: const Back_Button(),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: const Color.fromARGB(
                255, 74, 76, 133),
            height: 1.0,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 36, 39, 70),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              const Row(
                children: [],
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DataTable(
                  columnSpacing: 30.0,
                  horizontalMargin: 25.0,
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
                      style: TextStyle(fontSize: 12),
                    )),
                    const DataColumn(
                        label: Text(
                      'Assessment',
                      style: TextStyle(fontSize: 12),
                    )),
                    const DataColumn(
                        label: Text(
                      'Mid',
                      style: TextStyle(fontSize: 12),
                    )),
                    const DataColumn(
                        label: Text(
                      'Final',
                      style: TextStyle(fontSize: 12),
                    )),
                  ],
                  rows: DataRows,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class StudentSelectionScreen extends StatefulWidget {
  final List<Map<String, dynamic>> enrolledStudents;
  final String ClassID;

  const StudentSelectionScreen(
      {super.key, required this.ClassID, required this.enrolledStudents});

  @override
  State<StudentSelectionScreen> createState() => _StudentSelectionScreenState();
}

class _StudentSelectionScreenState extends State<StudentSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 36, 39, 70),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 51, 54, 97),
          leading: const Back_Button(),
          title: const Text(
            "Select Student",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: const Color.fromARGB(
                  255, 74, 76, 133),
              height: 1.0,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: ListView.builder(
            itemCount: widget.enrolledStudents.length,
            itemBuilder: (context, index) {
              final studentsdata = widget.enrolledStudents[index];
              return StudentlilWidget(
                student_name: studentsdata['name'],
                student_id: studentsdata['student_id'],
                class_id: widget.ClassID,
                marks: true,
              );
            },
          ),
        ));
  }
}

class StudentlilWidget extends StatelessWidget {
  final student_name;
  final student_id;
  final class_id;
  final bool marks;
  const StudentlilWidget(
      {super.key,
      required this.student_name,
      required this.student_id,
      required this.class_id,
      required this.marks});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => marks
                      ? GradesEditScreen(
                          classid: class_id,
                          studentId: student_id,
                        )
                      : StudentsInfoScreen(
                          ClassID: class_id, StudentID: student_id,permit: false,)));
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: 45,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 64, 66, 115),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${student_name}",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500),
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

class GradesEditScreen extends StatefulWidget {
  final studentId;
  final classid;
  const GradesEditScreen(
      {super.key, required this.studentId, required this.classid});

  @override
  State<GradesEditScreen> createState() => _GradesEditScreenState();
}

class _GradesEditScreenState extends State<GradesEditScreen> {
  final grade_controller = TextEditingController();
  GradeType? _selectedGrade;
  List<DataRow> DataRows = [
    const DataRow(cells: [
      DataCell(Text("No Data")),
      DataCell(Text("0")),
      DataCell(Text("0")),
      DataCell(Text("0")),
    ])
  ];

  @override
  void initState() {
    fetchdata().whenComplete(() => null);
    super.initState();
  }

  Future<void> fetchdata() async {
    final datar = await _fetchdata();
    if (mounted) {
      setState(() {
        //DataRows = datar.isNotEmpty ? datar : defaultmarktable;
        DataRows = datar;
      });
    }
  }

  Future<List<DataRow>> _fetchdata() async {
    var DataRows;
    try {
      final stData = await supabase.rest
          .from('enrollments')
          .select('class_id,mid_marks,final_marks,assessments')
          .filter('class_id', 'eq', widget.classid)
          .filter('student_id', 'eq', widget.studentId);

      List<Map<String, dynamic>> updatedStudentData =
          List<Map<String, dynamic>>.from(stData);

      for (var data in updatedStudentData) {
        data['classname'] =
            await getClassNamefromID(data['class_id'].toString());
      }

      DataRows = updatedStudentData
          .map((data) => DataRow(
                cells: [
                  DataCell(Text(data['classname'].toString())),
                  DataCell(Text(data['assessments'].toString())),
                  DataCell(Text(data['mid_marks'].toString())),
                  DataCell(Text(data['final_marks'].toString())),
                ],
              ))
          .toList();
    } catch (e) {
            Exceptionsnackbar(context,"Error fetching data");

    }
    return DataRows;
  }

  Future<void> updateGrade(String gradetype, String grade) async {
    try {
      await supabase
          .from('enrollments')
          .update({gradetype: grade})
          .eq('class_id', widget.classid.toString())
          .eq('student_id', widget.studentId.toString());
    } on PostgrestException {
      print("Postgrest Exception");
      Exceptionsnackbar(context,"Error fetching data");

    }
    catch(e){
            Exceptionsnackbar(context,"Error fetching data");

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 39, 70),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 51, 54, 97),
        leading: const Back_Button(),
        title: const Text(
          "Grades",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: const Color.fromARGB(
                255, 74, 76, 133),
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DataTable(
              columnSpacing: 30.0,
              horizontalMargin: 25.0,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    color: const Color.fromARGB(255, 80, 64, 153), width: 3),
                borderRadius: BorderRadius.circular(15.0),
              ),
              columns: [
                const DataColumn(
                    label: Text(
                  'Course',
                  style: TextStyle(fontSize: 12),
                )),
                const DataColumn(
                    label: Text(
                  'Assessment',
                  style: TextStyle(fontSize: 12),
                )),
                const DataColumn(
                    label: Text(
                  'Mid',
                  style: TextStyle(fontSize: 12),
                )),
                const DataColumn(
                    label: Text(
                  'Final',
                  style: TextStyle(fontSize: 12),
                )),
              ],
              rows: DataRows,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                    child: DropdownButton<GradeType>(
                      hint: const Text(
                        "Select Grade",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      dropdownColor: const Color.fromARGB(255, 80, 64, 153),
                      value: _selectedGrade,
                      onChanged: (GradeType? newValue) {
                        if (mounted) {
                          setState(() {
                            _selectedGrade = newValue;
                          });
                        }
                      },
                      items: getDropdownMenuItems(),
                      iconEnabledColor: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: const Color.fromARGB(255, 80, 64, 153),
                        width: 4),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: TextField(
                      controller: grade_controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10.0)
                        ),
                        hintText: 'Grade',
                      )),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () async {

              int currentgrade = 0;
              try {
                currentgrade = int.parse(grade_controller.text);
              } on FormatException {
                const SnackBar(
                  content: Text("Enter a number"),
                  backgroundColor: Color.fromARGB(255, 109, 41, 41),
                );
              }
              if (_selectedGrade != null && grade_controller.text.isNotEmpty) {
                if (_selectedGrade == GradeType.final_mark &&
                    currentgrade >= 0 &&
                    currentgrade <= 40) {
                  await updateGrade('final_marks', grade_controller.text);
                } else if (_selectedGrade == GradeType.final_mark &&
                        (currentgrade < 0 ||
                    currentgrade > 40)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: const Duration(milliseconds: 800),
                    content: const Text("Incorrect input"),
                    backgroundColor: Theme.of(context).primaryColorDark,
                  ));
                }
                if (_selectedGrade == GradeType.mid_mark &&
                    currentgrade >= 0 &&
                    currentgrade <= 30) {
                  await updateGrade('mid_marks', grade_controller.text);
                } else if (_selectedGrade == GradeType.mid_mark &&
                        (currentgrade < 0 ||
                    currentgrade > 30)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: const Duration(milliseconds: 800),
                    content: const Text("Incorrect input"),
                    backgroundColor: Theme.of(context).primaryColorDark,
                  ));
                }
                if (_selectedGrade == GradeType.Assessment &&
                    currentgrade >= 0 &&
                    currentgrade <= 30) {
                  await updateGrade('assessments', grade_controller.text);
                } else if (_selectedGrade == GradeType.Assessment &&
                        (currentgrade < 0 ||
                    currentgrade > 30)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: const Duration(milliseconds: 800),
                    content: const Text("Incorrect input"),
                    backgroundColor: Theme.of(context).primaryColorDark,
                  ));
                }
              } else if (_selectedGrade == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(milliseconds: 800),
                  content: const Text("Select grade first"),
                  backgroundColor: Theme.of(context).primaryColorDark,
                ));
              } else if (grade_controller.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(milliseconds: 800),
                  content: const Text("Enter a Grade"),
                  backgroundColor: Theme.of(context).primaryColorDark,
                ));
              }
              final datar = await _fetchdata();

              if (mounted) {
                setState(() {
                  DataRows = datar;
                });
              }
            },
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 80, 64, 153),
                    Color.fromARGB(255, 80, 64, 153)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Change Grade",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<DropdownMenuItem<GradeType>> getDropdownMenuItems() {
    List<DropdownMenuItem<GradeType>> items = [];
    for (GradeType type in GradeType.values) {
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
