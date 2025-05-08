import 'package:defect_report_mobile/Screens/Auth/login_page.dart';
import 'package:defect_report_mobile/Screens/Widget/auth_input.dart';
import 'package:defect_report_mobile/Services/api_services.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final retypeCtrl = TextEditingController();
  bool _showPassword = false;
  bool _showRePassword = false;

  String selectedRole = '';
  final roles = ['Admin', 'QC'];

  bool loading = false;
  String? error;

  void register() async {
    setState(() {
      loading = true;
      error = null;
    });

    if (selectedRole.isEmpty) {
      setState(() {
        loading = false;
        error = 'Please select a role.';
      });
      return;
    }

    if (passCtrl.text != retypeCtrl.text) {
      setState(() {
        loading = false;
        error = 'Passwords do not match.';
      });
      return;
    }

    final result = await ApiServices.register(nameCtrl.text, emailCtrl.text,
        selectedRole, passCtrl.text, retypeCtrl.text);

    setState(() => loading = false);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Please login.')),
      );
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      setState(() => error = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Text(
                'Register',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameCtrl,
                decoration:
                    buildAuthInputDecoration('Name', Icons.person_2_outlined),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration:
                    buildAuthInputDecoration('Email', Icons.email_outlined),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole.isEmpty ? null : selectedRole,
                decoration:
                    buildAuthInputDecoration('Role', Icons.badge_outlined),
                items: roles.map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (value) =>
                    setState(() => selectedRole = value ?? ''),
              ),
              const SizedBox(height: 12),
              TextField(
                  controller: passCtrl,
                  obscureText: !_showPassword,
                  decoration:
                      buildAuthInputDecoration('Password', Icons.lock_outline)
                          .copyWith(
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        )),
                  )),
              const SizedBox(height: 12),
              TextField(
                controller: retypeCtrl,
                obscureText: !_showRePassword,
                decoration:
                    buildAuthInputDecoration('Re-type Password', Icons.lock)
                        .copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showRePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _showRePassword = !_showRePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (error != null)
                Text(error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: loading ? null : register,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Register',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
