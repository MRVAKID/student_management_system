import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sms_provider.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedTab = 0;
  String _selectedDay = "Monday";

  final List<String> _weekDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SmsProvider>(context);
    final student = provider.studentProfile;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student?.name ?? "Student Dashboard",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
            ),
            Text(
              student?.rollNo ?? "",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.black),
            onPressed: () => provider.logout(),
          )
        ],
      ),
      body: _selectedTab == 0 ? _buildBentoOverview(student) : _buildTimetable(provider),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) => setState(() => _selectedTab = index),
        selectedItemColor: const Color(0xFF6750A4),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Timetable'),
        ],
      ),
    );
  }

  Widget _buildBentoOverview(student) {
    if (student == null) {
      return const Center(child: Text("No Student profile details found."));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            color: const Color(0xFFEADDFF),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Semester Overview",
                          style: TextStyle(color: Color(0xFF6750A4), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(student.course, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        Text(student.semester, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Color(0xFF6750A4),
                    child: Icon(Icons.school, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Card(
                  color: const Color(0xFF6750A4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("GPA Standing", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(
                          student.gpa.toStringAsFixed(2),
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        const Text("Out of 4.00", style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showAttendanceCalculator(context, student.attendance),
                  child: Card(
                    color: const Color(0xFFE8DEF8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text("Attendance", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 50,
                                width: 50,
                                child: CircularProgressIndicator(
                                  value: student.attendance / 100.0,
                                  strokeWidth: 6,
                                  color: student.attendance >= 75 ? Colors.green : Colors.red,
                                ),
                              ),
                              Text("${student.attendance.toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFF6750A4), borderRadius: BorderRadius.circular(10)),
                            child: const Text("Calculator 🧮", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Academic Scores", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Text("Recent Subject Performance", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 12),
                  ...student.scoresJson.split(',').map((item) {
                    final parts = item.split(':');
                    if (parts.length != 2) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(parts[0].trim(), style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
                          Chip(label: Text(parts[1].trim(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetable(SmsProvider provider) {
    final student = provider.studentProfile;

    // Student ke course se matching course key nikalna
    String studentCourseKey = 'MCA';
    final courseStr = (student?.course ?? '').toUpperCase();
    if (courseStr.contains('MBA')) {
      studentCourseKey = 'MBA';
    } else if (courseStr.contains('MSC') || courseStr.contains('IT')) {
      studentCourseKey = 'MSCIT';
    } else if (courseStr.contains('M.COM') || courseStr.contains('COMMERCE')) {
      studentCourseKey = 'MCOM';
    } else if (courseStr.contains('B.TECH') || courseStr.contains('CSE')) {
      studentCourseKey = 'BTECH';
    }

    // Selected Day aur Student Course dono filter
    final daySlots = provider.timetable.where((t) {
      final isDayMatched = t.dayOfWeek.toLowerCase() == _selectedDay.toLowerCase();
      final isCourseMatched = t.course.toUpperCase() == studentCourseKey;
      return isDayMatched && isCourseMatched;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: _weekDays.map((day) {
              final isSelected = _selectedDay == day;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(day),
                  selected: isSelected,
                  selectedColor: const Color(0xFF6750A4),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedDay = day);
                  },
                ),
              );
            }).toList(),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$_selectedDay • $studentCourseKey Schedule",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1D1B20)),
              ),
              Text(
                "${daySlots.length} Classes",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF6750A4)),
              ),
            ],
          ),
        ),

        Expanded(
          child: daySlots.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 54, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                Text("No classes scheduled for $_selectedDay", style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: daySlots.length,
            itemBuilder: (ctx, i) {
              final slot = daySlots[i];
              return Card(
                elevation: 1.5,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6750A4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: Color(0xFF6750A4)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slot.subject,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Faculty: ${slot.assignedTeacher}",
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.meeting_room_outlined, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  "Room: ${slot.roomNumber}",
                                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEADDFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          slot.timeSlot,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6750A4),
                            fontSize: 10.5,
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
    );
  }

  void _showAttendanceCalculator(BuildContext context, double currentAtt) {
    final totalLecturesCtrl = TextEditingController(text: "40");
    final attendedLecturesCtrl = TextEditingController(text: (40 * (currentAtt / 100)).toInt().toString());
    final targetCtrl = TextEditingController(text: "75");

    String resultText = "";

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.calculate, color: Color(0xFF6750A4)),
                  SizedBox(width: 8),
                  Text("Attendance Goal Calculator", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: totalLecturesCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Total Conducted Lectures"),
                    ),
                    TextField(
                      controller: attendedLecturesCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Attended Lectures"),
                    ),
                    TextField(
                      controller: targetCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Target Attendance % (e.g. 75)"),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6750A4)),
                      onPressed: () {
                        final total = double.tryParse(totalLecturesCtrl.text) ?? 0;
                        final attended = double.tryParse(attendedLecturesCtrl.text) ?? 0;
                        final target = double.tryParse(targetCtrl.text) ?? 75;

                        if (total > 0 && attended <= total) {
                          final currentPct = (attended / total) * 100;
                          if (currentPct >= target) {
                            int safeBunks = 0;
                            while (((attended) / (total + safeBunks + 1)) * 100 >= target) {
                              safeBunks++;
                            }
                            setDialogState(() {
                              resultText = "Current: ${currentPct.toStringAsFixed(1)}%\n🎉 You can safely bunk $safeBunks upcoming lectures and remain above $target%!";
                            });
                          } else {
                            int needed = 0;
                            while (((attended + needed) / (total + needed)) * 100 < target) {
                              needed++;
                            }
                            setDialogState(() {
                              resultText = "Current: ${currentPct.toStringAsFixed(1)}%\n⚠️ You must attend the next $needed lectures continuously to reach $target%!";
                            });
                          }
                        }
                      },
                      child: const Text("Calculate Status", style: TextStyle(color: Colors.white)),
                    ),
                    if (resultText.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(12)),
                        child: Text(resultText, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF6750A4))),
                      ),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
              ],
            );
          },
        );
      },
    );
  }
}