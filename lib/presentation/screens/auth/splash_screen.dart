import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskflow/presentation/screens/home/homescreen.dart';

import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    final authProvider = context.read<AuthProvider>();

    await authProvider.checkSession();

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF6F3FC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TaskFlow Logo
            _SplashLogo(),

            SizedBox(height: 24),

            Text(
              'TaskFlow',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFF241B2F),
                letterSpacing: -0.5,
              ),
            ),

            SizedBox(height: 8),

            Text(
              'Manage projects. Get things done.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6F6878)),
            ),

            SizedBox(height: 36),

            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF6C4AB6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: const Color(0xFFE9E1F7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(
        Icons.task_alt_rounded,
        size: 48,
        color: Color(0xFF6C4AB6),
      ),
    );
  }
}
