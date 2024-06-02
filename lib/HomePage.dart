import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AuthProvider.dart';
import 'HomeProvider.dart';
import 'ProfilePage.dart';
import 'ChatUser.dart';
import 'ChatPage.dart';
import 'Sizes.dart';
import 'Colours.dart';
import 'KeyboardUtils.dart';
import 'FirestoreConstants.dart';
import 'dart:async';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchTextEditingController = TextEditingController();
  final StreamController<bool> buttonClearController = StreamController<bool>();
  String _textSearch = "";

  @override
  void dispose() {
    searchTextEditingController.dispose();
    buttonClearController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final homeProvider = HomeProvider(
        firebaseFirestore: FirebaseFirestore.instance);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Smart Talk'),
        actions: [
          IconButton(
            onPressed: () => authProvider.googleSignOut(),
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: Column(
        children: [
          buildSearchBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: homeProvider.getFirestoreData(
                  FirestoreConstants.pathUserCollection, 20, _textSearch),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var users = snapshot.data!.docs;
                  return ListView.separated(
                    itemCount: users.length,
                    itemBuilder: (context, index) =>
                        buildItem(context, users[index]),
                    separatorBuilder: (context, index) => Divider(),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(Sizes.dimen_10),
      height: Sizes.dimen_50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: Sizes.dimen_10),
          const Icon(
              Icons.person_search, color: Colours.white, size: Sizes.dimen_28),
          const SizedBox(width: 5),
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.search,
              controller: searchTextEditingController,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  buttonClearController.add(true);
                  setState(() {
                    _textSearch = value;
                  });
                } else {
                  buttonClearController.add(false);
                  setState(() {
                    _textSearch = "";
                  });
                }
              },
              decoration: const InputDecoration.collapsed(
                hintText: 'Search here...',
                hintStyle: TextStyle(color: Colours.white),
              ),
            ),
          ),
          StreamBuilder(
            stream: buttonClearController.stream,
            builder: (context, snapshot) {
              return snapshot.data == true
                  ? GestureDetector(
                onTap: () {
                  searchTextEditingController.clear();
                  buttonClearController.add(false);
                  setState(() {
                    _textSearch = '';
                  });
                },
                child: const Icon(
                  Icons.clear_rounded,
                  color: Colours.greyColor,
                  size: 20,
                ),
              )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.dimen_30),
        color: Colours.spaceLight,
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot? documentSnapshot) {
    final firebaseAuth = FirebaseAuth.instance;
    if (documentSnapshot != null) {
      ChatUser userChat = ChatUser.fromSnapshot(
          documentSnapshot);
      if (userChat.id == firebaseAuth.currentUser?.uid) {
        return const SizedBox.shrink();
      } else {
        return TextButton(
          onPressed: () {
            if (KeyboardUtils.isKeyboardShowing()) {
              KeyboardUtils.closeKeyboard(context);
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChatPage(
                      peerId: userChat.id,
                      peerAvatar: userChat.photoUrl,
                      peerNickname: userChat.displayName,
                      userAvatar: firebaseAuth.currentUser!.photoURL!,
                      currentUserId: '',
                    ),
              ),
            );
          },
          child: ListTile(
            leading: userChat.photoUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(Sizes.dimen_30),
              child: Image.network(
                userChat.photoUrl,
                fit: BoxFit.cover,
                width: 50,
                height: 50,
                loadingBuilder: (BuildContext ctx, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        color: Colors.grey,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  }
                },
                errorBuilder: (context, object, stackTrace) {
                  return const Icon(Icons.account_circle, size: 50);
                },
              ),
            )
                : const Icon(Icons.account_circle, size: 50),
            title: Text(
              userChat.displayName,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}
