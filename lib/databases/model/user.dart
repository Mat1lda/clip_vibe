class UserModel {
  String gender;
  String fullName;
  String email;
  String age;
  String phone;
  List<String>? following;
  List<String>? follower;
  String avatarURL;

  UserModel({
    required this.gender,
    required this.email,
    required this.phone,
    required this.age,
    required this.avatarURL,
    required this.fullName,
    this.follower,
    this.following,
  });

}
