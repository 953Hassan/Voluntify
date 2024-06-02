import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'AuthProvider.dart'; // Adjust the path if necessary

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  MyApp({required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            googleSignIn: GoogleSignIn(),
            firebaseAuth: FirebaseAuth.instance,
            firebaseFirestore: FirebaseFirestore.instance,
            prefs: prefs,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Voluntify Beta',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Voluntify Beta"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Welcome to Voluntify Beta!"),
            ElevatedButton(
              onPressed: () async {
                bool success = await authProvider.handleGoogleSignIn();
                if (success) {
                  // Navigate to another screen or show a success message
                } else {
                  // Show an error message
                }
              },
              child: Text("Sign in with Google"),
            ),
          ],
        ),
      ),
    );
  }
}
