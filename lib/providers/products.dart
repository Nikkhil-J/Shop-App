import 'package:flutter/material.dart';
import 'dart:convert';
import 'product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favItems {
    return _items.where((e) => e.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    const url = 'https://flutter-update-62d45.firebaseio.com/products.json';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extractedData == null) return;
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            description: prodData['description'],
            id: prodId,
            imageUrl: prodData['imageUrl'],
            price: prodData['price'],
            title: prodData['title'],
            isFavorite: prodData['isFavorite']));
        _items = loadedProducts;
        notifyListeners();
      });
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) {
    const url = 'https://flutter-update-62d45.firebaseio.com/products.json';
    return http
        .post(url,
            body: json.encode({
              "title": product.title,
              "description": product.description,
              "imageUrl": product.imageUrl,
              "price": product.price,
              "isFavorite": product.isFavorite
            }))
        .then((res) {
      final newProduct = Product(
        description: product.description,
        id: json.decode(res.body)['name'],
        imageUrl: product.imageUrl,
        price: product.price,
        title: product.title,
      );
      _items.add(newProduct);
      notifyListeners();
    }).catchError((error) {
      print(error);
      throw error;
    });
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    final url = 'https://flutter-update-62d45.firebaseio.com/products/$id.json';
    await http.patch(url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price
        }));
    _items[prodIndex] = newProduct;
    notifyListeners();
  }

  void deleteProduct(String id) {
    final url = 'https://flutter-update-62d45.firebaseio.com/products/$id.json';
    http.delete(url).then((value) {
      _items.removeWhere((element) => element.id == id);
      notifyListeners();
    });
  }
}
