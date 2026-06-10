import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/diagnostic_provider.dart';
import 'providers/mood_provider.dart';
import 'views/auth/login_screen.dart';
import 'views/home/dashboard_screen.dart';
import 'views/onboarding/onboarding_screen.dart';
import 'views/onboarding/privacy_screen.dart';
import 'views/onboarding/palette_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<DiagnosticProvider>(
          create: (_) => DiagnosticProvider(),
        ),
        ChangeNotifierProvider<MoodProvider>(create: (_) => MoodProvider()),
      ],
      child: MaterialApp(
        title: 'RiseUp - Monitoring Kesehatan Mental',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            primary: const Color(0xFF6C63FF),
            secondary: const Color(0xFF00C9A7),
            background: const Color(0xFFF8F9FD),
          ),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFF3F3D56)),
            titleTextStyle: TextStyle(
              color: Color(0xFF3F3D56),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    switch (authProvider.status) {
      case AuthStatus.uninitialized:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.authenticating:
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        if (!authProvider.onboardingCompleted) {
          return const OnboardingScreen();
        } else if (!authProvider.privacyAccepted) {
          return const PrivacyScreen();
        } else if (!authProvider.paletteSetupCompleted) {
          return const PaletteSetupScreen();
        } else {
          return const LoginScreen();
        }
      case AuthStatus.authenticated:
        return const DashboardScreen();
    }
  }
}
