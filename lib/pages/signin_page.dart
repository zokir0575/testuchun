import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instaclone/pages/home_page.dart';
import 'package:flutter_instaclone/pages/signup_page.dart';
import 'package:flutter_instaclone/services/auth_service.dart';
import 'package:flutter_instaclone/services/prefs_service.dart';
import 'package:flutter_instaclone/services/utils_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);
  static final String id = "signIn_page";
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  var isLoading = false;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  _callSignUpPage() {
    Navigator.pushReplacementNamed(context, SignUpPage.id);
  }
  //
  //  _callHomePage() {
  //   Navigator.pushReplacementNamed(context, HomePage.id);
  // }

  _doSignIn() {
    String email = emailController.text.toString().trim();
    String password = passwordController.text.toString().trim();
    if (email.isEmpty || password.isEmpty) return;
    setState(() {
      isLoading=true;
    });

    AuthService.signInUser(context, email, password).then((user) => {
      _getFirebaseUser(user),
    });
  }

  _getFirebaseUser(Map<String, User?> map) async {
    setState(() {
      isLoading = false;
    });
    User? firebaseUser;
    if (!map.containsKey("SUCCESS")) {
      if (map.containsKey("ERROR"))
        Utils.fireToast("Check your email or password");
      return;
    }
    firebaseUser = map["SUCCESS"];
    if (firebaseUser == null) return;


    await Prefs.saveUserId(firebaseUser.uid);
    Navigator.pushReplacementNamed(context, HomePage.id);
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            height: MediaQuery
                .of(context)
                .size
                .height,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(193, 53, 132, 1),
                      Color.fromRGBO(131, 51, 180, 1),
                    ]
                )
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Instagram", style: TextStyle(
                              color: Colors.white,
                              fontSize: 45,
                              fontFamily: "Billabong"),),
                          SizedBox(height: 20,),
                          //#email
                          Container(
                            height: 50,
                            padding: EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                              color: Colors.white54.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: TextField(
                              controller: emailController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  hintText: "Email",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      color: Colors.white54, fontSize: 17)
                              ),
                            ),
                          ),

                          SizedBox(height: 10,),

                          //#password
                          Container(
                            height: 50,
                            padding: EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                              color: Colors.white54.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: TextField(
                              controller: passwordController,
                              style: TextStyle(color: Colors.white),
                              obscureText: true,
                              decoration: InputDecoration(
                                  hintText: "Password",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      color: Colors.white54, fontSize: 17)
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          //#sign in
                          GestureDetector(
                            onTap: _doSignIn,
                            child: Container(
                              height: 50,
                              padding: EdgeInsets.only(left: 10, right: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.white54.withOpacity(0.2),
                                    width: 2),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Center(
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),

                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account?", style: TextStyle(
                              color: Colors.white, fontSize: 16),),
                          SizedBox(width: 10,),
                          GestureDetector(
                            onTap: _callSignUpPage,
                            child: Text("Sign Up", style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
                isLoading ?
                Center(
                  child: CircularProgressIndicator(),
                ) : SizedBox.shrink()
              ],
            ),
          ),
        ),
      );
    }
  }







