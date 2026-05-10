import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models.dart';

class ApiService {
  // Untuk Flutter web, gunakan localhost.
  // Untuk emulator Android, gunakan 10.0.2.2.
  static const String baseUrl = 'http://localhost:8000/api';

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

  static void setToken(String? token) {
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
      setToken(body['access_token']);
      return user;
    }

    final message = body['message'] ?? 'Login gagal';
    throw ApiException(message.toString());
  }

  static Future<User> register(String name, String email, String password) async {
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
      setToken(body['access_token']);
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
    setToken(null);
  }

  static Future<List<Product>> fetchProducts({String? category, String? search}) async {
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
      return data.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
    }

    throw ApiException(body['message']?.toString() ?? 'Gagal memuat produk');
  }

  static Future<List<Order>> fetchOrders() async {
    final uri = Uri.parse('$baseUrl/orders');
    final response = await http.get(uri, headers: _headers);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'] as List<dynamic>;
      return data.map((item) => Order.fromJson(item as Map<String, dynamic>)).toList();
    }

    throw ApiException(body['message']?.toString() ?? 'Gagal memuat pesanan');
  }

  static Future<Order> createOrder({
    required String courier,
    required String address,
    required String phone,
    required String receiverName,
    required List<CartItem> items,
    required String paymentMethod,
    String? shippingCity,
    String? shippingDistrict,
    String? paymentProof,
  }) async {
    final uri = Uri.parse('$baseUrl/orders');
    final bodyData = {
      'receiver_name': receiverName,
      'shipping_address': address,
      'shipping_city': shippingCity ?? 'Kota Tidak Diketahui',
      'shipping_district': shippingDistrict ?? 'Kecamatan Tidak Diketahui',
      'shipping_postal_code': '00000',
      'shipping_phone': phone,
      'metode_pembayaran': paymentMethod,
      'kurir': courier,
      if (paymentProof != null) 'payment_proof': paymentProof,
      'items': items.map((item) {
        return {
          'product_id': item.product.id,
          'qty': item.quantity,
          'type': item.product.isRentable ? 'rent' : 'buy',
          'duration': item.product.isRentable ? 1 : null,
          'start_date': item.product.isRentable ? DateTime.now().toIso8601String() : null,
        };
      }).toList(),
    };

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(bodyData),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Order.fromJson(body['data'] as Map<String, dynamic>);
    }

    throw ApiException(body['message']?.toString() ?? 'Gagal membuat pesanan');
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
