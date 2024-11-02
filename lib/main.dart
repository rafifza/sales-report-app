import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripasammkt/pages/home.dart';
import 'package:tripasammkt/pages/login.dart';

void main() {
  // Hide the system status bar and set the status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Make status bar transparent
      statusBarIconBrightness: Brightness.light, // Set icon brightness to light
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tripasammkt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins', // Using Poppins font.
      ),
      home: const CheckAuth(), // CheckAuth will handle initial route logic
      debugShowCheckedModeBanner: false, // Remove debug banner
    );
  }
}

class CheckAuth extends StatefulWidget {
  const CheckAuth({super.key});

  @override
  CheckAuthState createState() => CheckAuthState();
}

class CheckAuthState extends State<CheckAuth> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAccessToken();
  }

  Future<void> _checkAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken =
        prefs.getString('access_token'); // Retrieve the access token

    // Simulate a slight delay to show loading state
    await Future.delayed(const Duration(seconds: 1));

    // Check if the widget is still mounted before using context
    if (!mounted) return; // Use 'this.mounted' instead of 'context.mounted'

    if (accessToken != null && accessToken.isNotEmpty) {
      // If token exists, navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    } else {
      // If no token, navigate to LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() // Show loading indicator while checking token
            : const SizedBox.shrink(),
      ),
    );
  }
}
