class BookingService {
  ///
  /// The userId of the currently logged user
  /// who will start the new booking
  final String? userId;

  /// The userName of the currently logged user
  /// who will start the new booking
  final String? userName;

  /// The userEmail of the currently logged user
  /// who will start the new booking
  final String? userEmail;

  /// The userPhoneNumber of the currently logged user
  /// who will start the new booking
  final String? userPhoneNumber;

  /// The id of the currently selected Service
  /// for this service will the user start the new booking

  final String? serviceId;

  ///The name of the currently selected Service
  final String serviceName;

  ///The duration of the currently selected Service

  final int serviceDuration;

  ///The price of the currently selected Service

  final int? servicePrice;

  ///The selected booking slot's starting time
  DateTime bookingStart;

  ///The selected booking slot's ending time
  DateTime bookingEnd;

  String? roomId = '1';

  String status;

  BookingService({
    this.userId,
    this.userName,
    this.userEmail,
    this.userPhoneNumber,
    this.serviceId,
    required this.serviceName,
    required this.serviceDuration,
    this.servicePrice,
    required this.bookingStart,
    required this.bookingEnd,
    this.roomId = '1',
    this.status = "pending",
  });

  BookingService copyWith(
      {String? userId,
      String? userName,
      String? userEmail,
      String? userPhoneNumber,
      String? serviceId,
      String? serviceName,
      int? serviceDuration,
      int? servicePrice,
      DateTime? bookingStart,
      DateTime? bookingEnd,
      String? status,
      String? roomId}) {
    return BookingService(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhoneNumber: userPhoneNumber ?? this.userPhoneNumber,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      serviceDuration: serviceDuration ?? this.serviceDuration,
      servicePrice: servicePrice ?? this.servicePrice,
      bookingStart: bookingStart ?? this.bookingStart,
      bookingEnd: bookingEnd ?? this.bookingEnd,
      status: status ?? this.status,
      roomId: roomId ?? this.roomId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhoneNumber': userPhoneNumber,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'serviceDuration': serviceDuration,
      'servicePrice': servicePrice,
      'bookingStart': bookingStart.millisecondsSinceEpoch,
      'bookingEnd': bookingEnd.millisecondsSinceEpoch,
      'status': status,
      'roomId': roomId,
    };
  }

  factory BookingService.fromMap(Map<String, dynamic> map) {
    return BookingService(
      userId: map['userId'] != null ? map['userId'] as String : null,
      userName: map['userName'] != null ? map['userName'] as String : null,
      userEmail: map['userEmail'] != null ? map['userEmail'] as String : null,
      userPhoneNumber: map['userPhoneNumber'] != null ? map['userPhoneNumber'] as String : null,
      serviceId: map['serviceId'] != null ? map['serviceId'] as String : null,
      serviceName: map['serviceName'] as String,
      serviceDuration: map['serviceDuration'] as int,
      servicePrice: map['servicePrice'] != null ? map['servicePrice'] as int : null,
      bookingStart: DateTime.fromMillisecondsSinceEpoch(map['bookingStart'] as int),
      bookingEnd: DateTime.fromMillisecondsSinceEpoch(map['bookingEnd'] as int),
      status: map['status'] ?? "pending",
      roomId: map['roomId'] ?? '1',
    );
  }
  BookingService.fromJson(Map<String, dynamic> json, {String? documentId})
      : userEmail = json['userEmail'] as String?,
        userPhoneNumber = json['userPhoneNumber'] as String?,
        userId = json['userId'] as String?,
        userName = json['userName'] as String?,
        bookingStart = DateTime.parse(json['bookingStart'] as String),
        bookingEnd = DateTime.parse(json['bookingEnd'] as String),
        serviceId = documentId,
        serviceName = json['serviceName'] as String,
        serviceDuration = json['serviceDuration'] as int,
        servicePrice = json['servicePrice'] as int?,
        status = json['status'] ?? "pending",
        roomId = json['roomId'] ?? '1';

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'userPhoneNumber': userPhoneNumber,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'serviceDuration': serviceDuration,
        'servicePrice': servicePrice,
        'bookingStart': bookingStart.toIso8601String(),
        'bookingEnd': bookingEnd.toIso8601String(),
        'status': status,
        'roomId': roomId,
      };

  // String toJson() => json.encode(toMap());

  // factory BookingService.fromJson(String source) => BookingService.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BookingService(userId: $userId, userName: $userName, userEmail: $userEmail, userPhoneNumber: $userPhoneNumber, serviceId: $serviceId, serviceName: $serviceName, serviceDuration: $serviceDuration, servicePrice: $servicePrice, bookingStart: $bookingStart, bookingEnd: $bookingEnd,roomId: $roomId,status: $status)';
  }

  @override
  bool operator ==(covariant BookingService other) {
    if (identical(this, other)) return true;

    return other.userId == userId &&
        other.userName == userName &&
        other.userEmail == userEmail &&
        other.userPhoneNumber == userPhoneNumber &&
        other.serviceId == serviceId &&
        other.serviceName == serviceName &&
        other.serviceDuration == serviceDuration &&
        other.servicePrice == servicePrice &&
        other.bookingStart == bookingStart &&
        other.bookingEnd == bookingEnd &&
        other.roomId == roomId &&
        other.status == status;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        userName.hashCode ^
        userEmail.hashCode ^
        userPhoneNumber.hashCode ^
        serviceId.hashCode ^
        serviceName.hashCode ^
        serviceDuration.hashCode ^
        servicePrice.hashCode ^
        bookingStart.hashCode ^
        bookingEnd.hashCode ^
        roomId.hashCode ^
        status.hashCode;
  }
}
