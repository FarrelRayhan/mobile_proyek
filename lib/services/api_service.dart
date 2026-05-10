import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models.dart';

class ApiService {
  static const String _apiBaseUrlOverride =
      String.fromEnvironment('API_BASE_URL');

  // Untuk Flutter web, gunakan localhost.
  // Untuk emulator Android, gunakan 10.0.2.2.
  static String get baseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      final cleaned = _apiBaseUrlOverride.replaceFirst(RegExp(r'/+$'), '');
      return cleaned.endsWith('/api') ? cleaned : '$cleaned/api';
    }

    return kIsWeb ? 'http://localhost:8000/api' : 'http://10.0.2.2:8000/api';
  }

  static String? _token;

  static Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static Future<void> setToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('auth_token', token);
    } else {
      await prefs.remove('auth_token');
    }
    _token = token;
  }

  static Future<User> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl/login');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final user = User.fromJson(body['user']);
      await setToken(body['access_token']);
      return user;
    }

    final message = body['message'] ?? 'Login gagal';
    throw ApiException(message.toString());
  }

  static Future<User> register(
      String name, String email, String password) async {
    final uri = Uri.parse('$baseUrl/register');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role': 'buyer',
      }),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final user = User.fromJson(body['data']);
      await setToken(body['access_token']);
      return user;
    }

    if (body is Map && body.containsKey('errors')) {
      final errors = body['errors'] as Map<String, dynamic>;
      final message = errors.values
          .expand((value) => (value as List).map((e) => e.toString()))
          .join('\n');
      throw ApiException(message);
    }

    throw ApiException('Register gagal');
  }

  static Future<void> logout() async {
    if (_token == null) return;
    final uri = Uri.parse('$baseUrl/logout');
    await http.post(uri, headers: _headers);
    await setToken(null);
  }

  static Future<User> getMe() async {
    final uri = Uri.parse('$baseUrl/me');
    final response = await http.get(uri, headers: _headers);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return User.fromJson(body['data'] ?? body['user'] ?? body);
    }

    await setToken(null);
    throw ApiException('Sesi telah berakhir, silakan login kembali.');
  }

  static Future<List<String>> fetchCategories() async {
    final uri = Uri.parse('$baseUrl/categories');
    final response = await http.get(uri, headers: _headers);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'] as List<dynamic>;
      final categories = data.map((item) => item['name'].toString()).toList();
      return ['Semua', ...categories];
    }

    return ['Semua', 'Camping', 'Hiking']; // fallback
  }

  static Future<List<CartItem>> getCart() async {
    final uri = Uri.parse('$baseUrl/cart');
    final response = await http.get(uri, headers: _headers);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'] as List<dynamic>;
      return data.map((item) => CartItem.fromJson(item)).toList();
    }
    throw ApiException('Gagal memuat keranjang');
  }

  static Future<void> addToCart(String productId, int quantity) async {
    final uri = Uri.parse('$baseUrl/cart');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'product_id': productId,
        'quantity': quantity,
        'type': 'buy',
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final bodyData = jsonDecode(response.body);
        final msg = bodyData['message'] ?? 'Gagal menambahkan ke keranjang';
        throw ApiException(msg.toString());
      } catch (e) {
        if (e is ApiException) throw e;
        throw ApiException(
            'Gagal menambahkan ke keranjang (${response.statusCode})');
      }
    }
  }

  static Future<void> updateCart(String cartId, int quantity) async {
    final uri = Uri.parse('$baseUrl/cart/$cartId');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      throw ApiException('Gagal memperbarui keranjang');
    }
  }

  static Future<void> removeFromCart(String cartId) async {
    final uri = Uri.parse('$baseUrl/cart/$cartId');
    final response = await http.delete(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw ApiException('Gagal menghapus item dari keranjang');
    }
  }

  static Future<List<Product>> getWishlist() async {
    final uri = Uri.parse('$baseUrl/wishlist');
    final response = await http.get(uri, headers: _headers);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'] as List<dynamic>;
      return data.map((item) => Product.fromJson(item['product'])).toList();
    }
    return [];
  }

  static Future<void> toggleWishlist(String productId) async {
    final uri = Uri.parse('$baseUrl/wishlist/toggle');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({'product_id': productId}),
    );

    if (response.statusCode != 200) {
      throw ApiException('Gagal mengupdate favorit');
    }
  }

  static Future<List<Product>> fetchProducts(
      {String? category, String? search}) async {
    final params = <String, String>{};
    if (category != null && category.isNotEmpty && category != 'Semua') {
      params['category'] = category;
    }
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }
    final uri = Uri.parse('$baseUrl/products').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'] as List<dynamic>;
      return data
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(body['message']?.toString() ?? 'Gagal memuat produk');
  }

  static Future<List<Order>> fetchOrders() async {
    final uri = Uri.parse('$baseUrl/orders');
    final response = await http.get(uri, headers: _headers);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'] as List<dynamic>;
      return data
          .map((item) => Order.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(body['message']?.toString() ?? 'Gagal memuat pesanan');
  }

  static Future<Order> createOrder({
    required String courier,
    required String address,
    required String phone,
    required String receiverName,
    required List<Map<String, dynamic>> itemsPayload,
    required String paymentMethod,
    String? shippingCity,
    String? shippingDistrict,
    String? postalCode,
    XFile? paymentProofFile,
    XFile? ktpFile,
  }) async {
    final uri = Uri.parse('$baseUrl/orders');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    });

    request.fields['receiver_name'] = receiverName;
    request.fields['shipping_address'] = address;
    request.fields['shipping_city'] = shippingCity ?? 'Kota Tidak Diketahui';
    request.fields['shipping_district'] =
        shippingDistrict ?? 'Kecamatan Tidak Diketahui';
    request.fields['shipping_postal_code'] = postalCode ?? '00000';
    request.fields['shipping_phone'] = phone;
    request.fields['metode_pembayaran'] = paymentMethod;
    request.fields['kurir'] = courier;

    for (int i = 0; i < itemsPayload.length; i++) {
      final item = itemsPayload[i];
      request.fields['items[$i][product_id]'] = item['product_id'].toString();
      request.fields['items[$i][qty]'] = item['qty'].toString();
      request.fields['items[$i][type]'] = item['type'].toString();
      if (item['duration'] != null) {
        request.fields['items[$i][duration]'] = item['duration'].toString();
      }
      if (item['start_date'] != null) {
        request.fields['items[$i][start_date]'] = item['start_date'].toString();
      }
    }

    if (paymentProofFile != null) {
      final bytes = await paymentProofFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'bukti_pembayaran',
        bytes,
        filename:
            paymentProofFile.name.isEmpty ? 'bukti.jpg' : paymentProofFile.name,
      ));
    }

    if (ktpFile != null) {
      final ktpBytes = await ktpFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'ktp_image',
        ktpBytes,
        filename: ktpFile.name.isEmpty ? 'ktp.jpg' : ktpFile.name,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Order.fromJson(body['data'] as Map<String, dynamic>);
    }

    try {
      final msg = body['message'] ?? body.toString();
      throw ApiException(msg.toString());
    } catch (e) {
      if (e is ApiException) throw e;
      throw ApiException('Gagal membuat pesanan (${response.statusCode})');
    }
  }

  // ─── Reviews ──────────────────────────────────────────────────────────────

  static Future<List<Review>> fetchProductReviews(String productId) async {
    final uri = Uri.parse('$baseUrl/products/$productId/reviews');
    final response = await http.get(uri, headers: _headers);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'] as List<dynamic>;
      return data
          .map((item) => Review.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static Future<bool> submitProductReview({
    required String orderId,
    required String productId,
    required int rating,
    String? comment,
  }) async {
    final uri = Uri.parse('$baseUrl/reviews/product');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'order_id': orderId,
        'product_id': productId,
        'rating': rating,
        'comment': comment ?? '',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    final body = jsonDecode(response.body);
    throw ApiException(body['message']?.toString() ?? 'Gagal mengirim ulasan');
  }

  // ─── KTP Upload ───────────────────────────────────────────────────────────

  static Future<void> submitRentalReturn({
    required String detailId,
    required String metodeReturn,
    String? resiReturn,
    required XFile fotoKondisi,
  }) async {
    final uri = Uri.parse('$baseUrl/returns/store/$detailId');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    });

    request.fields['metode_return'] = metodeReturn;
    if (resiReturn != null && resiReturn.isNotEmpty) {
      request.fields['resi_return'] = resiReturn;
    }

    final bytes = await fotoKondisi.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes(
      'foto_kondisi',
      bytes,
      filename: fotoKondisi.name.isEmpty ? 'kondisi.jpg' : fotoKondisi.name,
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) return;

    throw ApiException(
      body['message']?.toString() ?? 'Gagal mengirim pengembalian',
    );
  }

  static Future<Map<String, dynamic>> uploadKtp(XFile ktpFile) async {
    final uri = Uri.parse('$baseUrl/profile/ktp');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    });

    final bytes = await ktpFile.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes(
      'ktp_image',
      bytes,
      filename: ktpFile.name.isEmpty ? 'ktp.jpg' : ktpFile.name,
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return body['data'] as Map<String, dynamic>;
    }

    throw ApiException(body['message']?.toString() ?? 'Gagal mengunggah KTP');
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
