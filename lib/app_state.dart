// app_state.dart - Simple state management with ChangeNotifier
import 'package:flutter/material.dart';
import 'models.dart';
import 'services/api_service.dart';

class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;
  User? _currentUser;
  List<CartItem> _cartItems = [];
  List<RentalCartItem> _rentalCartItems = [];
  List<Product> _favorites = [];
  List<Product> _products = [];
  List<Order> _orders = [];
  List<RentalOrder> _rentalOrders = [];
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  AppState() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await fetchProducts();
  }

  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;
  List<CartItem> get cartItems => _cartItems;
  List<RentalCartItem> get rentalCartItems => _rentalCartItems;
  List<Product> get favorites => _favorites;
  List<Product> get products => _products;
  List<Order> get orders => _orders;
  List<RentalOrder> get rentalOrders => _rentalOrders;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<String> get categories {
    final categories = _products
        .map((product) => product.category)
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    return ['Semua', ...categories];
  }

  int get cartCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + item.total);
  int get rentalCartCount => _rentalCartItems.fold(0, (sum, item) => sum + item.quantity);
  double get rentalCartTotal => _rentalCartItems.fold(0, (sum, item) => sum + item.total);

  Future<String?> login(String email, String password) async {
    try {
      final user = await ApiService.login(email, password);
      _isLoggedIn = true;
      _currentUser = user;
      await fetchOrders();
      notifyListeners();
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    _isLoggedIn = false;
    _currentUser = null;
    _cartItems = [];
    _rentalCartItems = [];
    _favorites = [];
    _orders = [];
    notifyListeners();
  }

  Future<String?> register(String name, String email, String password) async {
    try {
      final user = await ApiService.register(name, email, password);
      _isLoggedIn = true;
      _currentUser = user;
      _orders = [];
      notifyListeners();
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  void addToCart(Product product) {
    final existing = _cartItems.where((i) => i.product.id == product.id);
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      _cartItems.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void updateCartQuantity(String productId, int quantity) {
    final item = _cartItems.firstWhere((i) => i.product.id == productId);
    if (quantity <= 0) {
      removeFromCart(productId);
    } else {
      item.quantity = quantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems = [];
    notifyListeners();
  }

  // Rental Cart Methods
  void addToRentalCart(Product product, DateTime startDate, DateTime endDate) {
    final existing = _rentalCartItems.where((i) => i.product.id == product.id);
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      _rentalCartItems.add(RentalCartItem(
        product: product,
        rentalStartDate: startDate,
        rentalEndDate: endDate,
      ));
    }
    notifyListeners();
  }

  void removeFromRentalCart(String productId) {
    _rentalCartItems.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void updateRentalCartQuantity(String productId, int quantity) {
    final item = _rentalCartItems.firstWhere((i) => i.product.id == productId);
    if (quantity <= 0) {
      removeFromRentalCart(productId);
    } else {
      item.quantity = quantity;
      notifyListeners();
    }
  }

  void clearRentalCart() {
    _rentalCartItems = [];
    notifyListeners();
  }

  Future<String?> placeRentalOrder(String address) async {
    if (_rentalCartItems.isEmpty) {
      return 'Keranjang sewa kosong.';
    }

    if (_currentUser == null) {
      return 'Silakan login terlebih dahulu.';
    }

    try {
      final newOrder = await ApiService.createOrder(
        courier: 'JNE',
        address: address,
        phone: _currentUser!.phone.isNotEmpty
            ? _currentUser!.phone
            : '081234567890',
        receiverName: _currentUser!.name,
        paymentMethod: 'transfer',
        items: _rentalCartItems
            .map((item) => CartItem(product: item.product, quantity: item.quantity))
            .toList(),
      );
      _orders.insert(0, newOrder);
      clearRentalCart();
      notifyListeners();
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  void uploadPaymentProof(String orderId, String paymentProof) {
    final index = _rentalOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _rentalOrders[index] = RentalOrder(
        id: _rentalOrders[index].id,
        items: _rentalOrders[index].items,
        total: _rentalOrders[index].total,
        status: 'Diproses',
        createdAt: _rentalOrders[index].createdAt,
        rentalStartDate: _rentalOrders[index].rentalStartDate,
        rentalEndDate: _rentalOrders[index].rentalEndDate,
        address: _rentalOrders[index].address,
        paymentProof: paymentProof,
      );
      notifyListeners();
    }
  }

  void confirmRentalReceived(String orderId) {
    final order = _rentalOrders.firstWhere((o) => o.id == orderId);
    _rentalOrders[_rentalOrders.indexOf(order)] = RentalOrder(
      id: order.id,
      items: order.items,
      total: order.total,
      status: 'Selesai',
      createdAt: order.createdAt,
      rentalStartDate: order.rentalStartDate,
      rentalEndDate: order.rentalEndDate,
      address: order.address,
      paymentProof: order.paymentProof,
    );
    notifyListeners();
  }

  void toggleFavorite(Product product) {
    if (_favorites.any((p) => p.id == product.id)) {
      _favorites.removeWhere((p) => p.id == product.id);
    } else {
      _favorites.add(product);
    }
    notifyListeners();
  }

  bool isFavorite(String productId) => _favorites.any((p) => p.id == productId);

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    List<Product> result = _products;
    if (_selectedCategory != 'Semua') {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return result;
  }

  List<Product> get rentalProducts {
    return _products.where((p) => p.isRentable && p.isAvailable).toList();
  }

  List<Product> get buyOnlyProducts {
    return _products.where((p) => !p.isRentable && p.isAvailable).toList();
  }

  Future<String?> fetchProducts({String? category, String? search}) async {
    try {
      _products = await ApiService.fetchProducts(category: category, search: search);
      notifyListeners();
      return null;
    } catch (error) {
      _products = DummyData.products;
      notifyListeners();
      return error.toString();
    }
  }

  Future<String?> fetchOrders() async {
    if (!_isLoggedIn) {
      _orders = [];
      return null;
    }

    try {
      _orders = await ApiService.fetchOrders();
      notifyListeners();
      return null;
    } catch (error) {
      _orders = [];
      notifyListeners();
      return error.toString();
    }
  }

  Future<String?> placeOrder(
    String courier,
    String address, {
    String? city,
    String? district,
    String? paymentMethod,
    String? paymentProof,
  }) async {
    if (_cartItems.isEmpty) {
      return 'Keranjang kosong.';
    }

    if (_currentUser == null) {
      return 'Silakan login terlebih dahulu.';
    }

    try {
      var newOrder = await ApiService.createOrder(
        courier: courier,
        address: address,
        phone: _currentUser!.phone.isNotEmpty
            ? _currentUser!.phone
            : '081234567890',
        receiverName: _currentUser!.name,
        paymentMethod: paymentMethod ?? 'transfer',
        items: _cartItems,
        shippingCity: city,
        shippingDistrict: district,
        paymentProof: paymentProof,
      );
      if (paymentProof != null) {
        newOrder = newOrder.copyWith(paymentProof: paymentProof);
      }
      _orders.insert(0, newOrder);
      clearCart();
      notifyListeners();
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  void returnRentalOrder(String orderId) {
  final index = _rentalOrders.indexWhere((o) => o.id == orderId);

  if (index != -1) {
    final old = _rentalOrders[index];

    _rentalOrders[index] = RentalOrder(
      id: old.id,
      items: old.items,
      total: old.total,
      status: 'Dikembalikan',
      createdAt: old.createdAt,
      rentalStartDate: old.rentalStartDate,
      rentalEndDate: old.rentalEndDate,
      address: old.address,
    );

    notifyListeners();
  }
}

  void confirmReceived(String orderId) {
    final order = _orders.firstWhere((o) => o.id == orderId);
    _orders[_orders.indexOf(order)] = Order(
      id: order.id,
      items: order.items,
      total: order.total,
      status: 'Selesai',
      createdAt: order.createdAt,
      courier: order.courier,
      trackingNumber: order.trackingNumber,
      address: order.address,
    );
    notifyListeners();
  }

  void updateProfile({String? name, String? phone, String? avatarUrl}) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: name,
        phone: phone,
        avatarUrl: avatarUrl,
      );
      notifyListeners();
    }
  }

  void updateAddress(String newAddress) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(address: newAddress);
      notifyListeners();
    }
  }

  bool changePassword(String currentPassword, String newPassword) {
    if (_currentUser != null && _currentUser!.password == currentPassword) {
      _currentUser = _currentUser!.copyWith(password: newPassword);
      notifyListeners();
      return true;
    }
    return false;
  }
}
