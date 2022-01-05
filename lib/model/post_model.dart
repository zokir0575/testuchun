class Post{
  String uid;
  String imgUser;
  String fullName;
  String id;
  String imgPost;
  String caption;
  String date;
  bool liked = false;

  bool mine = false;

  Post({this.caption, this.imgPost});

  Post.fromJson(Map<String, dynamic> json)
  : uid = json["uid"],
    fullName = json["fullname"],
    imgUser = json["img_user"],
    id = json["id"],
    imgPost = json["img_post"],
    caption = json["caption"],
    date = json["date"],
    liked = json["liked"];

  Map<String, dynamic> toJson() =>{
    "uid" : uid,
    "fullname" : fullName,
    "img_user" : imgUser,
    "id" : id,
    "img_post" : imgPost,
    "caption" : caption,
    "date" : date,
    "liked" : liked,
  };

}