import 'package:flutter/material.dart';
import '../services/cart_service.dart';


class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;
  double _total = 0;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get total => _total;
  int get itemCount => _items.length;

  void init(String userId) {
    _loadCart(userId);
  }

  Future<void> _loadCart(String userId) async {
    _setLoading(true);
    _error = null;

    try {
      _cartService.getCart(userId).listen(
        (items) {
          _items = items;
          _calculateTotal();
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

  Future<void> addToCart(String userId, CartItem item) async {
    _setLoading(true);
    _error = null;

    try {
      await _cartService.addToCart(userId, item);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> updateQuantity(
    String userId,
    String itemId,
    int quantity,
  ) async {
    if (quantity < 1) {
      await removeFromCart(userId, itemId);
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      await _cartService.updateQuantity(userId, itemId, quantity);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> removeFromCart(String userId, String itemId) async {
    _setLoading(true);
    _error = null;

    try {
      await _cartService.removeFromCart(userId, itemId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> clearCart(String userId) async {
    _setLoading(true);
    _error = null;

    try {
      await _cartService.clearCart(userId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  void _calculateTotal() {
    _total = _items.fold(
      0,
      (total, item) => total + (item.price * item.quantity),
    );
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
