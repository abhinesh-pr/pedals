class AuthCredentials {
  final String userId;
  final String password;

  AuthCredentials({
    required this.userId,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'password': password,
    };
  }

  factory AuthCredentials.fromMap(Map<String, dynamic> map) {
    return AuthCredentials(
      userId: map['userId'] ?? '',
      password: map['password'] ?? '',
    );
  }
}

class SignUpModel {
  final String fullName;
  final String userId;
  final String email;
  final String password;

  SignUpModel({
    required this.fullName,
    required this.userId,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'userId': userId,
      'email': email,
      'password': password,
    };
  }

  factory SignUpModel.fromMap(Map<String, dynamic> map) {
    return SignUpModel(
      fullName: map['fullName'] ?? '',
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }
}
