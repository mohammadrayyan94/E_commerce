class AppConstants {
  static const String appName = 'E-Commerce App';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String cartCollection = 'cart';

  // Routes
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String cartRoute = '/cart';
  static const String productRoute = '/product';
  static const String ordersRoute = '/orders';
  static const String profileRoute = '/profile';
  static const String addProductRoute = '/add-product';

  // Asset Paths
  static const String imagePath = 'assets/images';
  static const String iconPath = 'assets/icons';

  // Error Messages
  static const String defaultError = 'Something went wrong';
  static const String networkError = 'Please check your internet connection';
  static const String authError = 'Authentication failed';
  static const String invalidEmail = 'Please enter a valid email';
  static const String invalidPassword =
      'Password must be at least 6 characters';
  static const String passwordMismatch = 'Passwords do not match';

  // Success Messages
  static const String loginSuccess = 'Login successful';
  static const String signupSuccess = 'Account created successfully';
  static const String logoutSuccess = 'Logged out successfully';
  static const String productAdded = 'Product added successfully';
  static const String orderPlaced = 'Order placed successfully';
  static const String cartUpdated = 'Cart updated successfully';

  // Button Text
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String logout = 'Logout';
  static const String googleSignIn = 'Continue with Google';
  static const String addToCart = 'Add to Cart';
  static const String buyNow = 'Buy Now';
  static const String checkout = 'Checkout';
  static const String placeOrder = 'Place Order';
  static const String addProduct = 'Add Product';

  // Input Labels
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String productName = 'Product Name';
  static const String productDescription = 'Product Description';
  static const String productPrice = 'Price';
  static const String productImage = 'Image URL';

  // Bottom Navigation Labels
  static const String home = 'Home';
  static const String cart = 'Cart';
  static const String orders = 'Orders';
  static const String profile = 'Profile';

  // Placeholders
  static const String searchHint = 'Search products...';
  static const String emptyCart = 'Your cart is empty';
  static const String noOrders = 'No orders yet';
  static const String noProducts = 'No products available';
}
