// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class BranchModel {
  String branchName;
  String? branchId;
  AddressModel? branchAddress;
  DateTime? openingTime;
  DateTime? closingTime;
  String? branchPhone;
  String? branchImage;
  String? branchDescription;
  int? roomsCount;
  BranchModel({
    required this.branchName,
    this.branchId,
    this.branchAddress,
    this.openingTime,
    this.closingTime,
    this.branchPhone,
    this.branchImage,
    this.branchDescription,
    this.roomsCount,
  });

  BranchModel copyWith({
    String? branchName,
    String? branchId,
    AddressModel? branchAddress,
    DateTime? openingTime,
    DateTime? closingTime,
    String? branchPhone,
    String? branchImage,
    String? branchDescription,
    int? roomsCount,
  }) {
    return BranchModel(
      branchName: branchName ?? this.branchName,
      branchId: branchId ?? this.branchId,
      branchAddress: branchAddress ?? this.branchAddress,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      branchPhone: branchPhone ?? this.branchPhone,
      branchImage: branchImage ?? this.branchImage,
      branchDescription: branchDescription ?? this.branchDescription,
      roomsCount: roomsCount ?? this.roomsCount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'branchName': branchName,
      'branchId': branchId,
      'branchAddress': branchAddress?.toMap(),
      'openingTime': openingTime?.millisecondsSinceEpoch,
      'closingTime': closingTime?.millisecondsSinceEpoch,
      'branchPhone': branchPhone,
      'branchImage': branchImage,
      'branchDescription': branchDescription,
      'roomsCount': roomsCount,
    };
  }

  factory BranchModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return BranchModel(
      branchName: map['branchName'] as String,
      branchId: documentId ?? map['branchId'],
      branchAddress: map['branchAddress'] != null ? AddressModel.fromMap(map['branchAddress'] as Map<String, dynamic>) : null,
      openingTime: map['openingTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['openingTime'] as int) : null,
      closingTime: map['closingTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['closingTime'] as int) : null,
      branchPhone: map['branchPhone'] != null ? map['branchPhone'] as String : null,
      branchImage: map['branchImage'] != null ? map['branchImage'] as String : null,
      branchDescription: map['branchDescription'] != null ? map['branchDescription'] as String : null,
      roomsCount: map['roomsCount'] != null ? map['roomsCount'] as int : 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory BranchModel.fromJson(String source) => BranchModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BranchModel(branchName: $branchName, branchId: $branchId, branchAddress: $branchAddress, openingTime: $openingTime, closingTime: $closingTime, branchPhone: $branchPhone, branchImage: $branchImage, branchDescription: $branchDescription, roomsCount: $roomsCount)';
  }

  @override
  bool operator ==(covariant BranchModel other) {
    if (identical(this, other)) return true;

    return other.branchName == branchName &&
        other.branchId == branchId &&
        other.branchAddress == branchAddress &&
        other.openingTime == openingTime &&
        other.closingTime == closingTime &&
        other.branchPhone == branchPhone &&
        other.branchImage == branchImage &&
        other.branchDescription == branchDescription &&
        other.roomsCount == roomsCount;
  }

  @override
  int get hashCode {
    return branchName.hashCode ^
        branchId.hashCode ^
        branchAddress.hashCode ^
        openingTime.hashCode ^
        closingTime.hashCode ^
        branchPhone.hashCode ^
        branchImage.hashCode ^
        branchDescription.hashCode ^
        roomsCount.hashCode;
  }
}

class AddressModel {
  String name;
  double latitude;
  double longitude;
  AddressModel({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  AddressModel copyWith({
    String? name,
    double? latitude,
    double? longitude,
  }) {
    return AddressModel(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      name: map['name'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory AddressModel.fromJson(String source) => AddressModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'AddressModel(name: $name, latitude: $latitude, longitude: $longitude)';

  @override
  bool operator ==(covariant AddressModel other) {
    if (identical(this, other)) return true;

    return other.name == name && other.latitude == latitude && other.longitude == longitude;
  }

  @override
  int get hashCode => name.hashCode ^ latitude.hashCode ^ longitude.hashCode;
}
