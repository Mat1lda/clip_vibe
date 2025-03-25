import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

import '../../../components/colors.dart';
import '../../../databases/services/auth_services.dart';
import '../../../databases/services/storage_services.dart';
import '../../../databases/services/user_service.dart';
import '../../../provider/loading_model.dart';
import '../../widgets/custom_text.dart';
import '../video_page/video_people_info_screen.dart';
import 'edit_user_screen.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key}) : super(key: key);

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  // File? imageFile;

  @override
  void initState() {
    super.initState();
    // print('Current UserID:${FirebaseAuth.instance.currentUser?.uid}');
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

  Stream<QuerySnapshot> getUserImage() async* {
    final currentUserID = FirebaseAuth.instance.currentUser?.uid;
    yield* FirebaseFirestore.instance
        .collection('users')
        .where('uID', isEqualTo: currentUserID)
        .snapshots();
  }



  showLogoutDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: Colors.white,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'SIGN OUT',
                  style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Are you sure?',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SimpleDialogOption(
                onPressed: () {
                  AuthService.Logout(context: context);
                },
                child: Row(
                  children: const [
                    Icon(
                      Icons.done,
                      color: Colors.green,
                    ),
                    Padding(
                      padding: EdgeInsets.all(7.0),
                      child: Text(
                        'Yes',
                        style: TextStyle(fontSize: 18, color: Colors.green, fontFamily: "Tiktok"),
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
                        'No',
                        style: TextStyle(fontSize: 18, color: Colors.red, fontFamily: "Tiktok"),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: UserService.getUserInfo(),
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
                const SizedBox(
                  height: 5,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal:16, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.grey.withOpacity(0.1),
                    //     spreadRadius: 1,
                    //     blurRadius: 3,
                    //     offset: const Offset(0, 1),
                    //   ),
                    // ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {},
                        iconSize: 25,
                        icon: Icon(
                          Icons.menu,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () => showLogoutDialog(context),
                        iconSize: 25,
                        icon: Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // border: Border.all(
                    //   color: MyColors.mainColor,
                    //   width: 3,
                    // ),
                    // gradient: RadialGradient(
                    //   colors: [
                    //     Colors.white.withOpacity(0.1),
                    //     Colors.white.withOpacity(0.05),
                    //   ],
                    // ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          height: 100,
                          width: 100,
                          child: StreamBuilder<QuerySnapshot>(
                              stream: getUserImage(),
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
                                      return CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              MyColors.thirdColor,
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return CircleAvatar(
                                        backgroundColor: MyColors.mainColor,
                                        backgroundImage: NetworkImage(snapshot
                                            .data?.docs.first['avartaURL']),
                                      );
                                    }
                                  },
                                );
                              }),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(
                            color: Colors.cyan,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              context.read<LoadingModel>().changeLoading();
                              File? fileImage = await getImage();
                              if (fileImage == null) {
                                context.read<LoadingModel>().changeLoading();
                              } else {
                                String fileName =
                                await StorageServices.uploadImage(fileImage);
                                UserService.editUserImage(
                                    context: context, ImageStorageLink: fileName);
                                context.read<LoadingModel>().changeLoading();
                              }
                            },
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height: 20),
                // CustomText(
                //   alignment: Alignment.center,
                //   fontsize: 20,
                //   text: snapshot.data.get('fullName') == null
                //       ? ''
                //       : '${snapshot.data.get('fullName')}',
                //   fontFamily: 'Inter',
                //   color: Colors.black,
                // ),
                const SizedBox(height: 10),
                CustomText(
                  alignment: Alignment.center,
                  fontSize: 16,
                  text: '${snapshot.data.get('email')}',
                  color: Colors.black,
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            snapshot.data.get('following').length.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Colors.black),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            "Following",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade700),
                          )
                        ],
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      Column(
                        children: [
                          Text(
                            snapshot.data.get('follower').length.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Colors.black),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            "Followers",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade700),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => EditUserInfoScreen()),
                        );
                      },
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(25)),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.edit,
                                color: Colors.black,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Edit Profile",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    fontSize: 14),
                              ),
                            ],
                          )),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    InkWell(
                      onTap: () {
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //       builder: (context) => UpdatePasswordScreen()),
                        // );
                      },
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(25)),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.lock_outline,
                                color: Colors.black54,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Change Password",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                    fontSize: 14),
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 50,
                    child: TabBar(
                      controller: _tabController,
                      indicator: MaterialIndicator(
                        height: 3,
                        topLeftRadius: 0,
                        topRightRadius: 0,
                        bottomLeftRadius: 5,
                        bottomRightRadius: 5,
                        horizontalPadding: 16,
                        tabPosition: TabPosition.bottom,
                        color: Colors.black,
                      ),
                      labelColor: Colors.red,
                      unselectedLabelColor: Colors.grey.shade500,
                      tabs: const <Widget>[
                        Tab(
                          icon: Icon(Icons.person),
                          text: "Profile",
                        ),
                        Tab(
                          icon: Icon(Icons.video_collection),
                          text: "Videos",
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  height: MediaQuery.of(context).size.height - 363,
                  width: MediaQuery.of(context).size.width,
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
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
                            .where('uid', isEqualTo: uid)
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
    );
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
}