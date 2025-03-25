import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

import '../../views/widgets/snack_bar.dart';
import '../model/video.dart';

class StorageServices {
  //Upload Image to Storage and get link
  static Future<String> uploadImage(File? imageFileX) async {
    String fileName = const Uuid().v1();
    String currentUid = FirebaseAuth.instance.currentUser!.uid;
    var ref = FirebaseStorage.instance
        .ref()
        .child('images')
        .child(currentUid)
        .child('$fileName.jpg');
    var uploadTask = await ref.putFile(imageFileX!);
    String imageURL = await uploadTask.ref.getDownloadURL();
    return imageURL;
  }

  //nén video
  static compressVideo(String videoPath) async {
    try {
      final compressedVideo = await VideoCompress.compressVideo(
        videoPath,
        quality: VideoQuality.MediumQuality,
      );
      return compressedVideo!.file;
    } catch (e) {
      throw Exception("CompressVideo:________________________$e");
    }
  }

  //Upload Video to Storage and get link
  static Future<String> uploadVideoToStorage(
      String id, String videoPath) async {
    try {
      String currentUid = FirebaseAuth.instance.currentUser!.uid;

      Reference ref = FirebaseStorage.instance
          .ref()
          .child('videos')
          .child(currentUid)
          .child(id);

      UploadTask uploadTask = ref.putFile(await compressVideo(videoPath));
      TaskSnapshot snap = await uploadTask;
      String downloadUrl = await snap.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("uploadVideoToStorage:________________________$e");
    }
  }

  static getThumbnail(String videoPath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
    return thumbnail;
  }

  static Future<String> uploadImageToStorage(
      String id, String videoPath) async {
    String currentUid = FirebaseAuth.instance.currentUser!.uid;

    Reference ref =
    FirebaseStorage.instance.ref().child('thumbnails').child(currentUid).child(id);
    UploadTask uploadTask = ref.putFile(await getThumbnail(videoPath));
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  // upload video to firestore cloud
  static uploadVideo(BuildContext context, String songName, String caption,
      String videoPath) async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      // get id
      var allDocs = await FirebaseFirestore.instance.collection('videos').get();
      int len = allDocs.docs.length;

      String videoId = FirebaseFirestore.instance.collection("videos").doc().id;
      String videoUrl = await uploadVideoToStorage(videoId, videoPath);
      String thumbnail =
      await uploadImageToStorage("${videoId}_thumbnail", videoPath);

      Video video = Video(
        username: (userDoc.data()! as Map<String, dynamic>)['fullName'],
        uid: uid.toString(),
        id: videoId,
        likes: [],
        comments: [],
        shareCount: 0,
        songName: songName,
        caption: caption,
        videoUrl: videoUrl,
        thumbnail: thumbnail,
        profilePhoto: (userDoc.data()! as Map<String, dynamic>)['avartaURL'],
      );

      await FirebaseFirestore.instance
          .collection('videos')
          .doc(videoId)
          .set(
        video.toJson(),
      )
          .then((value) {
        Navigator.of(context).pop();
        getSnackBar(
          'Push Video',
          'Success.',
          Colors.green,
        ).show(context);
      });

      //Get.back();
    } catch (e) {
      getSnackBar('Error Uploading Video', e.toString(), Colors.redAccent);
      print(e);
    }
  }

  // static saveFile(String linkStorage) async {
  //   final tempDir = await getTemporaryDirectory();
  //   final path = '${tempDir.path}/$linkStorage';
  //   await Dio().download(linkStorage, path,
  //       onReceiveProgress: (received, total) {
  //         double? progress = received / total;
  //       });
  //   if (linkStorage.contains('.mp4')) {
  //     await GallerySaver.saveVideo(path, toDcim: true);
  //   } else if (linkStorage.contains('.jpg')) {
  //     await GallerySaver.saveImage(path, toDcim: true);
  //   }
  // }
}