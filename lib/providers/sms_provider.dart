import 'package:flutter/material.dart';
import '../models/sms_models.dart';
import '../services/db_helper.dart';

class SmsProvider extends ChangeNotifier {
  UserModel? _currentUser;
  StudentModel? _studentProfile;
  StudentModel? _lookupStudent;
  List<StudentModel> _allStudents = [];
  String? _loginError;
  String? _ingestionMessage;
  bool _ingestionSuccess = false;

  List<TimetableModel> _timetable = [];
  List<ReminderModel> _teacherReminders = [];

  UserModel? get currentUser => _currentUser;
  StudentModel? get studentProfile => _studentProfile;
  StudentModel? get lookupStudent => _lookupStudent;
  List<StudentModel> get allStudents => _allStudents;
  String? get loginError => _loginError;
  String? get ingestionMessage => _ingestionMessage;
  bool get ingestionSuccess => _ingestionSuccess;

  List<TimetableModel> get timetable => _timetable;
  List<ReminderModel> get teacherReminders => _teacherReminders;

  SmsProvider() {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      _allStudents = await DBHelper.instance.getAllStudents();
      _timetable = await DBHelper.instance.getTimetable();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> login(String username, String password, String selectedRole) async {
    _loginError = null;
    notifyListeners();

    try {
      final user = await DBHelper.instance.getUser(username).timeout(
        const Duration(seconds: 4),
        onTimeout: () => null,
      );

      if (user == null) {
        _loginError = "User profile not found. Default: S101 / student123";
        notifyListeners();
        return false;
      }
      if (user.passwordHash != password) {
        _loginError = "Invalid password credential.";
        notifyListeners();
        return false;
      }
      if (user.role != selectedRole) {
        _loginError = "Role mismatch for this user ID. Select correct tab.";
        notifyListeners();
        return false;
      }

      _currentUser = user;
      if (selectedRole == 'STUDENT') {
        _studentProfile = await DBHelper.instance.getStudent(username);
      } else if (selectedRole == 'TEACHER') {
        _teacherReminders = await DBHelper.instance.getReminders(username);
      }
      _allStudents = await DBHelper.instance.getAllStudents();
      _timetable = await DBHelper.instance.getTimetable();

      notifyListeners();
      return true;
    } catch (e) {
      _loginError = "Database issue: App data clear karein aur re-login karein.";
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _studentProfile = null;
    _lookupStudent = null;
    _loginError = null;
    notifyListeners();
  }

  Future<void> searchStudentByRollNo(String rollNo) async {
    if (rollNo.trim().isEmpty) {
      _lookupStudent = null;
    } else {
      _lookupStudent = await DBHelper.instance.getStudent(rollNo.trim());
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> changePasswordAndSetupSecurity({
    required String username,
    required String oldPassword,
    required String newPassword,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    final user = await DBHelper.instance.getUser(username);
    if (user == null) {
      return {'success': false, 'message': 'Username / ID not found!'};
    }

    if (user.passwordHash != oldPassword) {
      return {'success': false, 'message': 'Incorrect Old Password!'};
    }

    await DBHelper.instance.updateUserPasswordAndSecurity(
      username: username,
      newPassword: newPassword,
      securityQuestion: securityQuestion,
      securityAnswer: securityAnswer,
    );
    notifyListeners();
    return {'success': true, 'message': 'Password and Security Answer updated!'};
  }

  Future<Map<String, dynamic>> verifyAndResetPassword({
    required String username,
    required String securityAnswer,
    required String newPassword,
  }) async {
    final userDetails = await DBHelper.instance.getUserSecurityDetails(username);
    if (userDetails == null) {
      return {'success': false, 'message': 'Username / ID not found!'};
    }

    final savedAnswer = (userDetails['securityAnswer'] as String? ?? '').toLowerCase().trim();
    if (savedAnswer.isEmpty) {
      return {'success': false, 'message': 'Security Answer not setup! Contact Management.'};
    }

    if (savedAnswer != securityAnswer.toLowerCase().trim()) {
      return {'success': false, 'message': 'Incorrect Security Answer!'};
    }

    await DBHelper.instance.updateUserPassword(username, newPassword);
    notifyListeners();
    return {'success': true, 'message': 'Password reset successfully!'};
  }

  Future<void> updateUserPassword(String username, String newPassword) async {
    await DBHelper.instance.updateUserPassword(username, newPassword);
    notifyListeners();
  }

  Future<void> updateStudentDetails(StudentModel s) async {
    await DBHelper.instance.updateStudent(s);
    _allStudents = await DBHelper.instance.getAllStudents();
    if (_currentUser?.username == s.rollNo) {
      _studentProfile = s;
    }
    notifyListeners();
  }

  Future<void> addReminder(String subject, String timeSlot, int minutesBefore) async {
    if (_currentUser == null) return;
    final reminder = ReminderModel(
      id: 0,
      teacherId: _currentUser!.username,
      subject: subject,
      timeSlot: timeSlot,
      minutesBefore: minutesBefore,
      isEnabled: true,
    );
    await DBHelper.instance.insertReminder(reminder);
    _teacherReminders = await DBHelper.instance.getReminders(_currentUser!.username);
    notifyListeners();
  }

  Future<void> toggleReminder(ReminderModel reminder) async {
    await DBHelper.instance.toggleReminder(reminder.id, !reminder.isEnabled);
    _teacherReminders = await DBHelper.instance.getReminders(_currentUser!.username);
    notifyListeners();
  }

  Future<void> addManualStudent(StudentModel s) async {
    await DBHelper.instance.insertStudent(s);
    _allStudents = await DBHelper.instance.getAllStudents();
    notifyListeners();
  }

  Future<void> addManualTeacher(TeacherModel t) async {
    await DBHelper.instance.insertTeacher(t);
    notifyListeners();
  }

  Future<void> addTimetableSlot(TimetableModel t) async {
    await DBHelper.instance.insertTimetable(t);
    _timetable = await DBHelper.instance.getTimetable();
    notifyListeners();
  }

  Future<void> parseAndIngestCSV(String csvText) async {
    try {
      final lines = csvText.split('\n');
      int count = 0;
      for (var line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.toLowerCase().startsWith('roll')) continue;
        final parts = trimmed.split(',').map((e) => e.trim()).toList();
        if (parts.length >= 7) {
          final s = StudentModel(
            rollNo: parts[0],
            name: parts[1],
            course: parts[2],
            semester: parts[3],
            gpa: double.tryParse(parts[4]) ?? 0.0,
            attendance: double.tryParse(parts[5]) ?? 0.0,
            scoresJson: parts[6],
            assignmentsJson: parts.length >= 8 ? parts[7] : "No pending assignments",
          );
          await DBHelper.instance.insertStudent(s);
          count++;
        }
      }
      if (count > 0) {
        _allStudents = await DBHelper.instance.getAllStudents();
        _ingestionSuccess = true;
        _ingestionMessage = "Successfully imported $count student profiles into SQLite local database!";
      } else {
        _ingestionSuccess = false;
        _ingestionMessage = "No valid rows parsed.";
      }
    } catch (e) {
      _ingestionSuccess = false;
      _ingestionMessage = "Parsing error: ${e.toString()}";
    }
    notifyListeners();
  }

  Future<void> resetDatabaseDefaults() async {
    await DBHelper.instance.resetDatabaseDefaults();
    _allStudents = await DBHelper.instance.getAllStudents();
    _timetable = await DBHelper.instance.getTimetable();
    notifyListeners();
  }
}