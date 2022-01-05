
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_instaclone/model/post_model.dart';
import 'package:flutter_instaclone/services/data_service.dart';
import 'package:flutter_instaclone/services/file_service.dart';
import 'package:image_picker/image_picker.dart';
class MyUploadPage extends StatefulWidget {
  PageController pageController;
  MyUploadPage({this.pageController});
  @override
  _MyUploadPageState createState() => _MyUploadPageState();
}

class _MyUploadPageState extends State<MyUploadPage> {
  bool isLoading = false;
  var captionController = TextEditingController();
  File _image;
  _imgFromGallery() async {
    File image = (await  ImagePicker.platform.pickImage(
        source: ImageSource.gallery, imageQuality: 50
    )) as File;

    setState(() {
      _image = image;
    });
  }
  _imgFromCamera() async {
    File image = (await ImagePicker.platform.pickImage(
        source: ImageSource.camera, imageQuality: 50
    )) as File;

    setState(() {
      _image = image;
    });
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

  _uploadNewPost(){
    setState(() {
      isLoading = true;
    });
    String caption = captionController.text.toString().trim();
    if(caption.isEmpty) return;
    if(_image == null) return;
    _apiPostImage();
  }

  void _apiPostImage(){
    FileService.uploadPostImage(_image).then((downloadUrl) => {
      _respStorePost(downloadUrl)
    });
  }

  void _respStorePost(String downloadUrl){
    String caption = captionController.text.toString().trim();
    Post post = new Post(caption: caption, img_post: downloadUrl);
    _apiStorePost(post);
  }

  void _apiStorePost (Post post)async{
    Post posted = await DataService.storePost(post);
    DataService.storeFeed(posted).then((value) => {
      _moveToFeed()
    });
      }
  void _moveToFeed(){
    setState(() {
      isLoading = false;
    });
    captionController.text = "";
    _image = null;
    widget.pageController.animateToPage(0, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Upload", style: TextStyle(color: Colors.black, fontFamily: "Billabong", fontSize: 25),),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: (){
              _uploadNewPost();
            },
            icon: Icon(
              Icons.drive_folder_upload,
              color: Color.fromRGBO(193, 53, 132, 1),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(children: [
                    // Button : add a photo
                    GestureDetector(
                      onTap: () {
                        _showPicker(context);
                      },
                      child: Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.width,
                        color: Colors.grey.withOpacity(0.4),
                        child: _image == null
                            ? Icon(
                          Icons.add_a_photo,
                          color: Colors.grey,
                          size: 60,
                        )
                            : Stack(
                          children: [
                            // Added photo
                            Container(
                              height: double.infinity,
                              width: double.infinity,
                              child: Image.file(
                                _image,
                                fit: BoxFit.cover,
                              ),
                            ),

                            // Button : x => remove added photo
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black12.withOpacity(0.2),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  IconButton(
                                      icon: Icon(
                                        Icons.highlight_remove,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _image = null;
                                        });
                                      }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // TextField : Caption
                    Container(
                      margin: EdgeInsets.all(10),
                      child: TextField(
                        style: TextStyle(color: Colors.black),
                        controller: captionController,
                        decoration: InputDecoration(
                          hintText: 'Caption',
                          hintStyle: TextStyle(color: Colors.black38, fontSize: 17),
                        ),
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 5,
                      ),
                    ),
                  ]),
                ),          ],
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
}
