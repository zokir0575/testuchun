
// ignore_for_file: must_be_immutable, invalid_use_of_visible_for_testing_member

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_instaclone/model/post_model.dart';
import 'package:flutter_instaclone/services/data_service.dart';
import 'package:flutter_instaclone/services/file_service.dart';
import 'package:image_picker/image_picker.dart';
class MyUploadPage extends StatefulWidget {
  PageController pageController;
  MyUploadPage({Key? key,required this.pageController}) : super(key: key);

  @override
  _MyUploadPageState createState() => _MyUploadPageState();
}

class _MyUploadPageState extends State<MyUploadPage> {
  bool isLoading=false;
  File? _image;
  var captionController=TextEditingController();
  final ImagePicker _picker = ImagePicker();

  _imgFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = File(image!.path);
    });
  }
  _imgFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = File(image!.path);
    });
  }
  _uploadNewPost(){
    String caption=captionController.text.trim();
    if(caption.isEmpty)return;
    if(_image==null)return;
    _apiPostImage();

  }
  _apiPostImage(){
    setState(() {
      isLoading=true;
    });
    FileService.uploadPostImage(_image!).then((downloadUrl) => {
      _resPostImage(downloadUrl!),

    });
  }
  _resPostImage(String downloadUrl){
    String caption=captionController.text.toString().trim();
    Post post=Post(caption: caption,img_post: downloadUrl);
    _apiStorePost(post);
  }
  _apiStorePost(Post post) async{
    Post posted=await DataService.storePost(post);
    DataService.storeFeed(posted).then((value)=>{
      _moveToFeed()
    });

  }
  _moveToFeed(){
    setState(() {
      isLoading=false;
    });
    captionController.text="";
    _image=null;

    widget.pageController.animateToPage(0,
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Photo Library'),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("Upload", style: TextStyle(color: Colors.black, fontFamily: 'Billabong', fontSize: 25),
        ),
        actions: [
          IconButton(
            onPressed: (){
              _uploadNewPost();

            },
            icon: const Icon(Icons.drive_folder_upload, color: Color.fromRGBO(245, 96, 64, 1),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: (){
                      _showPicker(context);
                    },
                    child: Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.width,
                        color: Colors.grey.withOpacity(0.4),
                        child: _image==null ?  const Center(
                          child: Icon(Icons.add_a_photo, size: 60, color: Colors.grey),
                        ):Stack(
                          children: [
                            Image.file(_image!, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                            Container(
                              width: double.infinity,
                              color: Colors.black12,
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: (){
                                      setState(() {
                                        _image=null;
                                      });
                                    },
                                    icon: const Icon(Icons.highlight_remove),
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10,left: 10,right: 10),
                    child: TextField(
                      controller: captionController,
                      style: const TextStyle(color: Colors.black),
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: "Caption",
                        hintStyle: TextStyle(fontSize: 17,color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          isLoading ? const Center(
            child: CircularProgressIndicator(),

          ):const SizedBox.shrink(),
        ],
      ),
    );
  }
}
