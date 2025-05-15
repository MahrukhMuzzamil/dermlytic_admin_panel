import 'package:aesthetics_labs_admin/models/session_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ProductService {
// productModel
  final FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
  //get all products
  Future<List<ProductModel>> getProducts() async {
    List<ProductModel> products = [];
    try {
      await _firestoreInstance.collection('products').get().then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          products.add(ProductModel.fromMap(doc.data() as Map<String, dynamic>, id: doc.id));
        }
      });
      return products;
    } catch (e) {
      debugPrint(e.toString());
      return products;
    }
  }

  // add a new product
  Future<bool> addProduct(ProductModel product) async {
    try {
      await _firestoreInstance.collection('products').add(product.toMap());
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // update a product
  Future<bool> updateProduct(ProductModel product) async {
    try {
      print("before updating");
      await _firestoreInstance.collection('products').doc(product.productId).update(product.toMap());
      print("after updating");
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // delete a product
  Future<bool> deleteProduct(String productId) async {
    try {
      await _firestoreInstance.collection('products').doc(productId).delete();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // get a product
  Future<ProductModel?> getProduct(String productId) async {
    ProductModel? product;
    try {
      await _firestoreInstance.collection('products').doc(productId).get().then((DocumentSnapshot documentSnapshot) {
        product = ProductModel.fromMap(documentSnapshot.data() as Map<String, dynamic>, id: documentSnapshot.id);
      });
      return product;
    } catch (e) {
      debugPrint(e.toString());
      return product;
    }
  }
}
