import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';

class CartItem {
  final String id;
  final String productId;
  final String productName;
  final double price;
  final String imageUrl;
  final int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
    );
  }

  CartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    double? price,
    String? imageUrl,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user's cart
  Stream<List<CartItem>> getCart(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.cartCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return CartItem.fromMap(data);
      }).toList();
    });
  }

  // Add item to cart
  Future<void> addToCart(String userId, CartItem item) async {
    final existingItem = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.cartCollection)
        .where('productId', isEqualTo: item.productId)
        .get();

    if (existingItem.docs.isNotEmpty) {
      final doc = existingItem.docs.first;
      final currentQuantity = doc.data()['quantity'] ?? 0;
      await doc.reference.update({
        'quantity': currentQuantity + item.quantity,
      });
    } else {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.cartCollection)
          .add(item.toMap());
    }
  }

  // Update cart item quantity
  Future<void> updateQuantity(
    String userId,
    String itemId,
    int quantity,
  ) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.cartCollection)
        .doc(itemId)
        .update({'quantity': quantity});
  }

  // Remove item from cart
  Future<void> removeFromCart(String userId, String itemId) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.cartCollection)
        .doc(itemId)
        .delete();
  }

  // Clear cart
  Future<void> clearCart(String userId) async {
    final cartRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.cartCollection);

    final cartItems = await cartRef.get();

    final batch = _firestore.batch();
    for (var doc in cartItems.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Get cart total
  Future<double> getCartTotal(String userId) async {
    final cartItems = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.cartCollection)
        .get();

    return cartItems.docs.fold<double>(
      0,
      (total, doc) =>
          total +
          ((doc.data()['price'] ?? 0.0) * (doc.data()['quantity'] ?? 0)),
    );
  }
}
