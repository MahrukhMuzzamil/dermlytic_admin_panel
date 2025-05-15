// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  String userID;
  String name;
  String role;
  UserModel({
    required this.userID,
    required this.name,
    required this.role,
  });
  

  UserModel copyWith({
    String? userID,
    String? name,
    String? role,
  }) {
    return UserModel(
      userID: userID ?? this.userID,
      name: name ?? this.name,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userID': userID,
      'name': name,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userID: map['userID'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'UserModel(userID: $userID, name: $name, role: $role)';

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.userID == userID &&
      other.name == name &&
      other.role == role;
  }

  @override
  int get hashCode => userID.hashCode ^ name.hashCode ^ role.hashCode;
}
