// models.dart - All data models in one flat file
import 'package:flutter/foundation.dart';

String _backendBaseUrl() {
  const apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');
  if (apiBaseUrlOverride.isNotEmpty) {
    var cleaned = apiBaseUrlOverride.replaceFirst(RegExp(r'/+$'), '');
    if (cleaned.endsWith('/api')) {
      cleaned = cleaned.substring(0, cleaned.length - 4);
    }
    return cleaned;
  }

  return kIsWeb ? 'http://127.0.0.1:8000' : 'http://10.0.2.2:8000';
}

String _toImageUrl(String raw) {
  var value = raw.trim();
  if (value.isEmpty) return value;
  if (value.startsWith('http://') || value.startsWith('https://')) return value;

  value = value
      .replaceAll('\\', '/')
      .replaceAll(RegExp(r'/{2,}'), '/')
      .replaceFirst(RegExp(r'^/'), '');

  if (value.startsWith('assets/images/')) {
    value = value.substring('assets/images/'.length);
  }
  if (value.startsWith('images/')) {
    value = value.substring('images/'.length);
  }

  return '${_backendBaseUrl()}/images/$value';
}

class User {
  final String id;
  String name;
  final String email;
  String phone;
  String avatarUrl;
  String address;
  String password;
  String? ktpImage;
  String? ktpVerifiedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.address,
    this.password = 'password123',
    this.ktpImage,
    this.ktpVerifiedAt,
  });

  bool get hasKtpUploaded => ktpImage != null && ktpImage!.isNotEmpty;
  bool get isKtpVerified => ktpVerifiedAt != null && ktpVerifiedAt!.isNotEmpty;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['telepon']?.toString() ?? '',
      avatarUrl: json['avatar']?.toString() ??
          json['avatar_url']?.toString() ??
          'https://i.pravatar.cc/150?img=3',
      address: json['address']?.toString() ?? json['alamat']?.toString() ?? '',
      password: '',
      ktpImage: json['ktp_image']?.toString(),
      ktpVerifiedAt: json['ktp_verified_at']?.toString(),
    );
  }

  User copyWith({
    String? name,
    String? phone,
    String? avatarUrl,
    String? address,
    String? password,
    String? ktpImage,
    String? ktpVerifiedAt,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      password: password ?? this.password,
      ktpImage: ktpImage ?? this.ktpImage,
      ktpVerifiedAt: ktpVerifiedAt ?? this.ktpVerifiedAt,
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? rentalPrice;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final bool isRentable;
  final String sellerName;
  final String sellerCity;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.rentalPrice,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    this.isRentable = false,
    required this.sellerName,
    required this.sellerCity,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String toStringSafe(dynamic value) => value?.toString() ?? '';
    double toDouble(dynamic value) {
      if (value == null) return 0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    String categoryName = toStringSafe(json['category']);
    if (json['category'] is Map) {
      categoryName = toStringSafe(json['category']['name']);
    }

    String sellerNameStr =
        toStringSafe(json['seller_name'] ?? json['store_name']);
    String sellerCityStr =
        toStringSafe(json['seller_city'] ?? json['store_city']);
    if (json['seller'] is Map) {
      sellerNameStr = toStringSafe(json['seller']['name']) != ''
          ? toStringSafe(json['seller']['name'])
          : sellerNameStr;
      sellerCityStr = toStringSafe(json['seller']['city']) != ''
          ? toStringSafe(json['seller']['city'])
          : sellerCityStr;
    }

    var imageUrl =
        json['image']?.toString() ?? json['gambar']?.toString() ?? '';
    imageUrl = _toImageUrl(imageUrl);
    final isRentable = json['is_rental'] == 1 ||
        json['is_rental'] == true ||
        json['is_rentable'] == true;

    return Product(
      id: toStringSafe(json['id']),
      name: toStringSafe(json['name'] ?? json['nama_produk']),
      description: toStringSafe(json['description'] ?? json['deskripsi']),
      price: toDouble(json['price'] ?? json['harga'] ?? json['buy_price']),
      rentalPrice:
          json['rent_price'] != null ? toDouble(json['rent_price']) : null,
      imageUrl: imageUrl.isNotEmpty
          ? imageUrl
          : 'assets/images/meja-kayu-dengan-bangku-yang-dikelilingi-oleh-pegunungan-alpen-italia-yang-tertutup-tanaman-hijau-di-bawah-sinar-matahari_181624-28262.avif',
      category: categoryName,
      rating: toDouble(json['rating'] ?? 0),
      reviewCount: toInt(json['reviews_count'] ?? json['reviewed_by'] ?? 0),
      isAvailable:
          (json['status']?.toString().toLowerCase() ?? '') == 'approved' ||
              json['status'] == 1 ||
              json['is_available'] == true,
      isRentable: isRentable,
      sellerName: sellerNameStr,
      sellerCity: sellerCityStr,
      stock: toInt(json['stock'] ?? json['stok'] ?? 0),
    );
  }
}

class CartItem {
  final String id;
  final Product product;
  int quantity;
  final String type;
  final int? rentalDays;
  final DateTime? rentalStartDate;
  final Review? existingReview;

  CartItem({
    this.id = '',
    required this.product,
    this.quantity = 1,
    this.type = 'buy',
    this.rentalDays,
    this.rentalStartDate,
    this.existingReview,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'] as Map<String, dynamic>?;
    Review? review;
    final ratings = productJson?['product_ratings'];
    if (ratings is List &&
        ratings.isNotEmpty &&
        ratings.first is Map<String, dynamic>) {
      review = Review.fromJson(ratings.first as Map<String, dynamic>);
    }

    return CartItem(
      id: json['id']?.toString() ?? '',
      product: Product.fromJson(productJson ?? {}),
      quantity: int.tryParse(json['qty']?.toString() ?? '1') ?? 1,
      type: json['type']?.toString() ?? 'buy',
      rentalDays: int.tryParse(json['duration']?.toString() ?? ''),
      rentalStartDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString())
          : null,
      existingReview: review,
    );
  }

  double get total => product.price * quantity;
  bool get isRental => type == 'rent';
}

class RentalCartItem {
  final Product product;
  int quantity;
  final DateTime rentalStartDate;
  final DateTime rentalEndDate;
  final String orderDetailId;

  RentalCartItem({
    required this.product,
    this.quantity = 1,
    required this.rentalStartDate,
    required this.rentalEndDate,
    this.orderDetailId = '',
  });

  int get rentalDays => rentalEndDate.difference(rentalStartDate).inDays + 1;
  double get total => (product.rentalPrice ?? 0) * quantity * rentalDays;
}

class Order {
  final String id;
  final List<CartItem> items;
  final double total;
  final String status;
  final DateTime createdAt;
  final String courier;
  final String trackingNumber;
  final String address;
  final String? paymentProof;
  final bool returnSubmitted;

  const Order({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.courier,
    required this.trackingNumber,
    required this.address,
    this.paymentProof,
    this.returnSubmitted = false,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    final details =
        json['order_details'] ?? json['details'] ?? json['orderDetails'] ?? [];
    final items = <CartItem>[];
    if (details is List) {
      for (final item in details) {
        if (item is Map<String, dynamic>) {
          items.add(CartItem.fromJson(item));
        }
      }
    }

    final returns = json['returns'];
    final returnSubmitted = returns is List && returns.isNotEmpty;

    return Order(
      id: json['id']?.toString() ?? '',
      items: items,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? '',
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      courier: json['kurir']?.toString() ?? json['courier']?.toString() ?? '',
      trackingNumber: json['no_resi']?.toString() ??
          json['tracking_number']?.toString() ??
          '',
      address: json['shipping_address']?.toString() ??
          json['address']?.toString() ??
          '',
      paymentProof: json['bukti_pembayaran']?.toString(),
      returnSubmitted: returnSubmitted,
    );
  }

  Order copyWith({
    String? id,
    List<CartItem>? items,
    double? total,
    String? status,
    DateTime? createdAt,
    String? courier,
    String? trackingNumber,
    String? address,
    String? paymentProof,
    bool? returnSubmitted,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      courier: courier ?? this.courier,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      address: address ?? this.address,
      paymentProof: paymentProof ?? this.paymentProof,
      returnSubmitted: returnSubmitted ?? this.returnSubmitted,
    );
  }
}

class RentalOrder {
  final String id;
  final List<RentalCartItem> items;
  final double total;
  final String status;
  final DateTime createdAt;
  final DateTime rentalStartDate;
  final DateTime rentalEndDate;
  final String address;
  final String? paymentProof;
  final bool returnSubmitted;

  const RentalOrder({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.rentalStartDate,
    required this.rentalEndDate,
    required this.address,
    this.paymentProof,
    this.returnSubmitted = false,
  });
}

class Review {
  final String id;
  final String userName;
  final String avatarUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.userName,
    required this.avatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    double r = 0;
    if (json['rating'] != null) {
      if (json['rating'] is int) {
        r = (json['rating'] as int).toDouble();
      } else if (json['rating'] is double) {
        r = json['rating'];
      } else {
        r = double.tryParse(json['rating'].toString()) ?? 0;
      }
    }

    return Review(
      id: json['id']?.toString() ?? '',
      userName: json['user_name']?.toString() ??
          json['name']?.toString() ??
          'Pengguna',
      avatarUrl: json['user_avatar']?.toString() ??
          json['avatar']?.toString() ??
          'https://i.pravatar.cc/150?img=3',
      rating: r,
      comment: json['comment']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isFromMe;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isFromMe,
  });
}

class RegionData {
  static const List<String> cities = [
    'Bandung',
    'Jakarta',
    'Surabaya',
    'Yogyakarta',
    'Semarang',
  ];

  static const Map<String, List<String>> districts = {
    'Bandung': ['Cicendo', 'Coblong', 'Sumur Bandung', 'Andir'],
    'Jakarta': ['Gambir', 'Menteng', 'Kebayoran Lama', 'Cilandak'],
    'Surabaya': ['Wonokromo', 'Genteng', 'Tegalsari', 'Sukolilo'],
    'Yogyakarta': ['Gondokusuman', 'Danurejan', 'Umbulharjo', 'Jetis'],
    'Semarang': ['Candisari', 'Banyumanik', 'Gayamsari', 'Pedurungan'],
  };
}

class CurrencyFormat {
  static String formatPrice(double price) {
    if (price >= 1000000) {
      return 'Rp ${(price / 1000000).toStringAsFixed(1)}jt';
    }
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}';
  }
}

class AppConstants {
  static final List<String> couriers = [
    'JNE',
    'TIKI',
    'SiCepat',
    'Anteraja',
    'J&T Express',
    'GoSend',
    'GrabExpress'
  ];
}
