import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_instaclone/services/prefs_service.dart';


class FileService {
  static final _storage = FirebaseStorage.instance.ref();
  static final folder_post = "post_images";
  static final folder_user = "post_images";

  static Future<String?> uploadPostImage(File _image) async {
    String? uid=await Prefs.loadUserId();
    String img_name = uid!+"_"+DateTime.now().toString();
    Reference firebaseStorageRef = _storage.child(folder_post).child(img_name);
    UploadTask uploadTask = firebaseStorageRef.putFile(_image);
    if (uploadTask != null) {
      final String imageUrl = await (await uploadTask).ref.getDownloadURL();
      print(imageUrl);
      return imageUrl;
    }
    return null;
  }
  static Future<String?> uploadUserImage(File _image) async {
    String? uid=await Prefs.loadUserId();
    String img_name=uid!;
    // String img_name = "image_" + DateTime.now().toString();
    Reference firebaseStorageRef = _storage.child(folder_user).child(img_name);
    UploadTask uploadTask = firebaseStorageRef.putFile(_image);
    if (uploadTask != null) {
      final String imageUrl = await (await uploadTask).ref.getDownloadURL();
      print(imageUrl);
      return imageUrl;
    }
    return null;
  }
}