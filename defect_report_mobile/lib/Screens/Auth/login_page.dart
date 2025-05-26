import 'package:defect_report_mobile/Screens/Auth/register_page.dart';
import 'package:defect_report_mobile/Screens/Widget/auth_input.dart';
import 'package:defect_report_mobile/Screens/nav.dart';
import 'package:defect_report_mobile/Services/api_services.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _showPassword = false;

  bool loading = false;
  String? error;

  void login() async {
    setState(() {
      loading = true;
      error = null;
    });

    final result = await ApiServices.login(emailCtrl.text, passCtrl.text);

    setState(() => loading = false);
    if (!mounted) return;
    if (result == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Nav()),
      );
    } else {
      setState(() => error = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 80),
              const SizedBox(height: 12),
              const Text(
                'Welcome Back!',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailCtrl,
                decoration: buildAuthInputDecoration('Email', Icons.person),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                obscureText: !_showPassword,
                decoration:
                    buildAuthInputDecoration('Password', Icons.lock).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
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
                  const Text("Don't have account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage()),
                      );
                    },
                    child: const Text(
                      'Register',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
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
                  onPressed: loading ? null : login,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login',
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
