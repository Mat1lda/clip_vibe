import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../views/pages/chat_page/chat_detail_screen.dart';

class ChatService {
  static getChatID({
    required BuildContext context,
    required String peopleID,
    required String currentUserID,
    required String peopleImage,
    required String peopleName,
  }) {
    CollectionReference chats = FirebaseFirestore.instance.collection('chats');
    String chatDocID;
    chats
        .where('users', isEqualTo: {peopleID: null, currentUserID: null})
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            chatDocID = querySnapshot.docs.single.id;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                  peopleID: peopleID,
                  peopleName: peopleName,
                  ChatID: chatDocID,
                  peopleImage: peopleImage,
                  contextBackPage: context,
                ),
              ),
            );
          } else {
            chats
                .add({
                  'users': {currentUserID: null, peopleID: null},
                })
                .then((value) {
                  chatDocID = value.id;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(
                        peopleID: peopleID,
                        peopleName: peopleName,
                        ChatID: chatDocID,
                        peopleImage: peopleImage,
                        contextBackPage: context,
                      ),
                    ),
                  );
                });
          }
        })
        .catchError((e) {});
  }

  // static getUserIDChatRoom({
  //   required String currentUserID,
  // }) {
  //   CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  //   String uID = 'uID';
  //   chats
  //       .where('messages', whereIn: [currentUserID])
  //       .limit(3)
  //       .get()
  //       .then(
  //         (QuerySnapshot querySnapshot) {
  //           if (querySnapshot.docs.isNotEmpty) {
  //             for (int i = 0; i < querySnapshot.docs.length; i++) {
  //               print('lap = ${querySnapshot.docs[i].id}');
  //             }
  //           } else {
  //             print('lap = none+ ${querySnapshot.docs}');
  //           }
  //         },
  //       )
  //       .catchError((e) {});
  // }

  static Future getUserPeopleChatID({required String currentUserID}) async {
    final CollectionReference users = FirebaseFirestore.instance.collection('users');
    final result = await users.doc(currentUserID).get();
    
    if (!result.exists) {
      return [];
    }
    
    final data = result.data() as Map<String, dynamic>?;
    if (data == null || !data.containsKey('myChatPeopleID')) {
      // Initialize the field if it doesn't exist
      await users.doc(currentUserID).update({
        'myChatPeopleID': []
      });
      return [];
    }
    
    return data['myChatPeopleID'] ?? [];
  }

  static Future getUserPeopleChat({required String currentUserID}) async {
    List<dynamic> data = await ChatService.getUserPeopleChatID(
      currentUserID: currentUserID.toString(),
    );
    List<String>? listPeoPleChatID = (data).map((e) => e as String).toList();
    
    if (listPeoPleChatID.isEmpty) {
      return FirebaseFirestore.instance
          .collection('users')
          .where('uID', isEqualTo: '')
          .limit(0)
          .snapshots();
    }
    
    return FirebaseFirestore.instance
        .collection('users')
        .where('uID', whereIn: listPeoPleChatID)
        .snapshots();
  }
}
