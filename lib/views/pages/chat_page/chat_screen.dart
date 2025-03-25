import 'package:clip_vibe/views/pages/chat_page/chat_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/colors.dart';
import '../../../databases/services/chat_services.dart';
import '../../../provider/loading_model.dart';
import '../../widgets/custom_text.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({Key? key}) : super(key: key);

  final currentUserID = FirebaseAuth.instance.currentUser?.uid;

  // void goToChatDetailScreen(
  //     BuildContext context, String peopleID, String peopleName) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //         builder: (context) => ChatDetailScreen(
  //               peopleID: peopleID,
  //               peopleName: peopleName,
  //             )),
  //   );
  // }

  Stream<QuerySnapshot> currentUserStream() async* {
    try {
      List<dynamic> data = await ChatService.getUserPeopleChatID(
          currentUserID: currentUserID.toString());
      List<String>? listPeoPleChatID = (data).map((e) => e as String).toList();
      
      if (listPeoPleChatID.isEmpty) {
        yield* FirebaseFirestore.instance
            .collection('users')
            .where('uID', isEqualTo: '')
            .limit(0)
            .snapshots();
      } else {
        yield* FirebaseFirestore.instance
            .collection('users')
            .where('uID', whereIn: listPeoPleChatID)
            .snapshots();
      }
    } catch (e) {
      print('Error in currentUserStream: $e');
      yield* FirebaseFirestore.instance
          .collection('users')
          .where('uID', isEqualTo: '')
          .limit(0)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(onPressed: (){}, icon: Icon(Icons.add_location_alt)),
            title: const Text(
              'Hộp Thư',
              style: TextStyle(
                color: Colors.black,
                fontSize: 19,
                fontFamily: 'Tiktok',
                fontWeight: FontWeight.bold
              ),
            ),
            actions: [
              IconButton(onPressed: (){}, icon: Icon(Icons.search_rounded, )),
            ],
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Container(
            //   alignment: Alignment.center,
            //   padding: const EdgeInsets.only(left: 20, bottom: 10),
            //   height: MediaQuery.of(context).size.height / 10,
            //   child: CustomText(
            //     alignment: Alignment.bottomLeft,
            //     fontSize: 22,
            //     text: 'Everybody',
            //     fontFamily: 'Inter',
            //     color: Colors.white,
            //   ),
            // ),
            Expanded(
              child: Container(
                // decoration: BoxDecoration(
                //   color: Colors.white,
                //   borderRadius: const BorderRadius.only(
                //     topLeft: Radius.circular(30),
                //     topRight: Radius.circular(30),
                //   ),
                //   boxShadow: [
                //     BoxShadow(
                //       color: Colors.black87.withOpacity(0.2),
                //       spreadRadius: 1,
                //       blurRadius: 2,
                //       offset: const Offset(1, 1), // changes position of shadow
                //     ),
                //   ],
                // ),
                child: Column(
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 12.0, left: 12.0),
                    //   child: Row(
                    //     children: [
                    //       const Icon(
                    //         Icons.people_alt_rounded,
                    //         color: Colors.grey,
                    //       ),
                    //       const SizedBox(
                    //         width: 10,
                    //       ),
                    //       CustomText(
                    //         alignment: Alignment.bottomLeft,
                    //         fontSize: 20,
                    //         text: 'Chatted People',
                    //         fontFamily: 'Popins',
                    //         color: Colors.grey,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Consumer<LoadingModel>(
                      builder: (_, isBack, __) {
                        return Container(
                          height: MediaQuery.of(context).size.height / 3,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: currentUserStream(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'chưa có liên hệ',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontFamily: 'TiktokRegular',
                                    ),
                                  ),
                                );
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Text(
                                    'chưa có liên hệ',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontFamily: 'TiktokRegular',
                                    ),
                                  ),
                                );
                              }
                              return ListView.separated(
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                const Padding(
                                  padding:
                                  EdgeInsets.only(left: 16.0, right: 16.0),
                                  child: Divider(
                                    thickness: 1,
                                    color: Colors.black12,
                                  ),
                                ),
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (BuildContext ctx, int index) {
                                  final item = snapshot.data!.docs[index];
                                  return InkWell(
                                    onTap: () {
                                      // ChatService.getUserIDChatRoom(
                                      //     currentUserID: currentUserID.toString());
                                      ChatService.getChatID(
                                        context: context,
                                        peopleID: item['uID'],
                                        currentUserID: currentUserID.toString(),
                                        peopleName: item['fullName'],
                                        peopleImage: item['avartaURL'],
                                      );
                                    },
                                    child: ListTile(
                                      leading: Container(
                                        width: 48,
                                        height: 48,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        alignment: Alignment.center,
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            item['avartaURL'],
                                          ),
                                        ),
                                      ),
                                      title: CustomText(
                                        alignment: Alignment.centerLeft,
                                        fontSize: 16,
                                        text: item['fullName'],
                                        fontFamily: 'Poppins',
                                        color: Colors.black54,
                                      ),
                                      trailing: Wrap(spacing: 20, children: [
                                        InkWell(
                                          onTap: () {},
                                          child: const Icon(
                                            Icons.chat,
                                            color: Colors.grey,
                                          ),
                                        )
                                      ]),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, left: 12.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.people_alt_rounded,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          CustomText(
                            alignment: Alignment.bottomLeft,
                            fontSize: 18,
                            text: 'Đề xuất',
                            fontFamily: 'TiktokRegular',
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('uID', isNotEqualTo: currentUserID)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Something went wrong');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return ListView.separated(
                            separatorBuilder:
                                (BuildContext context, int index) =>
                            const Padding(
                              padding: EdgeInsets.only(left: 16.0, right: 16.0),
                              child: Divider(
                                thickness: 1,
                                color: Colors.black12,
                              ),
                            ),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (BuildContext ctx, int index) {
                              final item = snapshot.data!.docs[index];
                              return InkWell(
                                onTap: () {
                                  // ChatService.getUserIDChatRoom(
                                  //     currentUserID: currentUserID.toString());
                                  ChatService.getChatID(
                                    context: context,
                                    peopleID: item['uID'],
                                    currentUserID: currentUserID.toString(),
                                    peopleName: item['fullName'],
                                    peopleImage: item['avartaURL'],
                                  );
                                },
                                child: ListTile(
                                  leading: Container(
                                    width: 48,
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    alignment: Alignment.center,
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        item['avartaURL'],
                                      ),
                                    ),
                                  ),
                                  title: CustomText(
                                    alignment: Alignment.centerLeft,
                                    fontSize: 16,
                                    text: item['fullName'],
                                    fontFamily: 'Poppins',
                                    color: Colors.black54,
                                  ),
                                  trailing: Wrap(spacing: 20, children: [
                                    InkWell(
                                      onTap: () {
                                      },
                                      child: const Icon(
                                        Icons.chat,
                                        color: Colors.grey,
                                      ),
                                    )
                                  ]),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}