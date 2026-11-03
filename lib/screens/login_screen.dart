import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sms_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  String _selectedRole = 'STUDENT';
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _customError;

  final List<String> securityQuestions = [
    'What is your favorite color?',
    'What is your first school name?',
    'What is your college department name?',
    'What is your favorite subject?',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String _getFieldLabel(String role) {
    switch (role) {
      case 'STUDENT':
        return 'Roll Number';
      case 'TEACHER':
        return 'Faculty ID';
      case 'MANAGEMENT':
        return 'Admin Username';
      default:
        return 'User ID';
    }
  }

  String _getFieldHint(String role) {
    switch (role) {
      case 'STUDENT':
        return 'e.g., S101 to S105';
      case 'TEACHER':
        return 'e.g., T201 (Ms. Manali Panchal)';
      case 'MANAGEMENT':
        return 'e.g., admin';
      default:
        return '';
    }
  }

  String _getRoleDefaultError(String role) {
    switch (role) {
      case 'MANAGEMENT':
        return 'Admin profile not found or invalid. Default: admin / admin123';
      case 'TEACHER':
        return 'Faculty profile not found. Default: T201 / teacher123';
      case 'STUDENT':
      default:
        return 'Student profile not found. Default: S101 / student123';
    }
  }

  Future<void> _handleSignIn(SmsProvider provider) async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _customError = 'Please enter both ID and Password!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _customError = null;
    });

    // Case insensitive username pass karne se 'Admin' input par bhi login match hoga
    final normalizedUsername = _selectedRole == 'MANAGEMENT' ? username.toLowerCase() : username;

    final success = await provider.login(
      normalizedUsername,
      password,
      _selectedRole,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (!success) {
          // Provider ka message check karke role-specific message prioritize karein
          final provMsg = provider.loginError;
          if (provMsg != null && !provMsg.contains("Default: S101")) {
            _customError = provMsg;
          } else {
            _customError = _getRoleDefaultError(_selectedRole);
          }
        }
      });

      if (!success) {
        // Error aane ke baad password focus ready rahega
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SmsProvider>(context);
    final displayedError = _customError ?? provider.loginError;

    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school_rounded, size: 72, color: Color(0xFF6750A4)),
                const SizedBox(height: 16),
                const Text(
                  'College Portal',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1D1B20)),
                ),
                const Text(
                  'Secured Institutional Gateway',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PORTAL ROLE',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 0.8),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6750A4).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              {'role': 'STUDENT', 'label': 'Student'},
                              {'role': 'TEACHER', 'label': 'Faculty'},
                              {'role': 'MANAGEMENT', 'label': 'Admin'},
                            ].map((item) {
                              final role = item['role']!;
                              final label = item['label']!;
                              final isSelected = _selectedRole == role;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedRole = role;
                                      _customError = null;
                                      _usernameController.clear();
                                      _passwordController.clear();
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF6750A4) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextField(
                          controller: _usernameController,
                          focusNode: _usernameFocusNode,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {
                            if (_customError != null) setState(() => _customError = null);
                          },
                          onSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_passwordFocusNode);
                          },
                          decoration: InputDecoration(
                            labelText: '${_getFieldLabel(_selectedRole)} (${_getFieldHint(_selectedRole)})',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          textInputAction: TextInputAction.done,
                          obscureText: !_isPasswordVisible,
                          keyboardType: TextInputType.text,
                          onChanged: (_) {
                            if (_customError != null) setState(() => _customError = null);
                          },
                          onSubmitted: (_) => _handleSignIn(provider),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => _showChangePasswordDialog(context, provider),
                              child: const Text("Change Password", style: TextStyle(color: Color(0xFF6750A4), fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            TextButton(
                              onPressed: () => _showForgotPasswordDialog(context, provider),
                              child: const Text("Forgot Password?", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6750A4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _isLoading ? null : () => _handleSignIn(provider),
                            child: _isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : const Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),

                        if (displayedError != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    displayedError,
                                    style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Card(
                  color: Colors.purple.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Quick Access Credentials', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        SizedBox(height: 6),
                        Text(
                          'Student: S101 to S105 | Pass: student123\nFaculty: T201 (Ms. Manali Panchal) | Pass: teacher123\nAdmin: admin | Pass: admin123\n(Security Answer for all: blue)',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, SmsProvider provider) {
    final userCtrl = TextEditingController(text: _usernameController.text);
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    String selectedQuestion = securityQuestions.first;
    final answerCtrl = TextEditingController();
    String? dialogError;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.key, color: Color(0xFF6750A4)),
                  SizedBox(width: 8),
                  Text("Update Default Password", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: userCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(labelText: _getFieldLabel(_selectedRole), border: const OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: oldPassCtrl,
                      textInputAction: TextInputAction.next,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Old Password", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newPassCtrl,
                      textInputAction: TextInputAction.next,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "New Password", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmPassCtrl,
                      textInputAction: TextInputAction.next,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Confirm New Password", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Security Question for Recovery", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF6750A4))),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedQuestion,
                      isExpanded: true,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: securityQuestions.map((q) => DropdownMenuItem(value: q, child: Text(q, style: const TextStyle(fontSize: 11)))).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedQuestion = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: answerCtrl,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(labelText: "Security Answer", border: OutlineInputBorder()),
                    ),
                    if (dialogError != null) ...[
                      const SizedBox(height: 12),
                      Text(dialogError!, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6750A4)),
                  onPressed: () async {
                    final username = userCtrl.text.trim();
                    final oldPass = oldPassCtrl.text.trim();
                    final newPass = newPassCtrl.text.trim();
                    final confirmPass = confirmPassCtrl.text.trim();
                    final answer = answerCtrl.text.trim();

                    if (username.isEmpty || oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty || answer.isEmpty) {
                      setDialogState(() => dialogError = "All fields are required!");
                      return;
                    }
                    if (newPass != confirmPass) {
                      setDialogState(() => dialogError = "New Password and Confirm Password do not match!");
                      return;
                    }
                    if (newPass.length < 6) {
                      setDialogState(() => dialogError = "New Password must be at least 6 characters!");
                      return;
                    }

                    final res = await provider.changePasswordAndSetupSecurity(
                      username: username,
                      oldPassword: oldPass,
                      newPassword: newPass,
                      securityQuestion: selectedQuestion,
                      securityAnswer: answer,
                    );

                    if (res['success'] == true) {
                      Navigator.pop(ctx);
                      _usernameController.text = username;
                      _passwordController.text = newPass;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Password updated successfully!")),
                      );
                    } else {
                      setDialogState(() => dialogError = res['message']);
                    }
                  },
                  child: const Text("Save & Update", style: TextStyle(color: Colors.white)),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _showForgotPasswordDialog(BuildContext context, SmsProvider provider) {
    final rollCtrl = TextEditingController(text: _usernameController.text);
    final answerCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    String? resetError;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.lock_reset, color: Color(0xFF6750A4)),
                  SizedBox(width: 8),
                  Text("Password Recovery", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: rollCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(labelText: _getFieldLabel(_selectedRole), border: const OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: answerCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: "Security Answer", hintText: "e.g., blue", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newPassCtrl,
                      textInputAction: TextInputAction.next,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "New Password", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmPassCtrl,
                      textInputAction: TextInputAction.done,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Confirm New Password", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: const Text(
                        "Forgot Security Answer too? Contact Management/Admin Office for manual reset.",
                        style: TextStyle(fontSize: 11, color: Colors.black87),
                      ),
                    ),
                    if (resetError != null) ...[
                      const SizedBox(height: 12),
                      Text(resetError!, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6750A4)),
                  onPressed: () async {
                    final username = rollCtrl.text.trim();
                    final answer = answerCtrl.text.trim();
                    final newPass = newPassCtrl.text.trim();
                    final confirmPass = confirmPassCtrl.text.trim();

                    if (username.isEmpty || answer.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                      setDialogState(() => resetError = "All fields are required!");
                      return;
                    }
                    if (newPass != confirmPass) {
                      setDialogState(() => resetError = "New Password and Confirm Password do not match!");
                      return;
                    }

                    final result = await provider.verifyAndResetPassword(
                      username: username,
                      securityAnswer: answer,
                      newPassword: newPass,
                    );

                    if (result['success'] == true) {
                      Navigator.pop(ctx);
                      _usernameController.text = username;
                      _passwordController.text = newPass;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Password reset successfully! You can now Sign In.")),
                      );
                    } else {
                      setDialogState(() => resetError = result['message']);
                    }
                  },
                  child: const Text("Reset Password", style: TextStyle(color: Colors.white)),
                )
              ],
            );
          },
        );
      },
    );
  }
}