import 'package:aesthetics_labs_admin/models/session_model.dart';
import 'package:aesthetics_labs_admin/services/product_service.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  RxList<ProductModel> products = <ProductModel>[].obs;
  final ProductService _productService = ProductService();
  @override
  Future<void> onInit() async {
    super.onInit();
    await getProducts();
  }

  // get all products
  Future<List<ProductModel>> getProducts() async {
    try {
      await _productService.getProducts().then((value) {
        products.value = value;
        print(value);
      });
      return products;
    } catch (e) {
      return products;
    }
  }

  // add a new product
  Future<bool> addProduct(ProductModel product) async {
    try {
      await _productService.addProduct(product);
      products.add(product);
      return true;
    } catch (e) {
      return false;
    }
  }

  // update a product
  Future<bool> updateProduct(ProductModel product) async {
    try {
      await _productService.updateProduct(product);
      products[products.indexWhere((element) => element.productId == product.productId)] = product;
      return true;
    } catch (e) {
      return false;
    }
  }

  // delete a product
  Future<bool> deleteProduct(String productId) async {
    try {
      await _productService.deleteProduct(productId);
      products.removeWhere((element) => element.productId == productId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
