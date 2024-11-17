import 'package:flutter/material.dart';
import 'src/rust/api/simple.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  String? selectedSemester;
  List<Grade> grades = [];

  void fetch_grades(String semester) async {
    try {
      List<Grade> fetchedGrades = fetchGrades(semester: semester, studentId: 1);
      setState(() {
        grades = fetchedGrades;
      });
      //print(grades);
    } catch (e) {
      //print('Error fetching grades: $e');
    }
  }

  double calculateTotalGPA(List<Grade> grades) {
    double totalGPA = 0.0;
    for (var grade in grades) {
      totalGPA += (grade.score / 100) * grade.gpa;
    }
    return totalGPA;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的成绩'),
        backgroundColor: Colors.blue[200],
      ),
      body: Container(
        color: Colors.blue[50],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SemesterSelector(),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    if (selectedSemester != null) {
                      fetch_grades(selectedSemester!);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // 背景颜色
                    foregroundColor: Colors.white, // 文字颜色
                  ),
                  child: const Text("查询"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 1,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: DataTable(
                      dataRowColor: WidgetStateProperty.all(Colors.white),
                      columnSpacing: 16,
                      //dataRowMinHeight: 50,
                      columns: const [
                        DataColumn(label: Text('学期')),
                        DataColumn(label: Text('课程ID')),
                        DataColumn(label: Text('课程名称')),
                        DataColumn(label: Text('成绩')),
                        DataColumn(label: Text('绩点')),
                      ],
                      rows: grades.isEmpty
                          ? [
                              const DataRow(cells: [
                                DataCell(Text('暂无数据')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                              ]),
                            ]
                          : grades.map((grade) {
                              return DataRow(cells: [
                                DataCell(Text(grade.semester)),
                                DataCell(Text(grade.courseId.toString())),
                                DataCell(Text(grade.courseName)),
                                DataCell(Text(grade.score.toStringAsFixed(2))),
                                DataCell(Text(grade.gpa.toStringAsFixed(2))),
                              ]);
                            }).toList(),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 1,
                    child: Card(
                      color: Colors.grey[100],
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '总绩点:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              calculateTotalGPA(grades).toStringAsFixed(2),
                              style: const TextStyle(
                                  fontSize: 24, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SemesterSelector extends StatefulWidget {
  const SemesterSelector({super.key});

  @override
  _SemesterSelectorState createState() => _SemesterSelectorState();
}

class _SemesterSelectorState extends State<SemesterSelector> {
  // 定义学期的数据源
  List<String> semesters = [
    'All',
    'Spring 2023',
    'Summer 2023',
    'Fall 2023',
    'Winter 2023'
  ];

  // 保存选中的学期
  String? selectedSemester;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white, // 背景颜色
        borderRadius: BorderRadius.circular(10), // 圆角半径
        border: Border.all(color: Colors.grey, width: 1), // 边框
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: DropdownButton<String>(
        value: selectedSemester,
        hint: const Text('请选择学期'), // 当没有选择时显示的提示信息
        items: semesters.map((String semester) {
          return DropdownMenuItem<String>(
            value: semester,
            child: Text(semester),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedSemester = newValue; // 更新选中的学期
            // 通知父组件更新学期
            final parent =
                context.findAncestorStateOfType<_FavoritesPageState>()
                    as _FavoritesPageState;
            parent.setState(() {
              parent.selectedSemester = newValue;
            });
          });
        },
        underline: Container(), // 隐藏下划线
        isExpanded: true,
      ),
    );
  }
}
