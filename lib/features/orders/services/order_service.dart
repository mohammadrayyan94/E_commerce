import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../cart/services/cart_service.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final String imageUrl;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
    );
  }

  factory OrderItem.fromCartItem(CartItem cartItem) {
    return OrderItem(
      productId: cartItem.productId,
      productName: cartItem.productName,
      price: cartItem.price,
      imageUrl: cartItem.imageUrl,
      quantity: cartItem.quantity,
    );
  }
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final String? shippingAddress;
  final String? paymentMethod;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.shippingAddress,
    this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'status': status.name,
      'createdAt': createdAt,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: List<OrderItem>.from(
        (map['items'] ?? []).map((item) => OrderItem.fromMap(item)),
      ),
      total: (map['total'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? ''),
        orElse: () => OrderStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      shippingAddress: map['shippingAddress'],
      paymentMethod: map['paymentMethod'],
    );
  }
}

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user's orders
  Stream<List<Order>> getOrders(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.ordersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Order.fromMap(data);
      }).toList();
    });
  }

  // Get single order
  Future<Order?> getOrder(String userId, String orderId) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    data['id'] = doc.id;
    return Order.fromMap(data);
  }

  // Create order from cart
  Future<String> createOrder(
    String userId,
    List<CartItem> cartItems,
    String shippingAddress,
    String paymentMethod,
  ) async {
    final orderItems =
        cartItems.map((item) => OrderItem.fromCartItem(item)).toList();
    final total = cartItems.fold<double>(
      0,
      (total, item) => total + (item.price * item.quantity),
    );

    final order = Order(
      id: '',
      userId: userId,
      items: orderItems,
      total: total,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
    );

    final docRef = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.ordersCollection)
        .add(order.toMap());

    // Clear the cart after successful order creation
    final cartService = CartService();
    await cartService.clearCart(userId);

    return docRef.id;
  }

  // Update order status
  Future<void> updateOrderStatus(
    String userId,
    String orderId,
    OrderStatus status,
  ) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .update({'status': status.name});
  }

  // Cancel order
  Future<void> cancelOrder(String userId, String orderId) async {
    await updateOrderStatus(userId, orderId, OrderStatus.cancelled);
  }
}
