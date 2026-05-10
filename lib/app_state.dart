// app_state.dart - Simple state management with ChangeNotifier
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  List<String> _categories = ['Semua'];

  AppState() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await ApiService.init();

    try {
      _currentUser = await ApiService.getMe();
      _isLoggedIn = true;
    } catch (e) {
      _isLoggedIn = false;
      _currentUser = null;
    }

    await Future.wait([
      fetchCategories(),
      fetchProducts(),
      if (_isLoggedIn) fetchCart(),
      if (_isLoggedIn) fetchWishlist(),
      if (_isLoggedIn) fetchOrders(),
    ]);
    notifyListeners();
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

  List<String> get categories => _categories;

  // Cached product reviews: productId -> list of reviews
  final Map<String, List<Review>> _productReviews = {};

  // Per-order per-product review left by the current user: orderId -> (productId -> Review)
  final Map<String, Map<String, Review>> _orderItemReviews = {};

  int get cartCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + item.total);
  int get rentalCartCount =>
      _rentalCartItems.fold(0, (sum, item) => sum + item.quantity);
  double get rentalCartTotal =>
      _rentalCartItems.fold(0, (sum, item) => sum + item.total);

  Future<String?> login(String email, String password) async {
    try {
      final user = await ApiService.login(email, password);
      _isLoggedIn = true;
      _currentUser = user;
      await Future.wait([
        fetchCart(),
        fetchWishlist(),
        fetchOrders(),
      ]);
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
      _cartItems = [];
      _favorites = [];
      notifyListeners();
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Future<void> fetchCart() async {
    try {
      _cartItems = await ApiService.getCart();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchWishlist() async {
    try {
      _favorites = await ApiService.getWishlist();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addToCart(Product product) async {
    try {
      await ApiService.addToCart(product.id, 1);
      await fetchCart();
    } catch (_) {}
  }

  Future<void> removeFromCart(String productId) async {
    try {
      final item = _cartItems.firstWhere((i) => i.product.id == productId);
      await ApiService.removeFromCart(item.id);
      await fetchCart();
    } catch (_) {}
  }

  Future<void> updateCartQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }
    try {
      final item = _cartItems.firstWhere((i) => i.product.id == productId);
      await ApiService.updateCart(item.id, quantity);
      await fetchCart();
    } catch (_) {}
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

  void updateAllRentalDates(DateTime startDate, DateTime endDate) {
    _rentalCartItems = _rentalCartItems
        .map((item) => RentalCartItem(
              product: item.product,
              quantity: item.quantity,
              rentalStartDate: startDate,
              rentalEndDate: endDate,
              orderDetailId: item.orderDetailId,
            ))
        .toList();
    notifyListeners();
  }

  Future<String?> placeRentalOrder(
    String address, {
    String? courier,
    String? paymentMethod,
    String? phone,
    String? receiverName,
    String? postalCode,
    String? city,
    String? district,
    XFile? paymentProofFile,
    XFile? ktpFile,
  }) async {
    if (_rentalCartItems.isEmpty) {
      return 'Keranjang sewa kosong.';
    }

    if (_currentUser == null) {
      return 'Silakan login terlebih dahulu.';
    }

    try {
      final newOrder = await ApiService.createOrder(
        courier: courier ?? 'JNE',
        address: address,
        shippingCity: city ?? 'Kota Bandung',
        shippingDistrict: district ?? 'Kecamatan',
        postalCode: postalCode ?? '40111',
        phone: phone ??
            (_currentUser!.phone.isNotEmpty
                ? _currentUser!.phone
                : '081234567890'),
        receiverName: receiverName ?? _currentUser!.name,
        paymentMethod: paymentMethod ?? 'transfer',
        paymentProofFile: paymentProofFile,
        ktpFile: ktpFile,
        itemsPayload: _rentalCartItems
            .map((item) => {
                  'product_id': item.product.id,
                  'qty': item.quantity,
                  'type': 'rent',
                  'duration': item.rentalDays,
                  'start_date':
                      item.rentalStartDate.toIso8601String().split('T')[0],
                })
            .toList(),
      );
      _orders.insert(0, newOrder);
      _syncRentalOrdersFromOrders();
      clearRentalCart();
      notifyListeners();
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  void uploadPaymentProof(String orderId, String paymentProof) {
    // Update for _rentalOrders
    final rentalIndex = _rentalOrders.indexWhere((o) => o.id == orderId);
    if (rentalIndex != -1) {
      _rentalOrders[rentalIndex] = RentalOrder(
        id: _rentalOrders[rentalIndex].id,
        items: _rentalOrders[rentalIndex].items,
        total: _rentalOrders[rentalIndex].total,
        status: 'Diproses',
        createdAt: _rentalOrders[rentalIndex].createdAt,
        rentalStartDate: _rentalOrders[rentalIndex].rentalStartDate,
        rentalEndDate: _rentalOrders[rentalIndex].rentalEndDate,
        address: _rentalOrders[rentalIndex].address,
        paymentProof: paymentProof,
        returnSubmitted: _rentalOrders[rentalIndex].returnSubmitted,
      );
      notifyListeners();
    }

    // Update for _orders
    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex] = Order(
        id: _orders[orderIndex].id,
        items: _orders[orderIndex].items,
        total: _orders[orderIndex].total,
        status: 'Diproses',
        createdAt: _orders[orderIndex].createdAt,
        courier: _orders[orderIndex].courier,
        trackingNumber: _orders[orderIndex].trackingNumber,
        address: _orders[orderIndex].address,
        paymentProof: paymentProof,
        returnSubmitted: _orders[orderIndex].returnSubmitted,
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
      returnSubmitted: order.returnSubmitted,
    );
    notifyListeners();
  }

  Future<void> toggleFavorite(Product product) async {
    try {
      await ApiService.toggleWishlist(product.id);
      await fetchWishlist();
    } catch (_) {}
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

  Future<void> fetchCategories() async {
    try {
      _categories = await ApiService.fetchCategories();
      notifyListeners();
    } catch (_) {}
  }

  Future<String?> fetchProducts({String? category, String? search}) async {
    try {
      _products =
          await ApiService.fetchProducts(category: category, search: search);
      notifyListeners();
      return null;
    } catch (error) {
      _products = [];
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
      _syncRentalOrdersFromOrders();
      _syncExistingReviewsFromOrders();
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
    XFile? paymentProofFile,
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
        itemsPayload: _cartItems
            .map((item) => {
                  'product_id': item.product.id,
                  'qty': item.quantity,
                  'type': 'buy',
                })
            .toList(),
        shippingCity: city,
        shippingDistrict: district,
        paymentProofFile: paymentProofFile,
      );
      if (paymentProofFile != null) {
        newOrder = newOrder.copyWith(paymentProof: paymentProofFile.path);
      }
      _orders.insert(0, newOrder);
      clearCart();
      notifyListeners();
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Future<String?> returnRentalOrder({
    required String orderId,
    required String detailId,
    required String metodeReturn,
    String? resiReturn,
    required XFile fotoKondisi,
  }) async {
    final index = _rentalOrders.indexWhere((o) => o.id == orderId);

    if (index != -1) {
      try {
        await ApiService.submitRentalReturn(
          detailId: detailId,
          metodeReturn: metodeReturn,
          resiReturn: resiReturn,
          fotoKondisi: fotoKondisi,
        );
      } catch (error) {
        return error.toString();
      }

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
        paymentProof: old.paymentProof,
        returnSubmitted: true,
      );

      notifyListeners();
    }

    return null;
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
      returnSubmitted: order.returnSubmitted,
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

  Future<String?> submitReview({
    required String orderId,
    required String productId,
    required int rating,
    String? comment,
  }) async {
    try {
      await ApiService.submitProductReview(
        orderId: orderId,
        productId: productId,
        rating: rating,
        comment: comment,
      );
      // Refresh product reviews cache for this product
      List<Review> reviews = [];
      try {
        reviews = await ApiService.fetchProductReviews(productId);
        _productReviews[productId] = reviews;
      } catch (_) {}

      // Recompute aggregate rating & count from fetched reviews and update local products/orders
      final int newCount = reviews.length;
      final double newAvg = newCount > 0
          ? (reviews.map((r) => r.rating).reduce((a, b) => a + b) / newCount)
          : rating.toDouble();

      void _replaceProductStats(String pid, double avg, int count) {
        // Update in _products
        final pIndex = _products.indexWhere((p) => p.id == pid);
        if (pIndex != -1) {
          final old = _products[pIndex];
          final updated = Product(
            id: old.id,
            name: old.name,
            description: old.description,
            price: old.price,
            rentalPrice: old.rentalPrice,
            imageUrl: old.imageUrl,
            category: old.category,
            rating: avg,
            reviewCount: count,
            isAvailable: old.isAvailable,
            isRentable: old.isRentable,
            sellerName: old.sellerName,
            sellerCity: old.sellerCity,
            stock: old.stock,
          );
          _products[pIndex] = updated;
        }

        // Update in orders
        for (var i = 0; i < _orders.length; i++) {
          final order = _orders[i];
          final items = order.items
              .map((item) => item.product.id == pid
                  ? CartItem(
                      id: item.id,
                      product: Product(
                        id: item.product.id,
                        name: item.product.name,
                        description: item.product.description,
                        price: item.product.price,
                        rentalPrice: item.product.rentalPrice,
                        imageUrl: item.product.imageUrl,
                        category: item.product.category,
                        rating: avg,
                        reviewCount: count,
                        isAvailable: item.product.isAvailable,
                        isRentable: item.product.isRentable,
                        sellerName: item.product.sellerName,
                        sellerCity: item.product.sellerCity,
                        stock: item.product.stock,
                      ),
                      quantity: item.quantity,
                      type: item.type,
                      rentalDays: item.rentalDays,
                      rentalStartDate: item.rentalStartDate,
                      existingReview: item.existingReview)
                  : item)
              .toList();
          _orders[i] = order.copyWith(items: items);
        }

        // Update in rental orders
        for (var i = 0; i < _rentalOrders.length; i++) {
          final rOrder = _rentalOrders[i];
          final items = rOrder.items
              .map((item) => item.product.id == pid
                  ? RentalCartItem(
                      product: Product(
                        id: item.product.id,
                        name: item.product.name,
                        description: item.product.description,
                        price: item.product.price,
                        rentalPrice: item.product.rentalPrice,
                        imageUrl: item.product.imageUrl,
                        category: item.product.category,
                        rating: avg,
                        reviewCount: count,
                        isAvailable: item.product.isAvailable,
                        isRentable: item.product.isRentable,
                        sellerName: item.product.sellerName,
                        sellerCity: item.product.sellerCity,
                        stock: item.product.stock,
                      ),
                      quantity: item.quantity,
                      rentalStartDate: item.rentalStartDate,
                      rentalEndDate: item.rentalEndDate,
                      orderDetailId: item.orderDetailId,
                    )
                  : item)
              .toList();
          _rentalOrders[i] = RentalOrder(
            id: rOrder.id,
            items: items,
            total: rOrder.total,
            status: rOrder.status,
            createdAt: rOrder.createdAt,
            rentalStartDate: rOrder.rentalStartDate,
            rentalEndDate: rOrder.rentalEndDate,
            address: rOrder.address,
            paymentProof: rOrder.paymentProof,
            returnSubmitted: rOrder.returnSubmitted,
          );
        }
      }

      _replaceProductStats(productId, newAvg, newCount);

      // Insert the submitted review into order-item review map so Orders UI can show it immediately
      final newReview = Review(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: _currentUser?.name ?? 'Anda',
        avatarUrl: _currentUser?.avatarUrl ?? 'https://i.pravatar.cc/150?img=3',
        rating: rating.toDouble(),
        comment: comment ?? '',
        createdAt: DateTime.now(),
      );

      _orderItemReviews.putIfAbsent(orderId, () => {});
      _orderItemReviews[orderId]![productId] = newReview;
      notifyListeners();

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Get cached reviews for a product. If not present, will fetch and cache.
  Future<List<Review>> fetchProductReviews(String productId) async {
    if (_productReviews.containsKey(productId)) {
      return _productReviews[productId]!;
    }
    try {
      final reviews = await ApiService.fetchProductReviews(productId);
      _productReviews[productId] = reviews;
      return reviews;
    } catch (_) {
      return [];
    }
  }

  /// Get a review submitted by the current user for a specific order item, if any.
  Review? getOrderItemReview(String orderId, String productId) {
    return _orderItemReviews[orderId]?[productId];
  }

  void _syncRentalOrdersFromOrders() {
    _rentalOrders = _orders
        .where((order) => order.items.any((item) => item.isRental))
        .map((order) {
      final rentalItems =
          order.items.where((item) => item.isRental).map((item) {
        final start = item.rentalStartDate ?? order.createdAt;
        final days = item.rentalDays ?? 1;
        return RentalCartItem(
          product: item.product,
          quantity: item.quantity,
          rentalStartDate: start,
          rentalEndDate: start.add(Duration(days: days - 1)),
          orderDetailId: item.id,
        );
      }).toList();

      final first = rentalItems.first;
      final status = order.status.toLowerCase() == 'selesai'
          ? 'Selesai'
          : order.status.toLowerCase() == 'dikirim'
              ? 'Dikirim'
              : order.status.toLowerCase() == 'menunggu'
                  ? 'Menunggu'
                  : 'Diproses';

      return RentalOrder(
        id: order.id,
        items: rentalItems,
        total: order.total,
        status: status,
        createdAt: order.createdAt,
        rentalStartDate: first.rentalStartDate,
        rentalEndDate: rentalItems
            .map((item) => item.rentalEndDate)
            .reduce((a, b) => a.isAfter(b) ? a : b),
        address: order.address,
        paymentProof: order.paymentProof,
        returnSubmitted: order.returnSubmitted,
      );
    }).toList();
  }

  void _syncExistingReviewsFromOrders() {
    for (final order in _orders) {
      for (final item in order.items) {
        final review = item.existingReview;
        if (review == null) continue;
        _orderItemReviews.putIfAbsent(order.id, () => {});
        _orderItemReviews[order.id]![item.product.id] = review;
      }
    }
  }

  Future<String?> uploadUserKtp(XFile ktpFile) async {
    try {
      final data = await ApiService.uploadKtp(ktpFile);
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          ktpImage: data['ktp_image'],
          ktpVerifiedAt: data['ktp_verified_at'],
        );
        notifyListeners();
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
