class User {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final int planLimit;
  final int dataUsed;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.planLimit,
    required this.dataUsed,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      password: json['password'],
      confirmPassword: json['confirmPassword'],
      planLimit: json['planLimit'],
      dataUsed: json['dataUsed'],
    );
  }
}
