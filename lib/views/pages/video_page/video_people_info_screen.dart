import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../components/colors.dart';
import '../../../databases/model/video.dart';
import '../../../databases/services/video_service.dart';
import '../../widgets/circle_animation.dart';
import '../../widgets/video_player_item.dart';

class VideoProfileScreen extends StatelessWidget {
  final String videoID;

  VideoProfileScreen({super.key, required this.videoID});

  String? uid = FirebaseAuth.instance.currentUser?.uid;
  final CollectionReference videos = FirebaseFirestore.instance.collection('videos');
  final CollectionReference users = FirebaseFirestore.instance.collection('users',);

  buildProfile(String profilePhoto) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          Positioned(
            left: 5,
            child: Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image(
                  image: NetworkImage(profilePhoto),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildMusicAlbum(String profilePhoto) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.grey, Colors.white],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image(
                image: NetworkImage(profilePhoto),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> sendComment(String message, String videoID) async {
    if (message == '') return;
    final result = await users.doc(uid).get();
    final String avatarURL = result.get('avartaURL');
    final String userName = result.get('fullName');
    var allDocs =
        await FirebaseFirestore.instance
            .collection('videos')
            .doc(videoID)
            .collection('commentList')
            .get();
    int len = allDocs.docs.length;
    videos
        .doc(videoID)
        .collection('commentList')
        .doc('Comment $len')
        .set({
          'createdOn': FieldValue.serverTimestamp(),
          'uID': uid,
          'content': message,
          'avatarURL': avatarURL,
          'userName': userName,
          'id': 'Comment $len',
          'likes': [],
        })
        .then((value) async {});
  }

  _showBottomSheet(BuildContext context, String videoID) {
    final TextEditingController _textEditingController =
        TextEditingController();
    final page2 = SizedBox(
      height: MediaQuery.of(context).size.height * 3 / 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream:
                    videos.doc(videoID).collection('commentList').snapshots(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot,
                ) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: Container());
                  }
                  //Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  if (snapshot.hasData) {
                    return Text(
                      '${snapshot.data!.docs.length} Comments',
                      style: const TextStyle(fontSize: 18),
                    );
                  }
                  return Container();
                },
              ),
            ],
          ),
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream: videos.doc(videoID).collection('commentList').snapshots(),
              builder: (
                BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot,
              ) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: Container());
                }
                //Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            final item = snapshot.data!.docs[index];
                            return Column(
                              children: [
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          '${item['avatarURL']}',
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${item['userName']}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black38,
                                            ),
                                          ),
                                          SizedBox(
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                3 /
                                                4,
                                            child: Text(
                                              '${item['content']}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ),
                                          Text(
                                            item['createdOn'] == null
                                                ? DateTime.now().toString()
                                                : DateFormat.yMMMd()
                                                    .add_jm()
                                                    .format(
                                                      item['createdOn']
                                                          .toDate(),
                                                    ),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black38,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        child: Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                VideoServices.likeComment(
                                                  videoID,
                                                  item['id'],
                                                );
                                              },
                                              child: Icon(
                                                Icons.favorite,
                                                color:
                                                    snapshot
                                                            .data!
                                                            .docs[index]['likes']
                                                            .contains(uid)
                                                        ? Colors.red
                                                        : Colors.grey,
                                              ),
                                            ),
                                            Text('${item['likes'].length}'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
                return Container();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _textEditingController,
                textAlignVertical: TextAlignVertical.bottom,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: MyColors.thirdColor,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: "Comment here ...",
                  suffixIcon: IconButton(
                    onPressed: () {
                      sendComment(_textEditingController.text, videoID);
                      _textEditingController.text = '';
                    },
                    icon: Icon(Icons.send_rounded, color: MyColors.thirdColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    //_scaffoldKey.currentState.showBottomSheet((context) => null);
    showModalBottomSheet<void>(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
      ),
      //enableDrag: true,
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return page2;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('videos')
                  .where('id', isEqualTo: videoID)
                  .limit(1)
                  .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              final Video item = Video.fromSnap(snapshot.data!.docs[0]);
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        VideoPlayerItem(videoUrl: item.videoUrl),
                        Column(
                          children: [
                            const SizedBox(height: 100),
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        left: 20,
                                        bottom: 10,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            '@ ${item.username}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            item.caption,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.white60,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const Icon(
                                                CupertinoIcons.double_music_note,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                item.songName,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 80,
                                    margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height / 5,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        buildProfile(item.profilePhoto),
                                        Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                VideoServices.likeVideo(item.id);
                                              },
                                              child: Icon(
                                                Icons.favorite,
                                                size: 25,
                                                color:
                                                    snapshot
                                                            .data!
                                                            .docs[0]['likes']
                                                            .contains(uid)
                                                        ? Colors.red
                                                        : Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 7),
                                            Text(
                                              '${item.likes.length}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                _showBottomSheet(
                                                  context,
                                                  item.id,
                                                );
                                              },
                                              child: const Icon(
                                                CupertinoIcons
                                                    .chat_bubble_text_fill,
                                                size: 25,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 7),
                                            StreamBuilder<QuerySnapshot>(
                                              stream:
                                                  videos
                                                      .doc(item.id)
                                                      .collection('commentList')
                                                      .snapshots(),
                                              builder: (
                                                BuildContext context,
                                                AsyncSnapshot<QuerySnapshot>
                                                snapshot,
                                              ) {
                                                if (snapshot.hasError) {
                                                  return const Text(
                                                    'Something went wrong',
                                                  );
                                                }
                                                //Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                                                if (snapshot.hasData) {
                                                  return Text(
                                                    '${snapshot.data!.docs.length}',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  );
                                                }
                                                return Container();
                                              },
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                showOptionsDialog(
                                                  context,
                                                  item.videoUrl,
                                                );
                                              },
                                              child: const Icon(
                                                Icons.reply,
                                                size: 25,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 7),
                                          ],
                                        ),
                                        CircleAnimation(
                                          child: buildMusicAlbum(
                                            item.profilePhoto,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 20,
                          left: 20,
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  showOptionsDialog(BuildContext context, String url) {
    return showDialog(
      context: context,
      builder:
          (context) => SimpleDialog(
            children: [
              SimpleDialogOption(
                onPressed: () {
                  //StorageServices.saveFile(url);
                  Navigator.of(context).pop();
                },
                child: Row(
                  children: const [
                    Icon(Icons.save_alt),
                    Padding(
                      padding: EdgeInsets.all(7.0),
                      child: Text('Save', style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(),
                child: Row(
                  children: const [
                    Icon(Icons.cancel, color: Colors.red),
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
}
