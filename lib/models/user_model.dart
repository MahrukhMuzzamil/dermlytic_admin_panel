// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  String userID;
  String name;
  String role;
  String? branchId; // Association with clinic/branch
  String? specialization; // Doctor's specialization
  String? phoneNumber; // Contact info
  String? email; // Email
  UserModel({
    required this.userID,
    required this.name,
    required this.role,
    this.branchId,
    this.specialization,
    this.phoneNumber,
    this.email,
  });
  

  UserModel copyWith({
    String? userID,
    String? name,
    String? role,
    String? branchId,
    String? specialization,
    String? phoneNumber,
    String? email,
  }) {
    return UserModel(
      userID: userID ?? this.userID,
      name: name ?? this.name,
      role: role ?? this.role,
      branchId: branchId ?? this.branchId,
      specialization: specialization ?? this.specialization,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userID': userID,
      'name': name,
      'role': role,
      'branchId': branchId,
      'specialization': specialization,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userID: map['userID'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
      branchId: map['branchId'] as String?,
      specialization: map['specialization'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      email: map['email'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'UserModel(userID: $userID, name: $name, role: $role, branchId: $branchId, specialization: $specialization, phoneNumber: $phoneNumber, email: $email)';

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.userID == userID &&
      other.name == name &&
      other.role == role &&
      other.branchId == branchId &&
      other.specialization == specialization &&
      other.phoneNumber == phoneNumber &&
      other.email == email;
  }

  @override
  int get hashCode => userID.hashCode ^ name.hashCode ^ role.hashCode ^ branchId.hashCode ^ specialization.hashCode ^ phoneNumber.hashCode ^ email.hashCode;
}
