import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instaclone/pages/signin_page.dart';
import 'package:flutter_instaclone/services/prefs_service.dart';



class AuthService{
  static Future<Map<String, User?>> signInUser(BuildContext context, String email, String password) async {
    Map<String,User?> map={};
    try {
      UserCredential userCredential = await
      FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      User user = userCredential.user!;
      print(user.toString());
      map.addAll({"SUCCESS":user});
    } catch (error) {
      print(error.toString());
      map.addAll({"ERROR":null});
    }
    return map;
  }
  static Future<Map<String, User?>> signUpUser(BuildContext context, String name, String email, String password) async {
    Map<String,User?> map={};
    try {
      UserCredential userCredential = await
      FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      User user = userCredential.user!;
      map.addAll({"SUCCESS":user});
    } catch (error) {
      print(error);
      switch(error){
        case "ERROR_EMAIL_ALREADY_IN_USE":
          map.addAll({"ERROR_EMAIL_ALREADY_IN_USE":null});
          break;
        default:map.addAll({"error":null});

      }
    }
    return map;
  }
  static void signOutUser(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Prefs.removeUserId().then((value) {
      Navigator.pushReplacementNamed(context, SignInPage.id);
    });
  }
}