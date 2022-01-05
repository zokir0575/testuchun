import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_instaclone/model/post_model.dart';
import 'package:flutter_instaclone/services/data_service.dart';
import 'package:flutter_instaclone/services/utils_service.dart';
class MyFeedPage extends StatefulWidget {
  PageController pageController;
  MyFeedPage({this.pageController, pagecontroller});
  @override
  _MyFeedPageState createState() => _MyFeedPageState();
}

class _MyFeedPageState extends State<MyFeedPage> {
  List<Post> items = [];
  bool isLoading = false;

  void _apiLoadFeeds(){
    DataService.loadFeeds().then((value) => {
      _resLoadFeeds(value)
    });
  }

  void _resLoadFeeds(List<Post> posts){
    setState(() {
      items = posts;
    });
  }

  void _apiPostLike(Post post)async{
    setState(() {
      isLoading = true;
    });
    await DataService.likePost(post, true);
    setState(() {
      isLoading = false;
      post.liked = true;
    });
  }

  void _apiPostUnlike(Post post)async{
    setState(() {
      isLoading = true;
    });
    await DataService.likePost(post, false);
    setState(() {
      isLoading = false;
      post.liked = false;
    });
  }

  _actionRemovePost(Post post)async{
    var result = await Utils.dialogCommon(context, "Instagram", "Do you want to delete this post?", false);
    if(result !=null && result) {
      DataService.removePost(post).then((value) => {
        _apiLoadFeeds()
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _apiLoadFeeds();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Instagram", style: TextStyle(color: Colors.black, fontSize: 45, fontFamily: "Billabong"),),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: (){
              widget.pageController.animateToPage(2, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
            },
            icon: Icon(Icons.add_a_photo, color: Colors.black,),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, index){
              return _itemOfPost(items[index]);
            },
          ),
          isLoading ?
              Center(
                child: CircularProgressIndicator(),
              ) : SizedBox.shrink(),
        ],
      ),
    );
  }
  Widget _itemOfPost(Post post){
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Divider(),
          //#user info
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image(
                        image: AssetImage("assets/images/ic_person.png"),
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 10,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(post.fullname, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                        Text(post.date, style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),),
                      ],
                    ),
                  ],
                ),
                post.mine ?
                IconButton(
                    onPressed:(){
                      _actionRemovePost(post);
                    },
                    icon: Icon(SimpleLineIcons.options),
                ) : SizedBox.shrink(),
              ],
            ),
          ),
          //#image
          CachedNetworkImage(
            width:  MediaQuery.of(context).size.width,
            height:  MediaQuery.of(context).size.width,
            imageUrl: post.img_post,
            placeholder: (context, url) => Center(child: CircularProgressIndicator(),),
            errorWidget: (context, url, error) => Icon(Icons.error),
            fit: BoxFit.cover,
          ),          //#like share
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: (){
                        if(!post.liked){
                          _apiPostLike(post);
                        }else{
                          _apiPostUnlike(post);
                        }
                      },
                      icon: post.liked ?
                          Icon(
                            FontAwesome.heart,
                            color: Colors.red,
                          ) : Icon(FontAwesome.heart_o),
                  ),
                  IconButton(
                      onPressed: (){},
                      icon: Icon(Icons.share_outlined),
                  ),
                ],
              )
            ],
          ),
          //#caption
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: RichText(
              softWrap: true,
              overflow: TextOverflow.visible,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: " ${post.caption}",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}