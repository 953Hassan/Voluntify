import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ProfileProvider.dart';
import 'ChatUser.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? avatarImageFile;
  String id = FirebaseAuth.instance.currentUser?.uid ?? '';
  String displayName = '';
  String phoneNumber = '';
  String aboutMe = '';
  String? photoUrl;
  bool isLoading = false;

  final ProfileProvider profileProvider = ProfileProvider(
    firebaseFirestore: FirebaseFirestore.instance,
    firebaseStorage: FirebaseStorage.instance,
  );

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  void getUserInfo() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(id).get();
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?; // Using null-aware operator
    if (data != null) {
      setState(() {
        displayName = data['displayName'] ?? '';
        phoneNumber = data['phoneNumber'] ?? '';
        aboutMe = data['aboutMe'] ?? '';
        photoUrl = data['photoUrl'];
      });
    }
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery).catchError((onError) {
      Fluttertoast.showToast(msg: onError.toString());
    });
    File? image;
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }
    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = id;
    UploadTask uploadTask = profileProvider.uploadImageFile(avatarImageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      photoUrl = await snapshot.ref.getDownloadURL();
      ChatUser updateInfo = ChatUser(
        id: id,
        photoUrl: photoUrl ?? '',
        displayName: displayName,
        phoneNumber: phoneNumber,
        aboutMe: aboutMe,
      );
      await profileProvider.updateFirestoreData('users', id, updateInfo.toJson());
      setState(() {
        isLoading = false;
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void updateFirestoreData() async {
    setState(() {
      isLoading = true;
    });
    ChatUser updateInfo = ChatUser(
      id: id,
      photoUrl: photoUrl ?? '',
      displayName: displayName,
      phoneNumber: phoneNumber,
      aboutMe: aboutMe,
    );
    await profileProvider.updateFirestoreData('users', id, updateInfo.toJson());
    setState(() {
      isLoading = false;
    });
    Fluttertoast.showToast(msg: 'Update Success');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                getImage();
              },
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: photoUrl != null ? Image.network(photoUrl!, fit: BoxFit.cover) : Icon(Icons.person, size: 100),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      color: Colors.black54,
                      child: Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(labelText: 'Display Name'),
                onChanged: (value) => displayName = value,
                controller: TextEditingController(text: displayName),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                onChanged: (value) => phoneNumber = value,
                controller: TextEditingController(text: phoneNumber),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(labelText: 'About Me'),
                onChanged: (value) => aboutMe = value,
                controller: TextEditingController(text: aboutMe),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                updateFirestoreData();
              },
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
