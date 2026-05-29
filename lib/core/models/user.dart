class User {
  final String id;
  final String name;
  final String email;
  final int mode;
  final int group;
  final String password;

  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.mode,
      required this.group,
      required this.password});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      mode: map['mode'],
      group: map['group'],
      password: map['password'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mode': mode,
      'group': group,
      'password': password,
    };
  }
}
