import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'PostProvider.dart';
import 'Post.dart';
import 'CommentPage.dart';

class PostPage extends StatefulWidget {
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final PostProvider postProvider = PostProvider(firebaseFirestore: FirebaseFirestore.instance);
  final TextEditingController contentController = TextEditingController();

  void createPost() {
    String content = contentController.text.trim();
    if (content.isNotEmpty) {
      Post post = Post(
        id: '',
        userId: FirebaseAuth.instance.currentUser!.uid,
        content: content,
        timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      postProvider.createPost(post);
      contentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Posts')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: 'Write a post...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: createPost,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: postProvider.getPosts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                List<DocumentSnapshot> docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    Post post = Post.fromDocument(docs[index]);
                    return ListTile(
                      title: Text(post.content),
                      subtitle: Text('Posted by: ${post.userId}'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommentPage(postId: post.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
