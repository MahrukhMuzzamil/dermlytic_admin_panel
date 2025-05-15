import 'dart:convert';
import 'package:aesthetics_labs_admin/models/product_mode.dart';
import 'package:flutter/foundation.dart';

class ProductModel {
  String title;
  String imageUrl;
  double price;
  double duration;
  double? discount;
  double? rating;
  String? beforeAfterImageUrl;
  String? feedbackIds;
  String? description;
  List<BundleModel>? bundles;
  String? productId;
  int selectedBundleIndex = 0;
  ProductModel({
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.duration,
    this.discount = 0.0,
    this.rating = 5.0,
    this.beforeAfterImageUrl,
    this.feedbackIds,
    this.description,
    this.bundles,
    this.productId,
    this.selectedBundleIndex = 0,
  });

  ProductModel copyWith({
    String? title,
    String? imageUrl,
    double? price,
    double? duration,
    double? rating,
    double? discount,
    String? beforeAfterImageUrl,
    String? feedbackIds,
    String? description,
    List<BundleModel>? bundles,
    String? productId,
    int? selectedBundleIndex,
  }) {
    return ProductModel(
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      rating: rating ?? this.rating,
      discount: discount ?? this.discount,
      beforeAfterImageUrl: beforeAfterImageUrl ?? this.beforeAfterImageUrl,
      feedbackIds: feedbackIds ?? this.feedbackIds,
      description: description ?? this.description,
      bundles: bundles ?? this.bundles,
      productId: productId ?? this.productId,
      selectedBundleIndex: selectedBundleIndex ?? this.selectedBundleIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'duration': duration,
      'rating': rating,
      'discount': discount,
      'beforeAfterImageUrl': beforeAfterImageUrl,
      'feedbackIds': feedbackIds,
      'description': description,
      'bundles': bundles?.map((x) => x.toMap()).toList(),
      "productId": productId ?? "",
      "selectedBundleIndex": selectedBundleIndex,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ProductModel(
      title: map['title'] as String,
      imageUrl: map['imageUrl'] as String,
      price: map['price'] as double,
      duration: map['duration'] as double,
      rating: map['rating'] as double,
      discount: map['discount'] as double,
      beforeAfterImageUrl: map['beforeAfterImageUrl'] != null ? map['beforeAfterImageUrl'] as String : null,
      feedbackIds: map['feedbackIds'] != null ? map['feedbackIds'] as String : null,
      description: map['description'] != null ? map['description'] as String : null,
      bundles: map['bundles'] != null
          ? List<BundleModel>.from(
              (map['bundles']).map<BundleModel?>(
                (x) => BundleModel.fromMap(
                  x as Map<String, dynamic>,
                ),
              ),
            )
          : null,
      productId: id ?? map['productId'],
      selectedBundleIndex: map['selectedBundleIndex'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductModel.fromJson(String source) => ProductModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SessionModel(title: $title, imageUrl: $imageUrl, price: $price, duration: $duration, rating: $rating, discount: $discount, beforeAfterImageUrl: $beforeAfterImageUrl, feedbackIds: $feedbackIds, description: $description, bundles: $bundles, productId: $productId, selectedBundleIndex: $selectedBundleIndex)';
  }

  @override
  bool operator ==(covariant ProductModel other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.imageUrl == imageUrl &&
        other.price == price &&
        other.duration == duration &&
        other.rating == rating &&
        other.discount == discount &&
        other.beforeAfterImageUrl == beforeAfterImageUrl &&
        other.feedbackIds == feedbackIds &&
        other.description == description &&
        listEquals(other.bundles, bundles);
  }

  @override
  int get hashCode {
    return title.hashCode ^
        imageUrl.hashCode ^
        price.hashCode ^
        duration.hashCode ^
        rating.hashCode ^
        discount.hashCode ^
        beforeAfterImageUrl.hashCode ^
        feedbackIds.hashCode ^
        description.hashCode ^
        bundles.hashCode;
  }
}
