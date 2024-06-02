import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileProvider {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ProfileProvider({required this.firebaseFirestore, required this.firebaseStorage});

  UploadTask uploadImageFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateFirestoreData(String collectionPath, String path, Map<String, dynamic> dataUpdateNeeded) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(path)
        .update(dataUpdateNeeded);
  }
}
