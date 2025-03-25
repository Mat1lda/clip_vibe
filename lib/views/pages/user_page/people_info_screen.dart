import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

import '../../../components/colors.dart';
import '../../../databases/services/chat_services.dart';
import '../../../databases/services/user_service.dart';
import '../../../provider/loading_model.dart';
import '../../widgets/custom_text.dart';
import '../camera_page/add_video_screen.dart';
import '../video_page/video_people_info_screen.dart';

class PeopleInfoScreen extends StatefulWidget {
  final String peopleID;

  const PeopleInfoScreen({Key? key, required this.peopleID}) : super(key: key);

  @override
  State<PeopleInfoScreen> createState() => _PeopleInfoScreenState();
}

class _PeopleInfoScreenState extends State<PeopleInfoScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  // File? imageFile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<File?> getImage() async {
    var picker = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picker != null) {
      File? imageFile = File(picker.path);
      return imageFile;
    }
    return null;
  }
  Future<int> getFollowerCount() async {
    DocumentSnapshot doc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
    List<dynamic> followers = (doc.data() as Map<String, dynamic>)['follower'] ?? [];
    return followers.length;
  }
  Stream<QuerySnapshot> getUserImage() async* {
    final currentUserID = FirebaseAuth.instance.currentUser?.uid;
    yield* FirebaseFirestore.instance
        .collection('users')
        .where('uID', isEqualTo: currentUserID)
        .snapshots();
  }

  Stream<QuerySnapshot> getPeopleImage(String id) async* {
    yield* FirebaseFirestore.instance
        .collection('users')
        .where('uID', isEqualTo: id)
        .snapshots();
  }

  pickVideo(ImageSource src, BuildContext context) async {
    final video = await ImagePicker().pickVideo(source: src);
    if (video != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddVideoScreen(
            videoFile: File(video.path),
            videoPath: video.path,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder(
          stream: UserService.getPeopleInfo(widget.peopleID),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // SizedBox(
                      //   width: MediaQuery.of(context).size.width / 8,
                      // ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        iconSize: 24,
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black87,
                        ),
                      ),
                      Center(
                        child: CustomText(
                          fontSize: 20,
                          text: '${snapshot.data.get('fullName')}',
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ChatService.getChatID(
                            context: context,
                            peopleID: snapshot.data.get('uID'),
                            currentUserID: '$uid',
                            peopleName: snapshot.data.get('fullName'),
                            peopleImage: snapshot.data.get('avartaURL'),
                          );
                        },
                        iconSize: 25,
                        icon: const Icon(
                          CupertinoIcons.chat_bubble_fill,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: StreamBuilder<QuerySnapshot>(
                              stream: getPeopleImage(widget.peopleID),
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
                                return Consumer<LoadingModel>(
                                  builder: (_, isLoadingImage, __) {
                                    if (isLoadingImage.isLoading) {
                                      return const CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    } else {
                                      return CircleAvatar(
                                        backgroundColor: Colors.black,
                                        backgroundImage: NetworkImage(snapshot
                                            .data?.docs.first['avartaURL']),
                                      );
                                    }
                                  },
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${snapshot.data.get('fullName')}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance.collection('users').doc(widget.peopleID).snapshots(),
                            builder: (BuildContext context,AsyncSnapshot snapshot) {
                              if (!snapshot.hasData || snapshot.hasError) {
                                return const Text("0",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        color: Colors.black));
                              }

                              List<dynamic> following = (snapshot.data!.data() as Map<String, dynamic>)['following'] ?? [];
                              return Text(
                                "${following.length}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: Colors.black),
                              );
                            },
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            "Đang follow",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade700),
                          )
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        children: [
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance.collection('users').doc(widget.peopleID).snapshots(),
                            builder: (BuildContext context,AsyncSnapshot snapshot) {
                              if (!snapshot.hasData || snapshot.hasError) {
                                return const Text("0",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        color: Colors.black));
                              }

                              List<dynamic> followers = (snapshot.data!.data() as Map<String, dynamic>)['follower'] ?? [];
                              return Text(
                                "${followers.length}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: Colors.black),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Follower",
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          UserService.follow(widget.peopleID);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.pinkColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 60),
                        ),
                        child:
                        !snapshot.data.get('follower').contains(uid) ?
                        const Text(
                          "Follow",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ) : const Icon(Icons.check),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      InkWell(
                        onTap: () {
                          ChatService.getChatID(
                            context: context,
                            peopleID: snapshot.data.get('uID'),
                            currentUserID: '$uid',
                            peopleName: snapshot.data.get('fullName'),
                            peopleImage: snapshot.data.get('avartaURL'),
                          );
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 6),
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: const Icon(
                              Icons.send,
                              color: Colors.black,
                            )),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                    child: TabBar(
                      controller: _tabController,
                      // indicatorColor: Colors.green,
                      // labelColor: Colors.red,
                      // indicator: MaterialIndicator(
                      //   height: 3,
                      //   topLeftRadius: 0,
                      //   topRightRadius: 0,
                      //   bottomLeftRadius: 5,
                      //   bottomRightRadius: 5,
                      //   horizontalPadding: 16,
                      //   tabPosition: TabPosition.bottom,
                      // ),
                      tabs: const <Widget>[
                        Tab(
                          icon: Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                        ),
                        Tab(
                          icon: Icon(
                            Icons.video_collection,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    height: MediaQuery.of(context).size.height - 363,
                    width: MediaQuery.of(context).size.width,
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, top: 22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _buildInfoCard(
                                  context: context,
                                  icon: Icons.person,
                                  title: 'Full Name',
                                  value: '${snapshot.data.get('fullName')}',
                                ),
                                _buildInfoCard(
                                  context: context,
                                  icon: Icons.phone,
                                  title: 'Phone Number',
                                  value: '${snapshot.data.get('phone')}',
                                ),
                                _buildInfoCard(
                                  context: context,
                                  icon: Icons.calendar_today,
                                  title: 'Age',
                                  value: '${snapshot.data.get('age')}',
                                ),
                                _buildInfoCard(
                                  context: context,
                                  icon: Icons.people,
                                  title: 'Gender',
                                  value: '${snapshot.data.get('gender')}',
                                ),
                                _buildInfoCard(
                                  context: context,
                                  icon: Icons.email,
                                  title: 'Email',
                                  value: '${snapshot.data.get('email')}',
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('videos')
                              .where('uid', isEqualTo: widget.peopleID)
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
                            return GridView.builder(
                                gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 2 / 3),
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final item = snapshot.data!.docs[index];
                                  return Card(
                                    color: Colors.grey,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  VideoProfileScreen(
                                                    videoID: item['id'],
                                                  )),
                                        );
                                      },
                                      child: Stack(
                                        fit: StackFit.expand,
                                        alignment: Alignment.center,
                                        children: [
                                          ClipRect(
                                            child: Image.network(
                                              '${item['thumbnail']}',
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 5,
                                            left: 5,
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.favorite_border,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(
                                                  width: 3,
                                                ),
                                                Text(
                                                  '${item['likes'].length}',
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                      fontWeight:
                                                      FontWeight.bold),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
Widget _buildInfoCard({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String value,
  bool isLast = false,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Colors.black,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}