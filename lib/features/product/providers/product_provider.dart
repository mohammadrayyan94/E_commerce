import 'package:flutter/material.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _error;

  List<Product> get products =>
      _filteredProducts.isEmpty && _searchQuery.isEmpty
          ? _products
          : _filteredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    _setLoading(true);
    _error = null;

    try {
      _productService.getProducts().listen(
        (products) {
          _products = products;
          _filterProducts();
          _setLoading(false);
        },
        onError: (error) {
          _error = error.toString();
          _setLoading(false);
        },
      );
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> addProduct(Product product) async {
    _setLoading(true);
    _error = null;

    try {
      await _productService.addProduct(product);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    _setLoading(true);
    _error = null;

    try {
      await _productService.updateProduct(product);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    _setLoading(true);
    _error = null;

    try {
      await _productService.deleteProduct(productId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();
    _filterProducts();
  }

  void _filterProducts() {
    if (_searchQuery.isEmpty) {
      _filteredProducts = [];
    } else {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(_searchQuery) ||
            product.description.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
