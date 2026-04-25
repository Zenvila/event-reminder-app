import 'package:eventora_planner/providers/theme_provider.dart';
import 'package:eventora_planner/providers/user_provider.dart';
import 'package:eventora_planner/screens/auth_screen.dart';
import 'package:eventora_planner/screens/calender_screen.dart';
import 'package:eventora_planner/screens/on_boarding_screen.dart';
import 'package:eventora_planner/screens/settings.dart';
import 'package:eventora_planner/screens/upcoming_events_screen.dart';
import 'package:eventora_planner/services/firebase_bootstrap.dart';
import 'package:eventora_planner/services/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> handlePermissionsFirstTimeOnly() async {
  final prefs = await SharedPreferences.getInstance();
  final asked = prefs.getBool('asked_permissions') ?? false;
  if (!asked) {
    if (Platform.isAndroid && await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        package: 'com.example.eventora_planner',
      );
      await intent.launch();
    }
    await prefs.setBool('asked_permissions', true);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    _initApp();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAppServices();
    });
  }

  Future<void> _initApp() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final userName = prefs.getString('user_name') ?? '';
    final userEmail = prefs.getString('user_email') ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (isLoggedIn && userName.isNotEmpty) {
        final userProvider =
            Provider.of<UserProvider>(context, listen: false);
        await userProvider.setLocalUser(
            name: userName, email: userEmail);
      }

      if (!onboardingDone) {
        _initialScreen = const OnboardingScreen();
      } else if (isLoggedIn) {
        _initialScreen = const UpcomingEventScreenWidget();
      } else {
        _initialScreen = const AuthScreen();
      }

      setState(() => _initialized = true);
    });
  }

  Future<void> _initializeAppServices() async {
    // Keep startup smooth by rendering UI first, then bootstrapping services.
    try {
      await initializeNotifications();
      await handlePermissionsFirstTimeOnly();
    } catch (_) {
      // Keep app usable even if a background setup task fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Center(child: CircularProgressIndicator())),
      );
    }

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Eventora Planner',
          theme: ThemeProvider.lightTheme,
          darkTheme: ThemeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          home: _initialScreen,
          routes: {
            '/onboarding': (context) => const OnboardingScreen(),
            '/auth': (context) => const AuthScreen(),
            '/home': (context) => const UpcomingEventScreenWidget(),
            '/calender': (context) => const Calenderscreen(),
            '/settings': (context) => const SettingsPage(),
          },
        );
      },
    );
  }
}