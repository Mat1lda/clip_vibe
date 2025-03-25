import 'package:clip_vibe/views/pages/camera_page/camera_screen.dart';
import 'package:clip_vibe/views/pages/chat_page/chat_screen.dart';
import 'package:clip_vibe/views/pages/home/custom_bottom_bar.dart';
import 'package:clip_vibe/views/pages/user_page/user_info_screen.dart';
import 'package:clip_vibe/views/pages/video_page/video_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var tabIndex = 0;
  final List<Widget> list = [
    VideoScreen(),
    ChatScreen(),
    Container(),
    UserInfoScreen()
  ];

  void changeTabIndex(int index) {
    setState(() {
      tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(child: list[tabIndex]),
      bottomNavigationBar: CustomAnimatedBottomBar(
        selectedScreenIndex: tabIndex,
        onItemTap: changeTabIndex,
      ),
    );
  }
}
