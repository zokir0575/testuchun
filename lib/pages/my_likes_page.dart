import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_instaclone/model/post_model.dart';
import 'package:flutter_instaclone/services/data_service.dart';
import 'package:flutter_instaclone/services/utils_service.dart';
class MyLikesPage extends StatefulWidget {
  const MyLikesPage({Key key}) : super(key: key);

  @override
  _MyLikesPageState createState() => _MyLikesPageState();
}

class _MyLikesPageState extends State<MyLikesPage> {
  List<Post> items = [];
  bool isLoading = false;

  void _apiLoadLikes(){
    setState(() {
      isLoading = false;
    });
    DataService.loadLikes().then((value) => {
      _respLoadLikes(value)
    });
  }

  void _respLoadLikes(List<Post> posts){
    setState(() {
      items = posts;
      isLoading = false;
    });
  }

  void _apiPostUnlike(Post post)async{
    setState(() {
      isLoading = false;
      post.liked = false;
    });
    await DataService.likePost(post, false).then((value) => {
      _apiLoadLikes()
    });
  }

  _actionRemovePost(Post post)async{
    var result = await Utils.dialogCommon(context, "Instagram", "Do you want to delete this post?", false);
    if(result !=null && result) {
      DataService.removePost(post).then((value) => {
        _apiLoadLikes()
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _apiLoadLikes();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Likes", style: TextStyle(color: Colors.black, fontSize: 32, fontFamily: "Billabong"),),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          items.length > 0 ?
          ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, index){
              return _itemOfPost(items[index]);
            },
          ) : Center(
            child: Text("No liked posts"),
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
                        Text(post.fullName, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                        Text( post.date, style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed:(){
                    _actionRemovePost(post);
                  },
                  icon: Icon(SimpleLineIcons.options),
                ),
              ],
            ),
          ),
          //#image
          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            imageUrl: post.img_post,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),          //#like share
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: (){
                      if(post.liked){
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
                    icon: Icon(FontAwesome.send),
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
