import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sms_provider.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedTab = 0;
  final _searchController = TextEditingController();
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleStudentSearch(SmsProvider provider) async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid Roll Number!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _hasSearched = true);
    await provider.searchStudentByRollNo(query);

    if (mounted && provider.lookupStudent == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text("Student Not Found", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            ],
          ),
          content: Text(
            "No record matches Roll Number '$query'.\nPlease verify and try again.",
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6750A4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SmsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(provider.currentUser?.displayName ?? "Faculty Portal", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Text("Faculty Portal", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.exit_to_app), onPressed: () => provider.logout()),
        ],
      ),
      body: _selectedTab == 0 ? _buildAlertsTab(provider) : _buildLookupTab(provider),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (i) => setState(() => _selectedTab = i),
        selectedItemColor: const Color(0xFF6750A4),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Lookup'),
        ],
      ),
    );
  }

  Widget _buildAlertsTab(SmsProvider provider) {
    final reminders = provider.teacherReminders;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome back, Professor!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 4),
                  Text("Manage lectures & period alerts in real-time.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("My Period Reminders", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add_alarm, color: Color(0xFF6750A4)),
                onPressed: () => _showAddReminderDialog(context, provider),
              ),
            ],
          ),
          if (reminders.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(child: Text("No period reminders scheduled.")),
            ),
          ...reminders.map((r) => Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (r.isEnabled ? const Color(0xFF6750A4) : Colors.grey).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.access_time_rounded, color: r.isEnabled ? const Color(0xFF6750A4) : Colors.grey),
              ),
              title: Text(r.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text("Alert ${r.minutesBefore}m before • ${r.timeSlot}"),
              trailing: Switch(
                value: r.isEnabled,
                activeColor: const Color(0xFF6750A4),
                onChanged: (_) => provider.toggleReminder(r),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLookupTab(SmsProvider provider) {
    final student = provider.lookupStudent;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _handleStudentSearch(provider),
                  decoration: InputDecoration(
                    labelText: "Enter Student Roll No (e.g., S101)",
                    prefixIcon: const Icon(Icons.badge_outlined),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _hasSearched = false;
                        });
                        provider.searchStudentByRollNo("");
                      },
                    )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6750A4),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _handleStudentSearch(provider),
                child: const Icon(Icons.search, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1. Agar Student Mil Gaya Toh:
          if (student != null)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(student.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6750A4).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(student.rollNo, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6750A4))),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text("Course: ${student.course}", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text("Semester: ${student.semester}", style: const TextStyle(color: Colors.black54, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text("GPA Standing: ${student.gpa.toStringAsFixed(2)} / 4.00", style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text("Attendance: ${student.attendance.toStringAsFixed(1)}%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: student.attendance >= 75 ? Colors.green : Colors.red)),
                    const SizedBox(height: 12),
                    const Text("Scores:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(student.scoresJson, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                  ],
                ),
              ),
            ),

          // 2. Agar Search Kiya Par Student Nahi Mila:
          if (_hasSearched && student == null)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                children: [
                  const Icon(Icons.person_off_rounded, color: Colors.red, size: 48),
                  const SizedBox(height: 10),
                  Text(
                    "Student Not Found!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "No student found with Roll Number '${_searchController.text.trim()}'. Please check the roll number.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context, SmsProvider provider) {
    final subCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Add Period Reminder", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: subCtrl, decoration: const InputDecoration(labelText: "Subject / Lecture")),
            TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: "Time Slot (e.g., 07:30 AM)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6750A4)),
            onPressed: () {
              if (subCtrl.text.isNotEmpty) {
                provider.addReminder(subCtrl.text, timeCtrl.text, 10);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}