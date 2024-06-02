import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ChatUser extends Equatable {
  final String id;
  final String photoUrl;
  final String displayName;
  final String phoneNumber;
  final String aboutMe;

  const ChatUser({
    required this.id,
    required this.photoUrl,
    required this.displayName,
    required this.phoneNumber,
    required this.aboutMe,
  });

  factory ChatUser.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return ChatUser(
      id: data['id'],
      photoUrl: data['photoUrl'],
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      aboutMe: data['aboutMe'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photoUrl': photoUrl,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'aboutMe': aboutMe,
    };
  }

  @override
  List<Object?> get props => [id, photoUrl, displayName, phoneNumber, aboutMe];
}
