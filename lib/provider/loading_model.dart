import 'package:flutter/material.dart';

class LoadingModel extends ChangeNotifier {
  bool isLoading;
  bool isBack;
  bool isPushingVideo;

  LoadingModel(
      {this.isLoading = false,
        this.isBack = false,
        this.isPushingVideo = false});

  changeLoading() {
    if (isLoading == false) {
      isLoading = true;
    } else {
      isLoading = false;
    }
    notifyListeners();
  }

  changeBack() {
    if (isBack == false) {
      isBack = true;
    } else {
      isBack = false;
    }
    notifyListeners();
  }

  changePushingVideo() {
    if (isPushingVideo == false) {
      isPushingVideo = true;
    } else {
      isPushingVideo = false;
    }
    notifyListeners();
  }
}