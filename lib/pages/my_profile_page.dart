import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instaclone/model/post_model.dart';
import 'package:flutter_instaclone/model/user_model.dart';
import 'package:flutter_instaclone/services/auth_service.dart';
import 'package:flutter_instaclone/services/data_service.dart';
import 'package:flutter_instaclone/services/file_service.dart';
import 'package:flutter_instaclone/services/utils_service.dart';
import 'package:image_picker/image_picker.dart';
class MyProfilePAge extends StatefulWidget {
  const MyProfilePAge({Key key}) : super(key: key);

  @override
  _MyProfilePAgeState createState() => _MyProfilePAgeState();
}

class _MyProfilePAgeState extends State<MyProfilePAge> {
  bool isLoading = false;
  int axisCount = 1;
  String fullname = "", email = "", img_url = "";
  List<Post> items = [];
  int count_posts = 0;
  int count_followers = 0;
  int count_followings = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _apiloadUser();
    _apiLoadPosts();
  }
  File _image;
  _imgFromGallery() async {
    File image = (await  ImagePicker.platform.pickImage(
        source: ImageSource.gallery, imageQuality: 50
    )) as File;

    setState(() {
      _image = image;
    });
    _apiChangePhoto();
  }
  _imgFromCamera() async {
    File image = (await ImagePicker.platform.pickImage(
        source: ImageSource.camera, imageQuality: 50
    )) as File;

    setState(() {
      _image = image;
    });
    _apiChangePhoto();
  }
  _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Pick Photo'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Take Photo'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  void _apiChangePhoto(){
    if(_image ==null) return;
    setState(() {
      isLoading = true;
    });
    FileService.uploadUserImage(_image).then((downloadUrl) => {
      _apiUpdateUser(downloadUrl)
    });
  }

  void _apiUpdateUser(String downloadUrl) async{
    User user = await DataService.loadUser();
    user.img_url = downloadUrl;
    await DataService.updateUser(user);
    _apiloadUser();
  }

  void _apiloadUser(){
    DataService.loadUser().then((value) => {
      _showUserInfo(value)
    });
  }

  _actionLogout()async{
    var result = await Utils.dialogCommon(context, "Instagram", "Do you want to log out?", false);
    if(result !=null && result) {
      AuthService.signOutUser(context);
    }
  }
  _actionRemovePost(Post post)async{
    var result = await Utils.dialogCommon(context, "Instagram", "Do you want to delete this post?", false);
    if(result !=null && result) {
      DataService.removePost(post).then((value) => {
        _apiLoadPosts()
      });
    }
  }
  void _showUserInfo(User user){
    setState(() {
      isLoading = false;
      this.fullname = user.fullname;
      this.email = user.email;
      this.img_url = user.img_url;
      this.count_followers = user.followers_count;
      this.count_followings = user.following_count;
    });
  }

  void _apiLoadPosts(){
    DataService.loadPosts().then((value) => {
      _respLoadPosts(value)
    });
  }
  void _respLoadPosts(List<Post> posts){
    setState(() {
      items = posts;
      count_posts = items.length;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: Colors.black, fontSize: 25, fontFamily: "Billabong"),),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: (){
              _actionLogout();
            },
            color: Colors.black87,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            width: double.infinity,
            child: Column(
              children: [
                //#my photos
                GestureDetector(
                  onTap: (){
                    _showPicker(context);
                  },
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(70),
                          border: Border.all(
                            width: 1.5,
                            color: Color.fromRGBO(193, 53, 132, 1),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: img_url == null || img_url.isEmpty ?Image(
                            image: AssetImage("assets/images/ic_person.png"),
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          ) : Image.network(
                            img_url,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        height: 80,
                        width: 80,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(Icons.add_circle, color: Colors.purple,),
                          ],
                        ),
                      ),
                    ],
                  ),

                ),

                //#my infos
                SizedBox(height: 10,),
                Text(fullname.toUpperCase(), style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
                SizedBox(height: 3,),
                Text(email, style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.normal),),
                SizedBox(height: 10,),
                //#my counts
                Row(
                  children: [

                    Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            Text(count_posts.toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),),
                            SizedBox(height: 5,),
                            Text("POSTS", style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.normal),),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 1, height: 20, color: Colors.grey.withOpacity(0.5),),
                    Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            Text(count_followers.toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),),
                            SizedBox(height: 5,),
                            Text("FOLLOWERS", style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.normal),),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 1, height: 20, color: Colors.grey.withOpacity(0.5),),
                    Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            Text(count_followings.toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),),
                            SizedBox(height: 5,),
                            Text("FOLLOWINGS", style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.normal),),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                //#list grid
                Container(
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: IconButton(
                            onPressed: (){
                              setState(() {
                                axisCount = 1;
                              });
                            },
                            icon: Icon(Icons.list_alt),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: IconButton(
                            onPressed: (){
                              setState(() {
                                axisCount = 2;
                              });
                            },
                            icon: Icon(Icons.grid_view),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //#my posts
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: axisCount
                    ),
                    itemCount: items.length,
                    itemBuilder: (ctx, index){
                      return _itemsOfPost(items[index]);
                    },
                  ),
                ),
              ],
            ),
          ),

          isLoading ?
              Center(
                child: CircularProgressIndicator(),
              ) : SizedBox.shrink(),
        ],
      ),

    );
  }
  Widget _itemsOfPost(Post post){
    return GestureDetector(
      onLongPress: (){
        _actionRemovePost(post);
      },
      child: Container(
        margin: EdgeInsets.all(5),
        child: Column(
          children: [
            Expanded(
              child: CachedNetworkImage(

                width: double.infinity,
                imageUrl: post.img_post,
                placeholder: (context, url) => Center(child: CircularProgressIndicator(),),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 3,
            ),
            Text(
              post.caption,
              style: TextStyle(color: Colors.black87.withOpacity(0.7)),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
