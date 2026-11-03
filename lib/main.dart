import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/sms_provider.dart';
import 'screens/login_screen.dart';
import 'screens/student_dashboard.dart';
import 'screens/teacher_dashboard.dart';
import 'screens/management_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => SmsProvider(),
      child: const StudentManagementApp(),
    ),
  );
}

class StudentManagementApp extends StatelessWidget {
  const StudentManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College SMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      ),
      home: const MainAppNavRouter(),
    );
  }
}

class MainAppNavRouter extends StatelessWidget {
  const MainAppNavRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SmsProvider>(context);
    final user = provider.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    switch (user.role) {
      case 'STUDENT':
        return const StudentDashboard();
      case 'TEACHER':
        return const TeacherDashboard();
      case 'MANAGEMENT':
        return const ManagementDashboard();
      default:
        return const LoginScreen();
    }
  }
}