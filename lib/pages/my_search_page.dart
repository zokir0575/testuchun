import 'package:flutter/material.dart';
import 'package:flutter_instaclone/model/user_model.dart';
import 'package:flutter_instaclone/services/data_service.dart';
class MySearchPage extends StatefulWidget {
  const MySearchPage({Key key}) : super(key: key);

  @override
  _MySearchPageState createState() => _MySearchPageState();
}

class _MySearchPageState extends State<MySearchPage> {  bool isLoading = false;
var searchController = TextEditingController();
List<User> items = [];

void _apiSearchUsers(String keyword){
  setState(() {
    isLoading = true;
  });
  DataService.searchUsers(keyword).then((users) => {
    _respSearchUsers(users),
  });
}

void  _respSearchUsers(List<User> users){
  setState(() {
    items = users;
    isLoading = false;
  });
}

void _apiFollowUser(User someone) async{
  setState(() {
    isLoading = true;
  });
  await DataService.followUser(someone);
  setState(() {
    someone.followed = true;
    isLoading = false;
  });
  DataService.storePostsToMyFeed(someone);
}

void _apiUnfollowUser(User someone) async{
  setState(() {
    isLoading = true;
  });
  await DataService.unfollowUser(someone);
  setState(() {
    someone.followed = false;
    isLoading = false;
  });
  DataService.removePostsFromMyFeed(someone);
}

@override
void initState() {
  // TODO: implement initState
  super.initState();
  _apiSearchUsers("");
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        "Search",
        style: TextStyle(
            color: Colors.black, fontFamily: 'Billabong', fontSize: 25),
      ),
    ),

    body: Stack(
      children: [
        Container(
          padding: EdgeInsets.only(left: 20,right: 20),
          child: Column(
            children: [
              //#searchuser
              Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(7),
                ),
                height: 45,
                child: TextField(
                  style: TextStyle(color: Colors.black87),
                  controller: searchController,
                  onChanged: (input){
                    print(input);
                    _apiSearchUsers(input);
                  },
                  decoration: InputDecoration(
                    hintText: "Search",
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 15.0, color: Colors.grey),
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (ctx, index){
                    return _itemOfUser(items[index]);
                  },
                ),
              ),
            ],
          ),
        ),

        isLoading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : SizedBox.shrink(),
      ],
    ),
  );
}

Widget _itemOfUser(User user){
  return Container(
    height: 90,
    child: Row(
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
            borderRadius: BorderRadius.circular(22.5),
            child: user.imgUrl.isEmpty ? Image(
              image: AssetImage("assets/images/ic_person.png"),
              width: 45,
              height: 45,
              fit: BoxFit.cover,
            ): Image.network(
              user.imgUrl,
              width: 45,
              height: 45,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(
          width: 15,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.fullName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 3,
            ),
            Text(
              user.email,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),

        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [

              GestureDetector(
                onTap: (){
                  if(user.followed){
                    _apiUnfollowUser(user);
                  }else{
                    _apiFollowUser(user);
                  }
                },
                child: Container(
                  width: 100,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      width: 1,
                      color: Colors.grey,
                    ),
                  ),
                  child: Center(
                    child: user.followed ? Text("Following") : Text("Follow"),
                  ),
                ),
              ),

            ],
          ),
        ),

      ],
    ),
  );
}
}
