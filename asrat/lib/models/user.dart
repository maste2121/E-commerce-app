class User {
  int id;
  String name;
  String email;
  String role;
  String? avatarUrl; // Add this field

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    role: json['role'],
    avatarUrl: json['avatarUrl'], // map JSON if exists
  );
}
