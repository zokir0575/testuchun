import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_instaclone/services/prefs_service.dart';

class FileService {
  static final _storage = FirebaseStorage.instance.ref();
  static final folder_post = "post_images";
  static final folder_user = "user_images";

  static Future<String> uploadUserImage(File _image) async {
    String uid = await Prefs.loadUserId();
    String img_name = uid;
    StorageReference firebaseStorageRef = _storage.child(folder_user).child(img_name);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    if (taskSnapshot != null) {
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print(downloadUrl);
      return downloadUrl;
    }
    return null;
  }

  static Future<String> uploadPostImage(File _image) async {
    String uid = await Prefs.loadUserId();
    String img_name = uid +"_" + DateTime.now().toString();
    StorageReference firebaseStorageRef = _storage.child(folder_post).child(img_name);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    if (taskSnapshot != null) {
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print(downloadUrl);
      return downloadUrl;
    }
    return null;
  }
}
