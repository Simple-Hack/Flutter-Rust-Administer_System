import 'package:flutter/material.dart';
import 'src/rust/api/select_class.dart';

class ChooseClassPage extends StatefulWidget {
  const ChooseClassPage({super.key});

  @override
  State<ChooseClassPage> createState() => _ChooseClassStatePage();
}

class _ChooseClassStatePage extends State<ChooseClassPage> {
  late Database _database;
  List<Course> _courses = [];
  List<int> _selectedCourseIds = [];
  int _showCoursesMode = 0; // 0: 未选课程, 1: 已选课程, 2: 所有课程

  // 定义不可选和不可退选的课程ID列表
  final List<int> _unselectableCourseIds = [3]; // 课程ID为3的课程不能选
  final List<int> _unenrollableCourseIds = [4]; // 课程ID为4的课程不能退

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      _database = await Database.newInstance(dbPath: 'aniya.db');
      await _fetchCourses(semester: '2023-2024秋季');
      await _fetchSelectedCourses(semester: '2023-2024秋季');
      setState(() {});
    } catch (e) {
      //print('Error initializing database: $e');
    }
  }

  Future<void> _fetchCourses({required String semester}) async {
    try {
      _courses = await _database.execQueryCoursesBySemester(semester: semester);
      setState(() {});
    } catch (e) {
      //print('Error fetching courses: $e');
    }
  }

  Future<void> _fetchSelectedCourses({required String semester}) async {
    try {
      final enrollments = await _database.queryEnrollmentsByStudentAndSemester(
          studentId: 1, semester: semester);
      _selectedCourseIds = enrollments
          .where((enrollment) => enrollment.status == '已选')
          .map((enrollment) => enrollment.courseId)
          .toList();
      setState(() {});
    } catch (e) {
      //print('Error fetching selected courses: $e');
    }
  }

  Future<void> _enrollStudent(int courseId) async {
    try {
      if (_isCourseSelectable(courseId)) {
        await _database.execEnrollStudent(
            studentId: 1, courseId: courseId, semester: '2023-2024秋季');
        _selectedCourseIds.add(courseId);
        setState(() {});
        //print('Student enrolled successfully');
      } else {
        //print('This course cannot be selected.');
      }
    } catch (e) {
      //print('Error enrolling student: $e');
    }
  }

  Future<void> _unenrollStudent(int courseId) async {
    try {
      if (_isCourseUnselectable(courseId)) {
        await _database.execUnenrollStudent(
            studentId: 1, courseId: courseId, semester: '2023-2024秋季');
        _selectedCourseIds.remove(courseId);
        setState(() {});
        //print('Student unenrolled successfully');
      } else {
        //print('This course cannot be unselected.');
      }
    } catch (e) {
      //print('Error unenrolling student: $e');
    }
  }

  bool _isCourseSelectable(int courseId) {
    // 检查课程ID是否在不可选列表中
    return !_unselectableCourseIds.contains(courseId);
  }

  bool _isCourseUnselectable(int courseId) {
    // 检查课程ID是否在不可退选列表中
    return !_unenrollableCourseIds.contains(courseId);
  }

  List<Course> _filterCourses() {
    switch (_showCoursesMode) {
      case 0:
        return _courses
            .where((course) => !_selectedCourseIds.contains(course.courseId))
            .toList();
      case 1:
        return _courses
            .where((course) => _selectedCourseIds.contains(course.courseId))
            .toList();
      default:
        return _courses;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('选择课程'),
        backgroundColor: Colors.blue[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Radio<int>(
                  activeColor: Colors.blue,
                  value: 0,
                  groupValue: _showCoursesMode,
                  onChanged: (value) {
                    setState(() {
                      _showCoursesMode = value!;
                    });
                  },
                ),
                const Text('未选课程'),
                Radio<int>(
                  activeColor: Colors.blue,
                  value: 1,
                  groupValue: _showCoursesMode,
                  onChanged: (value) {
                    setState(() {
                      _showCoursesMode = value!;
                    });
                  },
                ),
                const Text('已选课程'),
                Radio<int>(
                  activeColor: Colors.blue,
                  value: 2,
                  groupValue: _showCoursesMode,
                  onChanged: (value) {
                    setState(() {
                      _showCoursesMode = value!;
                    });
                  },
                ),
                const Text('所有课程'),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filterCourses().length,
                itemBuilder: (context, index) {
                  final course = _filterCourses()[index];
                  final isSelected =
                      _selectedCourseIds.contains(course.courseId);

                  return Container(
                    color: Colors.white,
                    child: ListTile(
                      iconColor: Colors.white,
                      focusColor: Colors.white,
                      //textColor: Colors.white,
                      title: Text(course.courseName),
                      subtitle: Text(
                        '教师: ${course.teacherId}, 教室: ${course.classroom}, 时间: ${course.timeSlot}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isSelected &&
                              _isCourseSelectable(course.courseId))
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[100],
                              ),
                              onPressed: () => _enrollStudent(course.courseId),
                              child: const Text('选课'),
                            ),
                          if (!isSelected &&
                              !_isCourseSelectable(course.courseId))
                            Card(
                              color: Colors.red.shade100,
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  '不可选',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 16),
                                ),
                              ),
                            ),
                          if (isSelected &&
                              _isCourseUnselectable(course.courseId))
                            ElevatedButton(
                              onPressed: () =>
                                  _unenrollStudent(course.courseId),
                              child: const Text('退课'),
                            ),
                          if (isSelected &&
                              !_isCourseUnselectable(course.courseId))
                            Card(
                              color: Colors.red.shade100,
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  '不可退选',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 16),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
