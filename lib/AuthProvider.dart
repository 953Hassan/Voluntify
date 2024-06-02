import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status {
  uninitialized,
  authenticating,
  authenticated,
  authenticateError,
  authenticateCanceled
}

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;

  Status _status = Status.uninitialized;

  Status get status => _status;

  AuthProvider({
    required this.googleSignIn,
    required this.firebaseAuth,
    required this.firebaseFirestore,
    required this.prefs,
  });

  String? getFirebaseUserId() {
    return prefs.getString('id');
  }

  Future<bool> isLoggedIn() async {
    bool isLoggedIn = await googleSignIn.isSignedIn();
    return isLoggedIn && prefs.getString('id')?.isNotEmpty == true;
  }

  Future<bool> handleGoogleSignIn() async {
    _status = Status.authenticating;
    notifyListeners();

    try {
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
        User? firebaseUser = userCredential.user;

        if (firebaseUser != null) {
          final QuerySnapshot result = await firebaseFirestore
              .collection('users')
              .where('id', isEqualTo: firebaseUser.uid)
              .get();
          final List<DocumentSnapshot> document = result.docs;
          if (document.isEmpty) {
            await firebaseFirestore
                .collection('users')
                .doc(firebaseUser.uid)
                .set({
              'nickname': firebaseUser.displayName,
              'photoUrl': firebaseUser.photoURL,
              'id': firebaseUser.uid,
              'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
              'chattingWith': null
            });
          }
          _status = Status.authenticated;
          notifyListeners();
          return true;
        } else {
          _status = Status.authenticateError;
          notifyListeners();
          return false;
        }
      } else {
        _status = Status.authenticateCanceled;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Error signing in with Google: $e");
      _status = Status.authenticateError;
      notifyListeners();
      return false;
    }
  }

  Future<void> googleSignOut() async {
    try {
      await googleSignIn.signOut();
      await firebaseAuth.signOut();
      _status = Status.uninitialized;
      notifyListeners();
    } catch (e) {
      print("Error signing out with Google: $e");
    }
  }
}
