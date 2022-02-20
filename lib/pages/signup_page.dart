import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instaclone/model/user_model.dart';
import 'package:flutter_instaclone/pages/signin_page.dart';
import 'package:flutter_instaclone/services/auth_service.dart';
import 'package:flutter_instaclone/services/data_service.dart';
import 'package:flutter_instaclone/services/prefs_service.dart';
import 'package:flutter_instaclone/services/utils_service.dart';

import 'home_page.dart';
class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);
 static final String id = "signUp_page";
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var fullnameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var cpasswordController = TextEditingController();
  var isLoading = false;
  _doSignUp() {
    String fullName = fullnameController.text.toString().trim();
    String email = emailController.text.toString().trim();
    String password = passwordController.text.toString().trim();
    String cpassword= cpasswordController.text.toString().trim();
    if (fullName.isEmpty || email.isEmpty || password.isEmpty) return;
    if(cpassword!=password) {
      Utils.fireToast("Password and confirm password does not match");
      return;
    }
    setState(() {
      isLoading=true;
    });
    User1 user1=User1(fullname: fullName, email: email, password: password);
    AuthService.signUpUser(context, fullName, email, password).then((user) => {
      _getFirebaseUser(user1, user),
    });

  }
  _getFirebaseUser( User1? user1, Map<String,User?> map) async {

    setState(() {
      isLoading=false;
    });
    User? user;
    if (!map.containsKey("SUCCESS")) {
      if (map.containsKey("ERROR_EMAIL_ALREADY_IN_USE"))
        Utils.fireToast("Email already in use");
      if (map.containsKey("ERROR"))
        Utils.fireToast("Try again later");
      return;
    }
    user = map["SUCCESS"];
    if (user == null) return;
    if (user != null) {
      await Prefs.saveUserId(user.uid);
      DataService.storeUser(user1!).then((value) => {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) =>  HomePage())),
      });
    }
  }

  _callSignInPage(){
    Navigator.pushReplacementNamed(context, SignInPage.id);
  }
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end:  Alignment.bottomCenter,
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
                        Text("Instagram", style: TextStyle(color: Colors.white, fontSize: 45, fontFamily: "Billabong"),),
                        SizedBox(height: 20,),
                        //#fullname
                        Container(
                          height: 50,
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            color: Colors.white54.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: TextField(
                            controller: fullnameController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                                hintText: "Fullname",
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.white54, fontSize: 17)
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),

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
                                hintStyle: TextStyle(color: Colors.white54, fontSize: 17)
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
                                hintStyle: TextStyle(color: Colors.white54, fontSize: 17)
                            ),
                          ),
                        ),
                        //#confirm password
                        SizedBox(height: 10,),
                        Container(
                          height: 50,
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            color: Colors.white54.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: TextField(
                            controller: cpasswordController,
                            style: TextStyle(color: Colors.white),
                            obscureText: true,
                            decoration: InputDecoration(
                                hintText: "Confirm Password",
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.white54, fontSize: 17)
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        //#sign up
                        GestureDetector(
                          onTap: _doSignUp,
                          child: Container(
                            height: 50,
                            padding: EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.white54.withOpacity(0.2), width: 2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Center(
                              child: Text(
                                "Sign Up",
                                style: TextStyle(color: Colors.white, fontSize: 17),
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
                        Text("Already have an account?", style: TextStyle(color: Colors.white, fontSize: 16),),
                        SizedBox(width: 10,),
                        GestureDetector(
                          onTap: _callSignInPage,
                          child: Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),),
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
                  ) : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

}
