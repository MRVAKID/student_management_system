class UserModel {
  final String username;
  final String passwordHash;
  final String role;
  final String displayName;
  String? securityQuestion;
  String? securityAnswer;

  UserModel({
    required this.username,
    required this.passwordHash,
    required this.role,
    required this.displayName,
    this.securityQuestion,
    this.securityAnswer,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'passwordHash': passwordHash,
      'role': role,
      'displayName': displayName,
      'securityQuestion': securityQuestion,
      'securityAnswer': securityAnswer,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] ?? '',
      passwordHash: map['passwordHash'] ?? '',
      role: map['role'] ?? '',
      displayName: map['displayName'] ?? '',
      securityQuestion: map['securityQuestion'],
      securityAnswer: map['securityAnswer'],
    );
  }
}

class StudentModel {
  final String rollNo;
  final String name;
  final String course;
  final String semester;
  final double gpa;
  final double attendance;
  final String scoresJson;
  final String assignmentsJson;

  StudentModel({
    required this.rollNo,
    required this.name,
    required this.course,
    required this.semester,
    required this.gpa,
    required this.attendance,
    required this.scoresJson,
    required this.assignmentsJson,
  });

  Map<String, dynamic> toMap() {
    return {
      'rollNo': rollNo,
      'name': name,
      'course': course,
      'semester': semester,
      'gpa': gpa,
      'attendance': attendance,
      'scoresJson': scoresJson,
      'assignmentsJson': assignmentsJson,
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      rollNo: map['rollNo'] ?? '',
      name: map['name'] ?? '',
      course: map['course'] ?? '',
      semester: map['semester'] ?? '',
      gpa: (map['gpa'] as num?)?.toDouble() ?? 0.0,
      attendance: (map['attendance'] as num?)?.toDouble() ?? 0.0,
      scoresJson: map['scoresJson'] ?? '',
      assignmentsJson: map['assignmentsJson'] ?? '',
    );
  }
}

class TeacherModel {
  final String teacherId;
  final String name;
  final String subject;
  final String contact;

  TeacherModel({
    required this.teacherId,
    required this.name,
    required this.subject,
    required this.contact,
  });

  Map<String, dynamic> toMap() {
    return {
      'teacherId': teacherId,
      'name': name,
      'subject': subject,
      'contact': contact,
    };
  }

  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    return TeacherModel(
      teacherId: map['teacherId'] ?? '',
      name: map['name'] ?? '',
      subject: map['subject'] ?? '',
      contact: map['contact'] ?? '',
    );
  }
}

class TimetableModel {
  final int id;
  final String course; // e.g., MCA, MBA, MSCIT, MCOM, BTECH
  final String subject;
  final String timeSlot;
  final String dayOfWeek;
  final String roomNumber;
  final String assignedTeacher;

  TimetableModel({
    required this.id,
    this.course = 'General', // Default value taaki missing hone par compile error na aaye
    required this.subject,
    required this.timeSlot,
    required this.dayOfWeek,
    required this.roomNumber,
    required this.assignedTeacher,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course': course,
      'subject': subject,
      'timeSlot': timeSlot,
      'dayOfWeek': dayOfWeek,
      'roomNumber': roomNumber,
      'assignedTeacher': assignedTeacher,
    };
  }

  factory TimetableModel.fromMap(Map<String, dynamic> map) {
    return TimetableModel(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      course: map['course'] ?? 'General',
      subject: map['subject'] ?? '',
      timeSlot: map['timeSlot'] ?? '',
      dayOfWeek: map['dayOfWeek'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      assignedTeacher: map['assignedTeacher'] ?? '',
    );
  }
}

class ReminderModel {
  final int id;
  final String teacherId;
  final String subject;
  final String timeSlot;
  final int minutesBefore;
  bool isEnabled;

  ReminderModel({
    required this.id,
    required this.teacherId,
    required this.subject,
    required this.timeSlot,
    required this.minutesBefore,
    this.isEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId,
      'subject': subject,
      'timeSlot': timeSlot,
      'minutesBefore': minutesBefore,
      'isEnabled': isEnabled ? 1 : 0,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      teacherId: map['teacherId'] ?? '',
      subject: map['subject'] ?? '',
      timeSlot: map['timeSlot'] ?? '',
      minutesBefore: map['minutesBefore'] is int
          ? map['minutesBefore']
          : int.tryParse(map['minutesBefore'].toString()) ?? 0,
      isEnabled: map['isEnabled'] == 1 || map['isEnabled'] == true,
    );
  }
}