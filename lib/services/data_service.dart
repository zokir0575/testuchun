import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_instaclone/model/post_model.dart';
import 'package:flutter_instaclone/model/user_model.dart';
import 'package:flutter_instaclone/services/prefs_service.dart';
import 'package:flutter_instaclone/services/utils_service.dart';

class DataService {
  static final _firestore = Firestore.instance;

  static String folderUsers = "users";
  static String folderPosts = "posts";
  static String folderFeeds = "feeds";
  static String folderFollowing = "following";
  static String folderFollowers = "followers";

  // User Related

  static Future storeUser(User user) async {
    user.uid = await Prefs.loadUserId();
    Map<String, String> params = await Utils.deviceParams();
    print(params.toString());

    user.deviceId = params["device_id"];
    user.deviceType = params["device_type"];
    user.deviceToken = params["device_token"];

    return _firestore
        .collection(folderUsers)
        .document(user.uid)
        .setData(user.toJson());
  }

  static Future<User> loadUser() async {
    String uid = await Prefs.loadUserId();
    var value = await _firestore.collection("users").document(uid).get();
    User user = User.fromJson(value.data);

    var querySnapshot1 = await _firestore
        .collection(folderUsers)
        .document(uid)
        .collection(folderFollowers)
        .getDocuments();
    user.followersCount = querySnapshot1.documents.length;

    var querySnapshot2 = await _firestore
        .collection(folderUsers)
        .document(uid)
        .collection(folderFollowing)
        .getDocuments();
    user.followingCount = querySnapshot2.documents.length;

    return user;
  }

  static Future updateUser(User user) async {
    String uid = await Prefs.loadUserId();
    return _firestore
        .collection(folderUsers)
        .document(uid)
        .updateData(user.toJson());
  }

  static Future<List<User>> searchUsers(String keyword) async {
    List<User> users = [];
    String uid = await Prefs.loadUserId();

    var querySnapshot = await _firestore
        .collection(folderUsers)
        .orderBy("email")
        .startAt([keyword]).getDocuments();
    print(querySnapshot.documents.length);

    querySnapshot.documents.forEach((result) {
      User newUser = User.fromJson(result.data);
      if (newUser.uid != uid) {
        users.add(newUser);
      }
    });

    List<User> following = [];

    var querySnapshot2 = await _firestore
        .collection(folderUsers)
        .document(uid)
        .collection(folderFollowing)
        .getDocuments();
    querySnapshot2.documents.forEach((result) {
      following.add(User.fromJson(result.data));
    });

    for (User user in users) {
      if (following.contains(user)) {
        user.followed = true;
      } else {
        user.followed = false;
      }
    }

    return users;
  }

// Post Related

  static Future<Post> storePost(Post post) async {
    User me = await loadUser();
    post.uid = me.uid;
    post.fullName = me.fullName;
    post.imgUser = me.imgUrl;
    post.date = Utils.currentDate();

    String postId = _firestore
        .collection(folderUsers)
        .document(me.uid)
        .collection(folderPosts)
        .document()
        .documentID;
    post.id = postId;

    await _firestore
        .collection(folderUsers)
        .document(me.uid)
        .collection(folderPosts)
        .document(postId)
        .setData(post.toJson());
    return post;
  }

  static Future<Post> storeFeed(Post post) async {
    String uid = await Prefs.loadUserId();

    await _firestore
        .collection(folderUsers)
        .document(uid)
        .collection(folderFeeds)
        .document(post.id)
        .setData(post.toJson());
    return post;
  }

  static Future<List<Post>> loadFeeds() async {
    List<Post> posts = [];
    String uid = await Prefs.loadUserId();
    var querySnapshot = await _firestore
        .collection(folderUsers)
        .document(uid)
        .collection(folderFeeds)
        .getDocuments();

    querySnapshot.documents.forEach((result) {
      Post post = Post.fromJson(result.data);
      if (post.uid == uid) post.mine = true;
      posts.add(post);
    });
    return posts;
  }

  static Future<List<Post>> loadPosts() async {
    List<Post> posts = [];
    String uid = await Prefs.loadUserId();

    var querySnapshot = await _firestore
        .collection(folderUsers)
        .document(uid)
        .collection(folderPosts)
        .getDocuments();

    querySnapshot.documents.forEach((result) {
      posts.add(Post.fromJson(result.data));
    });
    return posts;
  }

  static Future<Post> likePost(Post post, bool liked) async {
    String uid = await Prefs.loadUserId();
    post.liked = liked;

    await _firestore
        .collection(folderUsers)
        .document(uid)
        .collection(folderFeeds)
        .document(post.id)
        .setData(post.toJson());

    if (uid == post.uid) {
      await _firestore
          .collection(folderUsers)
          .document(uid)
          .collection(folderPosts)
          .document(post.id)
          .setData(post.toJson());
    }
  }

  static Future<List<Post>> loadLikes() async {
    String uid = await Prefs.loadUserId();
    List<Post> posts = [];

    var querySnapshot = await _firestore
        .collection(folderUsers)
        .document(uid)
        .collection(folderFeeds)
        .where("liked", isEqualTo: true)
        .getDocuments();

    querySnapshot.documents.forEach((result) {
      Post post = Post.fromJson(result.data);
      if (post.uid == uid) post.mine = true;
      posts.add(post);
    });
    return posts;
  }

  // Follower and Following Related

  static Future<User> followUser(User someone) async {
    User me = await loadUser();

    // I followed to someone
    await _firestore
        .collection(folderUsers)
        .document(me.uid)
        .collection(folderFollowing)
        .document(someone.uid)
        .setData(someone.toJson());

    // I am in someone`s followers
    await _firestore
        .collection(folderUsers)
        .document(someone.uid)
        .collection(folderFollowers)
        .document(me.uid)
        .setData(me.toJson());

    return someone;
  }

  static Future<User> unfollowUser(User someone) async {
    User me = await loadUser();

    // I un followed to someone
    await _firestore
        .collection(folderUsers)
        .document(me.uid)
        .collection(folderFollowing)
        .document(someone.uid)
        .delete();

    // I am not in someone`s followers
    await _firestore
        .collection(folderUsers)
        .document(someone.uid)
        .collection(folderFollowers)
        .document(me.uid)
        .delete();

    return someone;
  }

  static Future storePostsToMyFeed(User someone) async {
    // Store someone`s posts to my feed

    List<Post> posts = [];
    var querySnapshot = await _firestore
        .collection(folderUsers)
        .document(someone.uid)
        .collection(folderPosts)
        .getDocuments();
    querySnapshot.documents.forEach((result) {
      var post = Post.fromJson(result.data);
      post.liked = false;
      posts.add(post);
    });

    for (Post post in posts) {
      storeFeed(post);
    }
  }

  static Future removePostsFromMyFeed(User someone) async {
    // Remove someone`s posts from my feed

    List<Post> posts = [];
    var querySnapshot = await _firestore
        .collection(folderUsers)
        .document(someone.uid)
        .collection(folderPosts)
        .getDocuments();
    querySnapshot.documents.forEach((result) {
      posts.add(Post.fromJson(result.data));
    });

    for (Post post in posts) {
      removeFeed(post);
    }
  }

  static Future removeFeed(Post post) async {
    String uid = await Prefs.loadUserId();

    return await _firestore
        .collection(folderUsers)
        .document(uid)
        .collection(folderFeeds)
        .document(post.id)
        .delete();
  }

  static Future removePost(Post post) async {
    String uid = await Prefs.loadUserId();
    await removeFeed(post);
    return await _firestore
        .collection(folderUsers)
        .document(uid)
        .collection(folderPosts)
        .document(post.id)
        .delete();
  }
}
