import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'AuthProvider.dart';
import 'HomePage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.status) {
      case Status.authenticateError:
        Fluttertoast.showToast(msg: 'Sign in failed');
        break;
      case Status.authenticateCanceled:
        Fluttertoast.showToast(msg: 'Sign in cancelled');
        break;
      case Status.authenticated:
        Fluttertoast.showToast(msg: 'Sign in successful');
        break;
      default:
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () async {
            bool isSuccess = await authProvider.handleGoogleSignIn();
            if (isSuccess) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage())); // Ensure HomePage is implemented
            }
          },
          child: Image.asset('assets/images/google_login.jpg'),
        ),
      ),
    );
  }
}
