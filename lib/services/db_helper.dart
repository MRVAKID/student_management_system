import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/sms_models.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  final Map<String, UserModel> _memoryUsers = {};
  final Map<String, StudentModel> _memoryStudents = {};
  final List<TimetableModel> _memoryTimetable = [];
  final List<ReminderModel> _memoryReminders = [];
  bool _isSeeded = false;

  DBHelper._init() {
    _seedAllData();
  }

  void _seedAllData() {
    if (_isSeeded) return;

    // 1. Admin & Faculty
    _memoryUsers['admin'] = UserModel(
      username: 'admin',
      passwordHash: 'admin123',
      role: 'MANAGEMENT',
      displayName: 'College Management',
      securityQuestion: 'What is your favorite color?',
      securityAnswer: 'blue',
    );

    _memoryUsers['T201'] = UserModel(
      username: 'T201',
      passwordHash: 'teacher123',
      role: 'TEACHER',
      displayName: 'Ms. Manali Panchal (MJP)',
      securityQuestion: 'What is your favorite color?',
      securityAnswer: 'blue',
    );

    // 2. 5 Department Students
    final students = [
      StudentModel(
        rollNo: 'S101',
        name: 'Mansuri Vakid',
        course: 'Master of Computer Application (MCA)',
        semester: 'Semester 3',
        gpa: 3.85,
        attendance: 78.5,
        scoresJson: 'DLCV: A, FOB: A-, SPM: B+',
        assignmentsJson: 'Minor Project Report - Due Jul 25; DLCV Lab - Due Jul 28',
      ),
      StudentModel(
        rollNo: 'S102',
        name: 'Rahul Sharma',
        course: 'Master of Business Administration (MBA)',
        semester: 'Semester 2',
        gpa: 3.70,
        attendance: 85.0,
        scoresJson: 'Business Analytics: A, Financial Modeling: B+, Digital Marketing: A',
        assignmentsJson: 'Valuation Pitch Deck - Due Jul 30',
      ),
      StudentModel(
        rollNo: 'S103',
        name: 'Priya Patel',
        course: 'MSc Information Technology (MSc IT)',
        semester: 'Semester 3',
        gpa: 3.92,
        attendance: 92.0,
        scoresJson: 'Cloud Virtualization: A+, DevOps: A, Threat Intel: A-',
        assignmentsJson: 'Kubernetes Cluster Setup - Due Aug 02',
      ),
      StudentModel(
        rollNo: 'S104',
        name: 'Amit Joshi',
        course: 'Master of Commerce (M.Com)',
        semester: 'Semester 1',
        gpa: 3.65,
        attendance: 81.0,
        scoresJson: 'Forensic Auditing: A-, Corporate Accounting: B+, Derivatives: A',
        assignmentsJson: 'Forensic Audit Report - Due Jul 26',
      ),
      StudentModel(
        rollNo: 'S105',
        name: 'Neha Verma',
        course: 'B.Tech Computer Science (CSE)',
        semester: 'Semester 4',
        gpa: 3.88,
        attendance: 74.0,
        scoresJson: 'Compiler Design: A, Computer Architecture: A-, Algorithms: B+',
        assignmentsJson: 'Lexical Analyzer Implementation - Due Aug 05',
      ),
    ];

    for (var s in students) {
      _memoryStudents[s.rollNo] = s;
      _memoryUsers[s.rollNo] = UserModel(
        username: s.rollNo,
        passwordHash: 'student123',
        role: 'STUDENT',
        displayName: s.name,
        securityQuestion: 'What is your favorite color?',
        securityAnswer: 'blue',
      );
    }

    // 3. Timetable (S101 Official Intact + 4 Re-architected Specific Schedules)
    _memoryTimetable.clear();
    _memoryTimetable.addAll([
      // =========================================================================
      // 1. S101: MCA Sem-3 Batch A3 (Silver Oak Official Sheet Unaltered)
      // =========================================================================
      // Monday
      TimetableModel(id: 101, course: 'MCA', subject: 'DLCV Practical (Lab)', timeSlot: '07:30 AM - 09:10 AM', dayOfWeek: 'Monday', roomNumber: 'B-214', assignedTeacher: 'Ms. Manali Panchal (MJP)'),
      TimetableModel(id: 102, course: 'MCA', subject: 'Software Project Management (SPM)', timeSlot: '09:20 AM - 10:10 AM', dayOfWeek: 'Monday', roomNumber: 'B-206', assignedTeacher: 'Ms. Meghna Panara (PMR)'),
      TimetableModel(id: 103, course: 'MCA', subject: 'Deep Learning with Computer Vision (DLCV)', timeSlot: '10:10 AM - 11:00 AM', dayOfWeek: 'Monday', roomNumber: 'B-206', assignedTeacher: 'Ms. Risha Tiwari (RTA)'),
      // Tuesday
      TimetableModel(id: 104, course: 'MCA', subject: 'Library (LIB)', timeSlot: '07:30 AM - 08:20 AM', dayOfWeek: 'Tuesday', roomNumber: 'Central Library', assignedTeacher: 'Library In-charge'),
      TimetableModel(id: 105, course: 'MCA', subject: 'Deep Learning with Computer Vision (DLCV)', timeSlot: '08:20 AM - 09:10 AM', dayOfWeek: 'Tuesday', roomNumber: 'B-206', assignedTeacher: 'Ms. Manali Panchal (MJP)'),
      TimetableModel(id: 106, course: 'MCA', subject: 'Full Stack Development (FSD Practical)', timeSlot: '09:20 AM - 11:00 AM', dayOfWeek: 'Tuesday', roomNumber: 'B-214', assignedTeacher: 'Mr. Harsh Barot (HDB)'),
      // Wednesday
      TimetableModel(id: 107, course: 'MCA', subject: 'Fundamentals of Blockchain (FOB)', timeSlot: '07:30 AM - 09:10 AM', dayOfWeek: 'Wednesday', roomNumber: 'B-206', assignedTeacher: 'Dr. Shyam Chavda (SNC)'),
      TimetableModel(id: 108, course: 'MCA', subject: 'Full Stack Development (FSD Practical)', timeSlot: '09:20 AM - 11:00 AM', dayOfWeek: 'Wednesday', roomNumber: 'B-214', assignedTeacher: 'Mr. Dhruv Patel (DMP)'),
      TimetableModel(id: 109, course: 'MCA', subject: 'Software Project Management (SPM)', timeSlot: '11:10 AM - 12:00 PM', dayOfWeek: 'Wednesday', roomNumber: 'B-206', assignedTeacher: 'Ms. Meghna Panara (PMR)'),
      // Thursday
      TimetableModel(id: 110, course: 'MCA', subject: 'Fundamentals of Blockchain (FOB)', timeSlot: '07:30 AM - 09:10 AM', dayOfWeek: 'Thursday', roomNumber: 'B-206', assignedTeacher: 'Dr. Shyam Chavda (SNC)'),
      TimetableModel(id: 111, course: 'MCA', subject: 'Fundamentals of Blockchain (FOB Practical)', timeSlot: '09:20 AM - 11:00 AM', dayOfWeek: 'Thursday', roomNumber: 'B-214', assignedTeacher: 'Ms. Madhvi Bhuptani (MNB)'),
      // Friday
      TimetableModel(id: 112, course: 'MCA', subject: 'DLCV Practical (Lab)', timeSlot: '07:30 AM - 09:10 AM', dayOfWeek: 'Friday', roomNumber: 'B-214', assignedTeacher: 'Ms. Manali Panchal (MJP)'),
      TimetableModel(id: 113, course: 'MCA', subject: 'Deep Learning with Computer Vision (DLCV)', timeSlot: '09:20 AM - 10:10 AM', dayOfWeek: 'Friday', roomNumber: 'B-206', assignedTeacher: 'Ms. Manali Panchal (MJP)'),
      TimetableModel(id: 114, course: 'MCA', subject: 'Library (LIB)', timeSlot: '10:10 AM - 11:00 AM', dayOfWeek: 'Friday', roomNumber: 'Central Library', assignedTeacher: 'Library In-charge'),
      TimetableModel(id: 115, course: 'MCA', subject: 'Software Project Management (SPM)', timeSlot: '11:10 AM - 12:00 PM', dayOfWeek: 'Friday', roomNumber: 'B-206', assignedTeacher: 'Ms. Meghna Panara (PMR)'),
      // Saturday
      TimetableModel(id: 116, course: 'MCA', subject: 'Fundamentals of Blockchain (FOB Practical)', timeSlot: '07:30 AM - 09:10 AM', dayOfWeek: 'Saturday', roomNumber: 'B-214', assignedTeacher: 'Mr. Dhruv Patel (DMP)'),
      TimetableModel(id: 117, course: 'MCA', subject: 'Software Project Management (SPM)', timeSlot: '09:20 AM - 10:10 AM', dayOfWeek: 'Saturday', roomNumber: 'B-206', assignedTeacher: 'Ms. Meghna Panara (PMR)'),
      TimetableModel(id: 118, course: 'MCA', subject: 'Deep Learning with Computer Vision (DLCV)', timeSlot: '10:10 AM - 11:00 AM', dayOfWeek: 'Saturday', roomNumber: 'B-206', assignedTeacher: 'Ms. Risha Tiwari (RTA)'),

      // =========================================================================
      // 2. S102: MBA (Management, Finance, Analytics & Marketing Schedule)
      // =========================================================================
      // Monday
      TimetableModel(id: 201, course: 'MBA', subject: 'Business Analytics & Visualization', timeSlot: '08:30 AM - 09:30 AM', dayOfWeek: 'Monday', roomNumber: 'MBA-101', assignedTeacher: 'Dr. Alok Nath'),
      TimetableModel(id: 202, course: 'MBA', subject: 'Financial Modeling & Valuation', timeSlot: '09:40 AM - 10:40 AM', dayOfWeek: 'Monday', roomNumber: 'Fin-Lab 1', assignedTeacher: 'Prof. Sunita Rao'),
      TimetableModel(id: 203, course: 'MBA', subject: 'Digital Marketing & Social Media Strategies', timeSlot: '11:00 AM - 12:00 PM', dayOfWeek: 'Monday', roomNumber: 'MBA-101', assignedTeacher: 'Prof. J. C. Shah'),
      // Tuesday
      TimetableModel(id: 204, course: 'MBA', subject: 'Advanced Spreadsheets & Tableau Lab', timeSlot: '08:30 AM - 10:30 AM', dayOfWeek: 'Tuesday', roomNumber: 'Analytics Lab', assignedTeacher: 'Dr. Alok Nath'),
      TimetableModel(id: 205, course: 'MBA', subject: 'Corporate Governance & Business Ethics', timeSlot: '10:45 AM - 11:45 AM', dayOfWeek: 'Tuesday', roomNumber: 'MBA-101', assignedTeacher: 'Dr. R. K. Sharma'),
      // Wednesday
      TimetableModel(id: 206, course: 'MBA', subject: 'Operations Research & Logistics', timeSlot: '08:30 AM - 09:30 AM', dayOfWeek: 'Wednesday', roomNumber: 'MBA-101', assignedTeacher: 'Prof. Anjali Verma'),
      TimetableModel(id: 207, course: 'MBA', subject: 'Consumer Behavior & Market Research', timeSlot: '09:40 AM - 10:40 AM', dayOfWeek: 'Wednesday', roomNumber: 'MBA-101', assignedTeacher: 'Prof. J. C. Shah'),
      TimetableModel(id: 208, course: 'MBA', subject: 'Harvard Business Case Study Analysis', timeSlot: '11:00 AM - 12:30 PM', dayOfWeek: 'Wednesday', roomNumber: 'Executive Hall', assignedTeacher: 'Dr. Vivek Saxena'),
      // Thursday
      TimetableModel(id: 209, course: 'MBA', subject: 'Strategic Human Resource Metrics', timeSlot: '08:30 AM - 09:30 AM', dayOfWeek: 'Thursday', roomNumber: 'MBA-101', assignedTeacher: 'Prof. Anjali Verma'),
      TimetableModel(id: 210, course: 'MBA', subject: 'Investment Banking & Equity Research', timeSlot: '09:40 AM - 10:40 AM', dayOfWeek: 'Thursday', roomNumber: 'Fin-Lab 1', assignedTeacher: 'Prof. Sunita Rao'),
      TimetableModel(id: 211, course: 'MBA', subject: 'Managerial Negotiation Simulation Lab', timeSlot: '11:00 AM - 12:15 PM', dayOfWeek: 'Thursday', roomNumber: 'Boardroom', assignedTeacher: 'Dr. Vivek Saxena'),
      // Friday
      TimetableModel(id: 212, course: 'MBA', subject: 'Global Supply Chain Management', timeSlot: '08:30 AM - 09:30 AM', dayOfWeek: 'Friday', roomNumber: 'MBA-101', assignedTeacher: 'Dr. R. K. Sharma'),
      TimetableModel(id: 213, course: 'MBA', subject: 'FinTech Innovations & Venture Capital', timeSlot: '09:40 AM - 10:40 AM', dayOfWeek: 'Friday', roomNumber: 'MBA-101', assignedTeacher: 'Prof. Sunita Rao'),
      TimetableModel(id: 214, course: 'MBA', subject: 'Corporate Leadership Forum', timeSlot: '11:00 AM - 12:00 PM', dayOfWeek: 'Friday', roomNumber: 'Seminar Hall-2', assignedTeacher: 'Dr. Vivek Saxena'),
      // Saturday
      TimetableModel(id: 215, course: 'MBA', subject: 'CXO Interaction & Industry Talk', timeSlot: '09:00 AM - 10:45 AM', dayOfWeek: 'Saturday', roomNumber: 'Auditorium-1', assignedTeacher: 'Corporate Guest'),
      TimetableModel(id: 216, course: 'MBA', subject: 'Capstone Business Plan Presentation', timeSlot: '11:00 AM - 12:30 PM', dayOfWeek: 'Saturday', roomNumber: 'Executive Hall', assignedTeacher: 'Faculty Panel'),

      // =========================================================================
      // 3. S103: MSc IT (Cloud Architecture, DevOps, Security & Big Data)
      // =========================================================================
      // Monday
      TimetableModel(id: 301, course: 'MSCIT', subject: 'Cloud Virtualization & Containers (Docker)', timeSlot: '08:00 AM - 09:30 AM', dayOfWeek: 'Monday', roomNumber: 'Lab-304', assignedTeacher: 'Dr. Rajesh Solanki'),
      TimetableModel(id: 302, course: 'MSCIT', subject: 'Cyber Threat Intelligence & SOC', timeSlot: '09:45 AM - 11:00 AM', dayOfWeek: 'Monday', roomNumber: 'Hall-205', assignedTeacher: 'Prof. Mitesh Patel'),
      // Tuesday
      TimetableModel(id: 303, course: 'MSCIT', subject: 'Kubernetes & CI/CD Pipeline Lab', timeSlot: '08:00 AM - 10:15 AM', dayOfWeek: 'Tuesday', roomNumber: 'Cloud Lab-1', assignedTeacher: 'Dr. Rajesh Solanki'),
      TimetableModel(id: 304, course: 'MSCIT', subject: 'Natural Language Processing (NLP)', timeSlot: '10:30 AM - 11:45 AM', dayOfWeek: 'Tuesday', roomNumber: 'Hall-205', assignedTeacher: 'Prof. Jignesh Vyas'),
      // Wednesday
      TimetableModel(id: 305, course: 'MSCIT', subject: 'Advanced Cryptography & PKI', timeSlot: '08:00 AM - 09:15 AM', dayOfWeek: 'Wednesday', roomNumber: 'Hall-205', assignedTeacher: 'Prof. Mitesh Patel'),
      TimetableModel(id: 306, course: 'MSCIT', subject: 'Distributed Big Data Systems (Spark/Kafka)', timeSlot: '09:30 AM - 10:45 AM', dayOfWeek: 'Wednesday', roomNumber: 'Lab-304', assignedTeacher: 'Prof. Jignesh Vyas'),
      TimetableModel(id: 307, course: 'MSCIT', subject: 'Deep Reinforcement Learning', timeSlot: '11:00 AM - 12:15 PM', dayOfWeek: 'Wednesday', roomNumber: 'Hall-205', assignedTeacher: 'Dr. Rajesh Solanki'),
      // Thursday
      TimetableModel(id: 308, course: 'MSCIT', subject: 'Big Data Pipeline Engineering Lab', timeSlot: '08:00 AM - 10:30 AM', dayOfWeek: 'Thursday', roomNumber: 'Lab-304', assignedTeacher: 'Prof. Jignesh Vyas'),
      TimetableModel(id: 309, course: 'MSCIT', subject: 'Enterprise Cloud Security Architecture', timeSlot: '10:45 AM - 12:00 PM', dayOfWeek: 'Thursday', roomNumber: 'Hall-205', assignedTeacher: 'Prof. Mitesh Patel'),
      // Friday
      TimetableModel(id: 310, course: 'MSCIT', subject: 'Offensive Security & Red Teaming Lab', timeSlot: '08:00 AM - 10:15 AM', dayOfWeek: 'Friday', roomNumber: 'Security SOC Lab', assignedTeacher: 'Prof. Mitesh Patel'),
      TimetableModel(id: 311, course: 'MSCIT', subject: 'Neural Networks & Computer Vision', timeSlot: '10:30 AM - 11:45 AM', dayOfWeek: 'Friday', roomNumber: 'Hall-205', assignedTeacher: 'Dr. Rajesh Solanki'),
      // Saturday
      TimetableModel(id: 312, course: 'MSCIT', subject: 'Dissertation Research & Code Defense', timeSlot: '08:30 AM - 11:30 AM', dayOfWeek: 'Saturday', roomNumber: 'Research Lab-2', assignedTeacher: 'Review Committee'),

      // =========================================================================
      // 4. S104: M.Com (Advanced Accounting, Forensic Audit, Tax & Banking)
      // =========================================================================
      // Monday
      TimetableModel(id: 401, course: 'MCOM', subject: 'Advanced Corporate Financial Accounting', timeSlot: '08:00 AM - 09:10 AM', dayOfWeek: 'Monday', roomNumber: 'Room-402', assignedTeacher: 'Prof. N. K. Joshi'),
      TimetableModel(id: 402, course: 'MCOM', subject: 'Forensic Accounting & Fraud Auditing', timeSlot: '09:20 AM - 10:30 AM', dayOfWeek: 'Monday', roomNumber: 'Room-402', assignedTeacher: 'Dr. Bina Desai'),
      // Tuesday
      TimetableModel(id: 403, course: 'MCOM', subject: 'Direct Taxes & Corporate Tax Planning', timeSlot: '08:00 AM - 09:15 AM', dayOfWeek: 'Tuesday', roomNumber: 'Room-402', assignedTeacher: 'Prof. N. K. Joshi'),
      TimetableModel(id: 404, course: 'MCOM', subject: 'SAP FICO & ERP Financials Lab', timeSlot: '09:30 AM - 11:30 AM', dayOfWeek: 'Tuesday', roomNumber: 'Commerce ERP Lab', assignedTeacher: 'Prof. S. R. Patel'),
      // Wednesday
      TimetableModel(id: 405, course: 'MCOM', subject: 'Financial Derivatives & Risk Management', timeSlot: '08:00 AM - 09:10 AM', dayOfWeek: 'Wednesday', roomNumber: 'Room-402', assignedTeacher: 'Dr. Bina Desai'),
      TimetableModel(id: 406, course: 'MCOM', subject: 'International Banking & Forex Treasury', timeSlot: '09:20 AM - 10:30 AM', dayOfWeek: 'Wednesday', roomNumber: 'Room-402', assignedTeacher: 'Prof. N. K. Joshi'),
      TimetableModel(id: 407, course: 'MCOM', subject: 'Statutory Audit Simulation Workshop', timeSlot: '10:45 AM - 12:00 PM', dayOfWeek: 'Wednesday', roomNumber: 'Commerce Lab', assignedTeacher: 'Dr. Bina Desai'),
      // Thursday
      TimetableModel(id: 408, course: 'MCOM', subject: 'Goods & Services Tax (GST) Advanced Filing', timeSlot: '08:00 AM - 09:15 AM', dayOfWeek: 'Thursday', roomNumber: 'Room-402', assignedTeacher: 'Prof. S. R. Patel'),
      TimetableModel(id: 409, course: 'MCOM', subject: 'Corporate Restructuring, Mergers & Acquisition', timeSlot: '09:30 AM - 10:45 AM', dayOfWeek: 'Thursday', roomNumber: 'Room-402', assignedTeacher: 'Prof. N. K. Joshi'),
      TimetableModel(id: 410, course: 'MCOM', subject: 'Business Valuation & Due Diligence', timeSlot: '11:00 AM - 12:00 PM', dayOfWeek: 'Thursday', roomNumber: 'Room-402', assignedTeacher: 'Dr. Bina Desai'),
      // Friday
      TimetableModel(id: 411, course: 'MCOM', subject: 'Econometrics & Empirical Research Lab', timeSlot: '08:00 AM - 10:00 AM', dayOfWeek: 'Friday', roomNumber: 'Commerce ERP Lab', assignedTeacher: 'Prof. S. R. Patel'),
      TimetableModel(id: 412, course: 'MCOM', subject: 'IFRS & Global Accounting Standards', timeSlot: '10:15 AM - 11:30 AM', dayOfWeek: 'Friday', roomNumber: 'Room-402', assignedTeacher: 'Prof. N. K. Joshi'),
      // Saturday
      TimetableModel(id: 413, course: 'MCOM', subject: 'Stock & Derivatives Live Market Terminal', timeSlot: '08:30 AM - 10:45 AM', dayOfWeek: 'Saturday', roomNumber: 'Fin-Terminal Lab', assignedTeacher: 'Visiting CA Expert'),
      TimetableModel(id: 414, course: 'MCOM', subject: 'Case Analysis in Corporate Scams', timeSlot: '11:00 AM - 12:15 PM', dayOfWeek: 'Saturday', roomNumber: 'Room-402', assignedTeacher: 'Dr. Bina Desai'),

      // =========================================================================
      // 5. S105: B.Tech CSE (Core CS: Compilers, Architecture, Systems & Algo)
      // =========================================================================
      // Monday
      TimetableModel(id: 501, course: 'BTECH', subject: 'Compiler Design & Grammar Parsing', timeSlot: '08:00 AM - 09:00 AM', dayOfWeek: 'Monday', roomNumber: 'LH-102', assignedTeacher: 'Prof. Amit Trivedi'),
      TimetableModel(id: 502, course: 'BTECH', subject: 'Computer Architecture & Pipelining', timeSlot: '09:10 AM - 10:10 AM', dayOfWeek: 'Monday', roomNumber: 'LH-102', assignedTeacher: 'Dr. Kiran Prajapati'),
      TimetableModel(id: 503, course: 'BTECH', subject: 'Distributed Operating Systems', timeSlot: '10:30 AM - 11:30 AM', dayOfWeek: 'Monday', roomNumber: 'LH-102', assignedTeacher: 'Prof. Priya Nair'),
      // Tuesday
      TimetableModel(id: 504, course: 'BTECH', subject: 'Lex & Yacc Compiler Tool Lab', timeSlot: '08:00 AM - 10:00 AM', dayOfWeek: 'Tuesday', roomNumber: 'CS Lab-2', assignedTeacher: 'Prof. Amit Trivedi'),
      TimetableModel(id: 505, course: 'BTECH', subject: 'Theory of Computation & Automata (TOC)', timeSlot: '10:15 AM - 11:15 AM', dayOfWeek: 'Tuesday', roomNumber: 'LH-102', assignedTeacher: 'Prof. Amit Trivedi'),
      TimetableModel(id: 506, course: 'BTECH', subject: 'Microprocessors & Embedded Systems (8086/ARM)', timeSlot: '11:30 AM - 12:30 PM', dayOfWeek: 'Tuesday', roomNumber: 'LH-102', assignedTeacher: 'Dr. Kiran Prajapati'),
      // Wednesday
      TimetableModel(id: 507, course: 'BTECH', subject: 'Design & Analysis of Algorithms (DAA)', timeSlot: '08:00 AM - 09:00 AM', dayOfWeek: 'Wednesday', roomNumber: 'LH-102', assignedTeacher: 'Prof. Priya Nair'),
      TimetableModel(id: 508, course: 'BTECH', subject: 'Microprocessor Hardware Interfacing Lab', timeSlot: '09:15 AM - 11:15 AM', dayOfWeek: 'Wednesday', roomNumber: 'Hardware Lab', assignedTeacher: 'Dr. Kiran Prajapati'),
      TimetableModel(id: 509, course: 'BTECH', subject: 'Computer Graphics & OpenGL', timeSlot: '11:30 AM - 12:30 PM', dayOfWeek: 'Wednesday', roomNumber: 'LH-102', assignedTeacher: 'Prof. Priya Nair'),
      // Thursday
      TimetableModel(id: 510, course: 'BTECH', subject: 'Advanced Algorithms & Graph Problem Lab', timeSlot: '08:00 AM - 10:00 AM', dayOfWeek: 'Thursday', roomNumber: 'CS Lab-1', assignedTeacher: 'Prof. Priya Nair'),
      TimetableModel(id: 511, course: 'BTECH', subject: 'Software Architecture & System Design', timeSlot: '10:15 AM - 11:15 AM', dayOfWeek: 'Thursday', roomNumber: 'LH-102', assignedTeacher: 'Prof. Amit Trivedi'),
      TimetableModel(id: 512, course: 'BTECH', subject: 'Signals & Information Coding', timeSlot: '11:30 AM - 12:30 PM', dayOfWeek: 'Thursday', roomNumber: 'LH-102', assignedTeacher: 'Dr. Kiran Prajapati'),
      // Friday
      TimetableModel(id: 513, course: 'BTECH', subject: 'OpenGL Graphics 3D Shader Lab', timeSlot: '08:00 AM - 10:00 AM', dayOfWeek: 'Friday', roomNumber: 'Graphics Lab', assignedTeacher: 'Prof. Priya Nair'),
      TimetableModel(id: 514, course: 'BTECH', subject: 'High Performance Computing (HPC)', timeSlot: '10:15 AM - 11:15 AM', dayOfWeek: 'Friday', roomNumber: 'LH-102', assignedTeacher: 'Prof. Amit Trivedi'),
      TimetableModel(id: 515, course: 'BTECH', subject: 'Peer Code Review & Technical Seminar', timeSlot: '11:30 AM - 12:30 PM', dayOfWeek: 'Friday', roomNumber: 'Seminar Hall-1', assignedTeacher: 'Faculty Panel'),
      // Saturday
      TimetableModel(id: 516, course: 'BTECH', subject: 'Hackathon Project Development Lab', timeSlot: '08:30 AM - 11:30 AM', dayOfWeek: 'Saturday', roomNumber: 'Incubation Center', assignedTeacher: 'Project Mentor Team'),
    ]);

    // 4. Period Alerts for Ms. Manali Panchal (MJP)
    _memoryReminders.clear();
    _memoryReminders.addAll([
      ReminderModel(
        id: 1,
        teacherId: 'T201',
        subject: 'DLCV Practical (Lab B-214)',
        timeSlot: '07:30 AM - 09:10 AM (Mon)',
        minutesBefore: 10,
        isEnabled: true,
      ),
      ReminderModel(
        id: 2,
        teacherId: 'T201',
        subject: 'Deep Learning with Computer Vision (B-206)',
        timeSlot: '08:20 AM - 09:10 AM (Tue)',
        minutesBefore: 10,
        isEnabled: true,
      ),
      ReminderModel(
        id: 3,
        teacherId: 'T201',
        subject: 'DLCV Practical (Lab B-214)',
        timeSlot: '07:30 AM - 09:10 AM (Fri)',
        minutesBefore: 10,
        isEnabled: true,
      ),
      ReminderModel(
        id: 4,
        teacherId: 'T201',
        subject: 'Deep Learning with Computer Vision (B-206)',
        timeSlot: '09:20 AM - 10:10 AM (Fri)',
        minutesBefore: 10,
        isEnabled: true,
      ),
    ]);

    _isSeeded = true;
  }

  Future<Database?> get database async {
    if (kIsWeb) return null;
    try {
      if (_database != null) return _database!;
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'student_management.db');
      _database = await openDatabase(
        path,
        version: 3,
        onCreate: (db, version) async {
          await db.execute('CREATE TABLE users (username TEXT PRIMARY KEY, passwordHash TEXT, role TEXT, displayName TEXT, securityQuestion TEXT, securityAnswer TEXT)');
          await db.execute('CREATE TABLE students (rollNo TEXT PRIMARY KEY, name TEXT, course TEXT, semester TEXT, gpa REAL, attendance REAL, scoresJson TEXT, assignmentsJson TEXT)');
          await db.execute('CREATE TABLE teachers (teacherId TEXT PRIMARY KEY, name TEXT, subject TEXT, contact TEXT)');
          await db.execute('CREATE TABLE timetable (id INTEGER PRIMARY KEY AUTOINCREMENT, course TEXT, subject TEXT, timeSlot TEXT, dayOfWeek TEXT, roomNumber TEXT, assignedTeacher TEXT)');
          await db.execute('CREATE TABLE reminders (id INTEGER PRIMARY KEY AUTOINCREMENT, teacherId TEXT, subject TEXT, timeSlot TEXT, minutesBefore INTEGER, isEnabled INTEGER)');

          for (var u in _memoryUsers.values) {
            await db.insert('users', {'username': u.username, 'passwordHash': u.passwordHash, 'role': u.role, 'displayName': u.displayName, 'securityQuestion': u.securityQuestion, 'securityAnswer': u.securityAnswer});
          }
          for (var s in _memoryStudents.values) {
            await db.insert('students', {'rollNo': s.rollNo, 'name': s.name, 'course': s.course, 'semester': s.semester, 'gpa': s.gpa, 'attendance': s.attendance, 'scoresJson': s.scoresJson, 'assignmentsJson': s.assignmentsJson});
          }
          for (var t in _memoryTimetable) {
            await db.insert('timetable', {'course': t.course, 'subject': t.subject, 'timeSlot': t.timeSlot, 'dayOfWeek': t.dayOfWeek, 'roomNumber': t.roomNumber, 'assignedTeacher': t.assignedTeacher});
          }
          for (var r in _memoryReminders) {
            await db.insert('reminders', {'teacherId': r.teacherId, 'subject': r.subject, 'timeSlot': r.timeSlot, 'minutesBefore': r.minutesBefore, 'isEnabled': r.isEnabled ? 1 : 0});
          }
        },
      );
      return _database;
    } catch (_) {
      return null;
    }
  }

  Future<UserModel?> getUser(String username) async {
    _seedAllData();
    if (!kIsWeb) {
      try {
        final db = await database;
        if (db != null) {
          final maps = await db.query('users', where: 'username = ?', whereArgs: [username]);
          if (maps.isNotEmpty) {
            final m = maps.first;
            return UserModel(
              username: m['username'] as String,
              passwordHash: m['passwordHash'] as String,
              role: m['role'] as String,
              displayName: m['displayName'] as String,
              securityQuestion: m['securityQuestion'] as String?,
              securityAnswer: m['securityAnswer'] as String?,
            );
          }
        }
      } catch (_) {}
    }
    return _memoryUsers[username];
  }

  Future<Map<String, dynamic>?> getUserSecurityDetails(String username) async {
    _seedAllData();
    if (!kIsWeb) {
      try {
        final db = await database;
        if (db != null) {
          final maps = await db.query('users', where: 'username = ?', whereArgs: [username]);
          if (maps.isNotEmpty) return maps.first;
        }
      } catch (_) {}
    }
    final u = _memoryUsers[username];
    return u != null ? {'username': u.username, 'securityAnswer': u.securityAnswer} : null;
  }

  Future<void> updateUserPasswordAndSecurity({
    required String username,
    required String newPassword,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    _seedAllData();
    final u = _memoryUsers[username];
    if (u != null) {
      _memoryUsers[username] = UserModel(
        username: u.username,
        passwordHash: newPassword,
        role: u.role,
        displayName: u.displayName,
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer.toLowerCase().trim(),
      );
    }
    if (!kIsWeb) {
      try {
        final db = await database;
        await db?.update('users', {
          'passwordHash': newPassword,
          'securityQuestion': securityQuestion,
          'securityAnswer': securityAnswer.toLowerCase().trim(),
        }, where: 'username = ?', whereArgs: [username]);
      } catch (_) {}
    }
  }

  Future<void> updateUserPassword(String username, String newPassword) async {
    _seedAllData();
    final u = _memoryUsers[username];
    if (u != null) {
      _memoryUsers[username] = UserModel(
        username: u.username,
        passwordHash: newPassword,
        role: u.role,
        displayName: u.displayName,
        securityQuestion: u.securityQuestion,
        securityAnswer: u.securityAnswer,
      );
    }
    if (!kIsWeb) {
      try {
        final db = await database;
        await db?.update('users', {'passwordHash': newPassword}, where: 'username = ?', whereArgs: [username]);
      } catch (_) {}
    }
  }

  Future<StudentModel?> getStudent(String rollNo) async {
    _seedAllData();
    if (!kIsWeb) {
      try {
        final db = await database;
        if (db != null) {
          final maps = await db.query('students', where: 'rollNo = ?', whereArgs: [rollNo]);
          if (maps.isNotEmpty) {
            final m = maps.first;
            return StudentModel(
              rollNo: m['rollNo'] as String,
              name: m['name'] as String,
              course: m['course'] as String,
              semester: m['semester'] as String,
              gpa: (m['gpa'] as num).toDouble(),
              attendance: (m['attendance'] as num).toDouble(),
              scoresJson: m['scoresJson'] as String,
              assignmentsJson: m['assignmentsJson'] as String,
            );
          }
        }
      } catch (_) {}
    }
    return _memoryStudents[rollNo];
  }

  Future<List<StudentModel>> getAllStudents() async {
    _seedAllData();
    if (!kIsWeb) {
      try {
        final db = await database;
        if (db != null) {
          final maps = await db.query('students');
          if (maps.isNotEmpty) {
            return maps.map((m) => StudentModel(
              rollNo: m['rollNo'] as String,
              name: m['name'] as String,
              course: m['course'] as String,
              semester: m['semester'] as String,
              gpa: (m['gpa'] as num).toDouble(),
              attendance: (m['attendance'] as num).toDouble(),
              scoresJson: m['scoresJson'] as String,
              assignmentsJson: m['assignmentsJson'] as String,
            )).toList();
          }
        }
      } catch (_) {}
    }
    return _memoryStudents.values.toList();
  }

  Future<void> updateStudent(StudentModel s) async {
    _seedAllData();
    _memoryStudents[s.rollNo] = s;
    if (!kIsWeb) {
      try {
        final db = await database;
        await db?.update('students', {
          'name': s.name,
          'course': s.course,
          'semester': s.semester,
          'gpa': s.gpa,
          'attendance': s.attendance,
          'scoresJson': s.scoresJson,
          'assignmentsJson': s.assignmentsJson,
        }, where: 'rollNo = ?', whereArgs: [s.rollNo]);
      } catch (_) {}
    }
  }

  Future<List<TimetableModel>> getTimetable() async {
    _seedAllData();
    if (!kIsWeb) {
      try {
        final db = await database;
        if (db != null) {
          final maps = await db.query('timetable');
          if (maps.isNotEmpty) {
            return maps.map((m) => TimetableModel(
              id: m['id'] as int,
              course: (m['course'] ?? 'MCA') as String,
              subject: m['subject'] as String,
              timeSlot: m['timeSlot'] as String,
              dayOfWeek: m['dayOfWeek'] as String,
              roomNumber: m['roomNumber'] as String,
              assignedTeacher: m['assignedTeacher'] as String,
            )).toList();
          }
        }
      } catch (_) {}
    }
    return _memoryTimetable;
  }

  Future<List<ReminderModel>> getReminders(String teacherId) async {
    _seedAllData();
    if (!kIsWeb) {
      try {
        final db = await database;
        if (db != null) {
          final maps = await db.query('reminders', where: 'teacherId = ?', whereArgs: [teacherId]);
          if (maps.isNotEmpty) {
            return maps.map((m) => ReminderModel(
              id: m['id'] as int,
              teacherId: m['teacherId'] as String,
              subject: m['subject'] as String,
              timeSlot: m['timeSlot'] as String,
              minutesBefore: m['minutesBefore'] as int,
              isEnabled: (m['isEnabled'] as int) == 1,
            )).toList();
          }
        }
      } catch (_) {}
    }
    return _memoryReminders.where((r) => r.teacherId == teacherId).toList();
  }

  Future<void> insertStudent(StudentModel s) async {
    _seedAllData();
    _memoryStudents[s.rollNo] = s;
    _memoryUsers[s.rollNo] = UserModel(
      username: s.rollNo,
      passwordHash: 'student123',
      role: 'STUDENT',
      displayName: s.name,
      securityQuestion: 'What is your favorite color?',
      securityAnswer: 'blue',
    );
    if (!kIsWeb) {
      try {
        final db = await database;
        await db?.insert('students', {
          'rollNo': s.rollNo,
          'name': s.name,
          'course': s.course,
          'semester': s.semester,
          'gpa': s.gpa,
          'attendance': s.attendance,
          'scoresJson': s.scoresJson,
          'assignmentsJson': s.assignmentsJson,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      } catch (_) {}
    }
  }

  Future<void> insertTeacher(TeacherModel t) async {
    _seedAllData();
    _memoryUsers[t.teacherId] = UserModel(
      username: t.teacherId,
      passwordHash: 'teacher123',
      role: 'TEACHER',
      displayName: t.name,
      securityQuestion: 'What is your favorite color?',
      securityAnswer: 'blue',
    );
  }

  Future<void> insertTimetable(TimetableModel t) async {
    _seedAllData();
    _memoryTimetable.add(t);
  }

  Future<void> insertReminder(ReminderModel r) async {
    _seedAllData();
    _memoryReminders.add(r);
  }

  Future<void> toggleReminder(int id, bool isEnabled) async {
    _seedAllData();
    for (var r in _memoryReminders) {
      if (r.id == id) {
        r.isEnabled = isEnabled;
        break;
      }
    }
  }

  Future<void> resetDatabaseDefaults() async {
    _isSeeded = false;
    _memoryUsers.clear();
    _memoryStudents.clear();
    _memoryTimetable.clear();
    _memoryReminders.clear();
    _seedAllData();
  }
}