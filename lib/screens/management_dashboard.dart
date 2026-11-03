import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sms_models.dart';
import '../providers/sms_provider.dart';

class ManagementDashboard extends StatefulWidget {
  const ManagementDashboard({super.key});

  @override
  State<ManagementDashboard> createState() => _ManagementDashboardState();
}

class _ManagementDashboardState extends State<ManagementDashboard> {
  int _selectedTab = 0;
  int _manualFormType = 0;

  final _csvController = TextEditingController();
  final _searchController = TextEditingController();

  final _rollController = TextEditingController();
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();
  final _semController = TextEditingController(text: 'Semester 1');
  final _gpaController = TextEditingController();
  final _attController = TextEditingController();
  final _scoresController = TextEditingController();
  final _assignController = TextEditingController();

  final _teacherIdController = TextEditingController();
  final _teacherNameController = TextEditingController();
  final _teacherSubController = TextEditingController();
  final _teacherContactController = TextEditingController();

  final _ttSubController = TextEditingController();
  final _ttCourseController = TextEditingController(); // Added course controller
  final _ttTimeController = TextEditingController();
  final _ttDayController = TextEditingController(text: 'Monday');
  final _ttRoomController = TextEditingController();
  final _ttTeacherController = TextEditingController();

  bool _isSuccessMessageVisible = false;

  final sampleTemplate =
      "S106, Michael Scott, Business Adm., Semester 3, 3.12, 82.5, Sales: A Management: B+\n"
      "S107, Dwight Schrute, Agriculture, Semester 5, 4.00, 99.8, Farming: A Paper Sales: A+";

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SmsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("College Management", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text("Admin Administration Portal", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.exit_to_app), onPressed: () => provider.logout()),
        ],
      ),
      body: _selectedTab == 0
          ? _buildIngestionView(provider)
          : _selectedTab == 1
          ? _buildManualEntryView(provider)
          : _selectedTab == 2
          ? _buildSearchAndEditView(provider)
          : _buildDatabaseAdminView(provider),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        selectedItemColor: const Color(0xFF6750A4),
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _selectedTab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.cloud_upload), label: 'Ingestion'),
          BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Manual'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search & Edit'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Database'),
        ],
      ),
    );
  }

  Widget _buildIngestionView(SmsProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: const Color(0xFFEADDFF),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Bulk Ingestion Tool", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 4),
                  Text("Parse academic transcripts and registrations instantly.", style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _csvController.text = sampleTemplate,
            child: const Text("Load Sample Template Sheet"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _csvController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: "Paste CSV or spreadsheet rows here...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6750A4)),
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: const Text("Parse & Commit to Database", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () => provider.parseAndIngestCSV(_csvController.text),
            ),
          ),
          if (provider.ingestionMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              provider.ingestionMessage!,
              style: TextStyle(color: provider.ingestionSuccess ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildManualEntryView(SmsProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Manual Registration Flow", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF1E293B))),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: ['Student', 'Faculty', 'Schedule'].asMap().entries.map((entry) {
                final idx = entry.key;
                final label = entry.value;
                final isSelected = _manualFormType == idx;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _manualFormType = idx;
                      _isSuccessMessageVisible = false;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF6750A4) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        label,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          if (_manualFormType == 0) ...[
            TextField(controller: _rollController, decoration: InputDecoration(labelText: "Roll Number (e.g. S106)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: "Full Student Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: _courseController, decoration: InputDecoration(labelText: "Course", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: _semController, decoration: InputDecoration(labelText: "Semester", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: _gpaController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "GPA (0.0 to 4.0)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: _attController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Attendance %", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: _scoresController, decoration: InputDecoration(labelText: "Scores", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: _assignController, decoration: InputDecoration(labelText: "Assignments", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6750A4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  if (_rollController.text.isNotEmpty && _nameController.text.isNotEmpty) {
                    provider.addManualStudent(StudentModel(
                      rollNo: _rollController.text.trim(),
                      name: _nameController.text.trim(),
                      course: _courseController.text.trim(),
                      semester: _semController.text.trim(),
                      gpa: double.tryParse(_gpaController.text) ?? 0.0,
                      attendance: double.tryParse(_attController.text) ?? 0.0,
                      scoresJson: _scoresController.text.trim(),
                      assignmentsJson: _assignController.text.trim(),
                    ));
                    setState(() => _isSuccessMessageVisible = true);
                    _rollController.clear(); _nameController.clear(); _courseController.clear(); _gpaController.clear(); _attController.clear(); _scoresController.clear(); _assignController.clear();
                  }
                },
                child: const Text("Register Student Record", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ] else if (_manualFormType == 1) ...[
            TextField(controller: _teacherIdController, decoration: InputDecoration(labelText: "Faculty ID (e.g. T203)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: _teacherNameController, decoration: InputDecoration(labelText: "Faculty Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: _teacherSubController, decoration: InputDecoration(labelText: "Department", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: _teacherContactController, decoration: InputDecoration(labelText: "Email Address", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6750A4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  if (_teacherIdController.text.isNotEmpty && _teacherNameController.text.isNotEmpty) {
                    provider.addManualTeacher(TeacherModel(
                      teacherId: _teacherIdController.text.trim(),
                      name: _teacherNameController.text.trim(),
                      subject: _teacherSubController.text.trim(),
                      contact: _teacherContactController.text.trim(),
                    ));
                    setState(() => _isSuccessMessageVisible = true);
                    _teacherIdController.clear(); _teacherNameController.clear(); _teacherSubController.clear(); _teacherContactController.clear();
                  }
                },
                child: const Text("Register Faculty Member", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ] else ...[
            TextField(controller: _ttSubController, decoration: InputDecoration(labelText: "Lecture Subject", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: _ttCourseController, decoration: InputDecoration(labelText: "Course (e.g. MCA, B.Tech)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: _ttTimeController, decoration: InputDecoration(labelText: "Timing", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: _ttDayController, decoration: InputDecoration(labelText: "Day of Week", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: _ttRoomController, decoration: InputDecoration(labelText: "Room / Lab", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: _ttTeacherController, decoration: InputDecoration(labelText: "Professor Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6750A4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  if (_ttSubController.text.isNotEmpty && _ttTimeController.text.isNotEmpty) {
                    provider.addTimetableSlot(TimetableModel(
                      id: DateTime.now().millisecondsSinceEpoch,
                      course: _ttCourseController.text.trim().isNotEmpty ? _ttCourseController.text.trim() : 'General',
                      subject: _ttSubController.text.trim(),
                      timeSlot: _ttTimeController.text.trim(),
                      dayOfWeek: _ttDayController.text.trim(),
                      roomNumber: _ttRoomController.text.trim(),
                      assignedTeacher: _ttTeacherController.text.trim(),
                    ));
                    setState(() => _isSuccessMessageVisible = true);
                    _ttSubController.clear(); _ttCourseController.clear(); _ttTimeController.clear(); _ttRoomController.clear(); _ttTeacherController.clear();
                  }
                },
                child: const Text("Append Schedule Slot", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],

          if (_isSuccessMessageVisible) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(child: Text("Registration saved to SQLite Database!", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSearchAndEditView(SmsProvider provider) {
    final query = _searchController.text.toLowerCase();
    final filteredStudents = provider.allStudents.where((s) {
      return s.name.toLowerCase().contains(query) || s.rollNo.toLowerCase().contains(query) || s.course.toLowerCase().contains(query);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              labelText: "Search Student Record...",
              prefixIcon: const Icon(Icons.search, color: Color(0xFF6750A4)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _searchController.clear()),
              )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Enrolled Records: ${filteredStudents.length}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filteredStudents.isEmpty
                ? const Center(child: Text("No student records found."))
                : ListView.builder(
              itemCount: filteredStudents.length,
              itemBuilder: (ctx, i) {
                final student = filteredStudents[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Roll: ${student.rollNo} • GPA: ${student.gpa.toStringAsFixed(2)} • Att: ${student.attendance}%"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.vpn_key, color: Colors.amber),
                          tooltip: "Reset Password",
                          onPressed: () => _showResetPasswordDialog(context, provider, student.rollNo, student.name),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF6750A4)),
                          tooltip: "Edit Profile",
                          onPressed: () => _showEditStudentDialog(context, provider, student),
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
    );
  }

  void _showResetPasswordDialog(BuildContext context, SmsProvider provider, String rollNo, String name) {
    final pwdCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Change Password for $name ($rollNo)", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: pwdCtrl,
          decoration: const InputDecoration(labelText: "Enter New Password", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6750A4)),
            onPressed: () async {
              if (pwdCtrl.text.trim().isNotEmpty) {
                await provider.updateUserPassword(rollNo, pwdCtrl.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Password updated for $rollNo successfully!")),
                );
              }
            },
            child: const Text("Update Password", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showEditStudentDialog(BuildContext context, SmsProvider provider, StudentModel student) {
    final nameCtrl = TextEditingController(text: student.name);
    final courseCtrl = TextEditingController(text: student.course);
    final semCtrl = TextEditingController(text: student.semester);
    final gpaCtrl = TextEditingController(text: student.gpa.toString());
    final attCtrl = TextEditingController(text: student.attendance.toString());
    final scoresCtrl = TextEditingController(text: student.scoresJson);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Edit Record: ${student.rollNo}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Student Name")),
              TextField(controller: courseCtrl, decoration: const InputDecoration(labelText: "Course")),
              TextField(controller: semCtrl, decoration: const InputDecoration(labelText: "Semester")),
              TextField(controller: gpaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "GPA")),
              TextField(controller: attCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Attendance %")),
              TextField(controller: scoresCtrl, decoration: const InputDecoration(labelText: "Scores")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6750A4)),
            onPressed: () {
              provider.updateStudentDetails(StudentModel(
                rollNo: student.rollNo,
                name: nameCtrl.text.trim(),
                course: courseCtrl.text.trim(),
                semester: semCtrl.text.trim(),
                gpa: double.tryParse(gpaCtrl.text) ?? student.gpa,
                attendance: double.tryParse(attCtrl.text) ?? student.attendance,
                scoresJson: scoresCtrl.text.trim(),
                assignmentsJson: student.assignmentsJson,
              ));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Student record updated successfully!")),
              );
            },
            child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildDatabaseAdminView(SmsProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            color: Colors.red.shade100,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text("Database Administration Zone", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => provider.resetDatabaseDefaults(),
                    child: const Text("Restore Database Defaults", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}