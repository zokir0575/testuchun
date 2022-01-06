class User {
  String uid = "";
  String fullName = "";
  String email = "";
  String password = "";
  String img_url = "";

  String deviceId = "";
  String deviceType = "";
  String deviceToken = "";

  bool followed = false;
  int followersCount = 0;
  int followingCount = 0;

  User({this.fullName, this.email, this.password});

  User.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        fullName = json['fullname'],
        email = json['email'],
        password = json['password'],
        img_url = json['img_url'],
        deviceId = json['device_id'],
        deviceType = json['device_type'],
        deviceToken = json['device_token'];

  Map<String, dynamic> toJson() => {
        'uid': uid, //buyam user
        'fullname': fullName,
        'email': email,
        'password': password,
        'img_url': img_url,
        'device_id': deviceId,
        'device_type': deviceType,
        'device_token': deviceToken,
      };
  @override
  bool operator ==(other) {
    return (other is User) && other.uid == uid;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}
