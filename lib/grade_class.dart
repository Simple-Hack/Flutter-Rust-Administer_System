class Grade {
  final int courseId;
  final String courseName;
  final double score;
  final double gpa;
  final String semester;

  Grade({
    required this.courseId,
    required this.courseName,
    required this.score,
    required this.gpa,
    required this.semester,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      courseId: json['course_id'],
      courseName: json['course_name'],
      score: json['score'].toDouble(),
      gpa: json['gpa'].toDouble(),
      semester: json['semester'],
    );
  }
}
