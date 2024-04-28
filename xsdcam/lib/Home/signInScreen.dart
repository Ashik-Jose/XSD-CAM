import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/auth.dart';
import 'googleSignInButton.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  Authentication _auth=Authentication();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(),
              const Expanded(
                child: Image(image: AssetImage('assets/logo_sym.png'),height: 60,)
              ),
              FutureBuilder(
                future: _auth.initializeFirebase(context: context),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error initializing Firebase');
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return const GoogleSignInButton();
                  }
                  return const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
