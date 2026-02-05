import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/storage_service.dart';
import 'registration_screen.dart';
import 'login_screen.dart';
import 'set_mpin_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    
    final isRegistered = await StorageService.getBool(StorageService.keyIsRegistered);
    final isLoggedIn = await StorageService.getBool(StorageService.keyIsLoggedIn);
    final isMpinSet = await StorageService.getBool(StorageService.keyIsMpinSet);

    if (!mounted) return;

    Widget nextScreen;
    if (!isRegistered) {
      nextScreen = const RegistrationScreen();
    } else if (!isLoggedIn) {
      nextScreen = const LoginScreen();
    } else if (!isMpinSet) {
      nextScreen = const SetMpinScreen();
    } else {
      nextScreen = const HomeScreen();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldDark),
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              const Text(
                'Sri Murugan Groups',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkBrown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}