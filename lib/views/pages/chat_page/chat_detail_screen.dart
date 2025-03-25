import 'dart:io';

import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../components/colors.dart';
import '../../../databases/services/chat_services.dart';
import '../../../databases/services/storage_services.dart';
import '../../../provider/loading_model.dart';
import '../../../provider/save_model.dart';
import '../../widgets/custom_text.dart';
import '../user_page/people_info_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final String peopleID;
  final String peopleName;
  final String ChatID;
  final String peopleImage;
  final BuildContext? contextBackPage;
  const ChatDetailScreen({
    Key? key,
    required this.peopleID,
    required this.peopleName,
    required this.peopleImage,
    required this.ChatID,
    this.contextBackPage,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState(
      this.peopleID, this.peopleName, this.ChatID, this.peopleImage);
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  final peopleID;
  final peopleName;
  final peopleImage;
  final ChatID;
  final currentUserID = FirebaseAuth.instance.currentUser?.uid;
  var chatDocID;
  final TextEditingController _textEditingController = TextEditingController();
  _ChatDetailScreenState(
      this.peopleID, this.peopleName, this.ChatID, this.peopleImage);

  void sendMessage(String message, String peopleChatID, String type) {
    if (message.trim().isEmpty) return;
    
    context.read<LoadingModel>().isLoading = true;
    
    chats.doc(ChatID).collection('messages').add({
      'createdOn': FieldValue.serverTimestamp(),
      'uID': currentUserID,
      'content': message.trim(),
      'type': type
    }).then((value) async {
      _textEditingController.text = '';
      context.read<LoadingModel>().isLoading = false;

      try {
        List<dynamic> data = await ChatService.getUserPeopleChatID(
            currentUserID: currentUserID.toString());
        List<String>? listPeoPleChatID =
            (data).map((e) => e as String).toList();
            
        if (listPeoPleChatID != null && !listPeoPleChatID.contains(peopleChatID)) {
          final CollectionReference users =
              FirebaseFirestore.instance.collection('users');
          await users.doc(currentUserID).update({
            'myChatPeopleID': FieldValue.arrayUnion([peopleChatID]),
          });
        }
      } catch (e) {
        context.read<LoadingModel>().isLoading = false;
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Error updating chat list: ${e.toString()}'),
        //     backgroundColor: Colors.red,
        //   ),
        // );
        print(e);
      }
    }).catchError((error) {
      context.read<LoadingModel>().isLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  bool isSender(String sender) {
    return sender == currentUserID;
  }

  Alignment getAligment(sender) {
    if (sender == currentUserID) {
      return Alignment.topRight;
    }
    return Alignment.topLeft;
  }

  Future<File?> getImage(ImageSource src) async {
    var _picker = await ImagePicker().pickImage(source: src);
    if (_picker != null) {
      File? imageFile = File(_picker.path);
      return imageFile;
    }
    return null;
  }

  showOptionsDialog(BuildContext context, String url) {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          SimpleDialogOption(
            onPressed: () {
              // StorageServices.saveFile(url);
              // Navigator.of(context).pop();
            },
            child: Row(
              children: const [
                Icon(Icons.save_alt),
                Padding(
                  padding: EdgeInsets.all(7.0),
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(),
            child: Row(
              children: const [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                Padding(
                  padding: EdgeInsets.all(7.0),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 20, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.read<LoadingModel>().isLoading = false;
    context.read<SaveModel>().isSaving = 0.0;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 40,
              width: 40,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PeopleInfoScreen(peopleID: peopleID)),
                  );
                },
                child: CircleAvatar(
                  backgroundImage: NetworkImage(peopleImage),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              child: CustomText(
                alignment: Alignment.center,
                fontSize: 20,
                maxLines: 2,
                text: peopleName,
                fontFamily: 'Tiktok',
                color: Colors.black,
              ),
            ),
          ],
        ),
        elevation: 0,
        toolbarHeight: 50,
        //shadowColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            widget.contextBackPage?.read<LoadingModel>().changeBack();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          // Icon(
          //   Icons.call_outlined,
          //   color: MyColors.mainColor,
          // ),
        ],
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .doc(ChatID)
              .collection('messages')
              .orderBy('createdOn', descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            //Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            if (snapshot.hasData) {
              return Column(
                children: [
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
                      //       offset: const Offset(
                      //           1, 1), // changes position of shadow
                      //     ),
                      //   ],
                      // ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ListView(
                          reverse: true,
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            var data = document.data()! as Map<String, dynamic>;
                            return Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: data['type'] == 'image'
                                            ? GestureDetector(
                                          onLongPress: () {
                                            showOptionsDialog(
                                                context, data['content']);
                                          },
                                          child: Container(
                                            width: 200,
                                            height: 200,
                                            padding:
                                            const EdgeInsets.only(
                                                left: 10, right: 10),
                                            alignment: isSender(
                                                data['uID']
                                                    .toString())
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: isSender(data['uID'].toString())
                                                  ? CrossAxisAlignment.end
                                                  : CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: Image.network(
                                                    data['content'],
                                                    fit: BoxFit.cover,
                                                    width: 180,
                                                    height: 180,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  data['createdOn'] == null
                                                      ? DateFormat('HH:mm').format(DateTime.now())
                                                      : DateFormat('HH:mm').format(data['createdOn'].toDate()),
                                                  style: const TextStyle(
                                                    color: Colors.black45,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                            : Column(
                                              crossAxisAlignment: isSender(data['uID'].toString())
                                                  ? CrossAxisAlignment.end
                                                  : CrossAxisAlignment.start,
                                              children: [
                                                BubbleSpecialThree(
                                                  text: data['content'],
                                                  color: isSender(
                                                      data['uID'].toString())
                                                      ? MyColors.thirdColor
                                                      : Colors.grey.shade100,
                                                  tail: true,
                                                  isSender: isSender(
                                                      data['uID'].toString()),
                                                  textStyle: TextStyle(
                                                      color: isSender(
                                                          data['uID'].toString())
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontSize: 16,
                                                      fontFamily: 'TiktokRegular'),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: isSender(data['uID'].toString()) ? 0 : 12,
                                                    right: isSender(data['uID'].toString()) ? 12 : 0,
                                                  ),
                                                  child: Text(
                                                    data['createdOn'] == null
                                                        ? DateFormat('HH:mm').format(DateTime.now())
                                                        : DateFormat('HH:mm').format(data['createdOn'].toDate()),
                                                    style: const TextStyle(
                                                      color: Colors.black45,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  Consumer<LoadingModel>(
                    builder: (_, isLoadingImage, __) {
                      if (isLoadingImage.isLoading) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          child: const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                              onPressed: () async {
                                context.read<LoadingModel>().changeLoading();
                                File? fileImage =
                                await getImage(ImageSource.camera);
                                if (fileImage == null) {
                                  context.read<LoadingModel>().changeLoading();
                                } else {
                                  String fileName =
                                  await StorageServices.uploadImage(
                                      fileImage);
                                  sendMessage(fileName, peopleID, 'image');
                                  try {
                                    context
                                        .read<LoadingModel>()
                                        .changeLoading();
                                  } catch (e) {}
                                }
                              },
                              icon: Icon(
                                Icons.enhance_photo_translate,
                                color: MyColors.thirdColor,
                              )),
                          IconButton(
                              onPressed: () async {
                                context.read<LoadingModel>().changeLoading();
                                File? fileImage =
                                await getImage(ImageSource.gallery);
                                if (fileImage == null) {
                                  context.read<LoadingModel>().changeLoading();
                                } else {
                                  String fileName =
                                  await StorageServices.uploadImage(
                                      fileImage);
                                  sendMessage(fileName, peopleID, 'image');
                                  try {
                                    context
                                        .read<LoadingModel>()
                                        .changeLoading();
                                  } catch (e) {}
                                }
                              },
                              icon: Icon(Icons.image_outlined,
                                  color: Colors.black)),
                          Expanded(
                            child: Container(
                              height: 45,
                              child: TextField(
                                controller: _textEditingController,
                                textAlignVertical: TextAlignVertical.bottom,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 2,
                                      color: Colors.grey.shade100,
                                    ),
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  hintText: "Type here ...",
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      sendMessage(_textEditingController.text,
                                          peopleID, 'text');
                                    },
                                    icon: Icon(
                                      Icons.send_rounded,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // IconButton(
                          //   onPressed: () {
                          //     sendMessage(_textEditingController.text);
                          //   },
                          //   icon: Icon(
                          //     Icons.send_outlined,
                          //     color: MyColors.mainColor,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return const Center(
              child: Text('Failed!'),
            );
          }),
    );
  }
}