import 'dart:convert';

class BundleModel {
  int sessions;
  double price;
  double discount;

  BundleModel({
    required this.sessions,
    required this.price,
    required this.discount,
  });

  BundleModel copyWith({
    int? sessions,
    double? price,
    double? discount,
  }) {
    return BundleModel(
      sessions: sessions ?? this.sessions,
      price: price ?? this.price,
      discount: discount ?? this.discount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sessions': sessions,
      'price': price,
      'discount': discount,
    };
  }

  factory BundleModel.fromMap(Map<String, dynamic> map) {
    return BundleModel(
      sessions: map['sessions'] as int,
      price: map['price'] as double,
      discount: map['discount'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory BundleModel.fromJson(String source) => BundleModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'BundleModel(sessions: $sessions, price: $price, discount: $discount)';

  @override
  bool operator ==(covariant BundleModel other) {
    if (identical(this, other)) return true;

    return other.sessions == sessions && other.price == price && other.discount == discount;
  }

  @override
  int get hashCode => sessions.hashCode ^ price.hashCode ^ discount.hashCode;
}
