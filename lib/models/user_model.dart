class UserModel {
  const UserModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.dailyGoal,
  });

  final String fullName;
  final String email;
  final String password;
  final int dailyGoal;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fullName': fullName,
      'email': email,
      'password': password,
      'dailyGoal': dailyGoal,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      dailyGoal: json['dailyGoal'] as int,
    );
  }
}
