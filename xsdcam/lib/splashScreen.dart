import 'package:flutter/material.dart';
import 'package:xsdcam/Home/signInScreen.dart';

import 'Home/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignInScreen()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        body: Center(
          child: Image(image: AssetImage('assets/logo.png'),fit: BoxFit.fill)
        )
      ),
    );
  }
}