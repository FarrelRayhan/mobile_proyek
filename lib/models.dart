// models.dart - All data models in one flat file

class User {
  final String id;
  String name;
  final String email;
  String phone;
  String avatarUrl;
  String address;
  String password;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.address,
    this.password = 'password123',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['telepon']?.toString() ?? '',
      avatarUrl: json['avatar']?.toString() ?? json['avatar_url']?.toString() ?? 'https://i.pravatar.cc/150?img=3',
      address: json['address']?.toString() ?? json['alamat']?.toString() ?? '',
      password: '',
    );
  }

  User copyWith({
    String? name,
    String? phone,
    String? avatarUrl,
    String? address,
    String? password,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      password: password ?? this.password,
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

    final sellerData = json['seller'] as Map<String, dynamic>? ?? {};
    final categoryData = json['category'] as Map<String, dynamic>?;
    final imageUrl = json['image']?.toString() ?? json['gambar']?.toString() ?? '';
    final isRentable = json['is_rental'] == 1 || json['is_rental'] == true || json['is_rentable'] == true;

    return Product(
      id: toStringSafe(json['id']),
      name: toStringSafe(json['name'] ?? json['nama_produk']),
      description: toStringSafe(json['description'] ?? json['deskripsi']),
      price: toDouble(json['price'] ?? json['harga'] ?? json['buy_price']),
      rentalPrice: json['rent_price'] != null ? toDouble(json['rent_price']) : null,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/400x300',
      category: categoryData != null ? toStringSafe(categoryData['name']) : toStringSafe(json['category']),
      rating: toDouble(json['rating'] ?? 0),
      reviewCount: toInt(json['reviews_count'] ?? json['reviewed_by'] ?? 0),
      isAvailable: (json['status']?.toString().toLowerCase() ?? '') == 'approved' || json['status'] == 1 || json['is_available'] == true,
      isRentable: isRentable,
      sellerName: toStringSafe(sellerData['name'] ?? json['seller_name'] ?? json['store_name']),
      sellerCity: toStringSafe(sellerData['city'] ?? json['seller_city'] ?? json['store_city']),
      stock: toInt(json['stock'] ?? json['stok'] ?? 0),
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'] as Map<String, dynamic>?;
    return CartItem(
      product: Product.fromJson(productJson ?? {}),
      quantity: int.tryParse(json['qty']?.toString() ?? '1') ?? 1,
    );
  }

  double get total => product.price * quantity;
}

class RentalCartItem {
  final Product product;
  int quantity;
  final DateTime rentalStartDate;
  final DateTime rentalEndDate;

  RentalCartItem({
    required this.product,
    this.quantity = 1,
    required this.rentalStartDate,
    required this.rentalEndDate,
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
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    final details = json['order_details'] ?? json['details'] ?? json['orderDetails'] ?? [];
    final items = <CartItem>[];
    if (details is List) {
      for (final item in details) {
        if (item is Map<String, dynamic>) {
          items.add(CartItem.fromJson(item));
        }
      }
    }

    return Order(
      id: json['id']?.toString() ?? '',
      items: items,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? '',
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      courier: json['kurir']?.toString() ?? json['courier']?.toString() ?? '',
      trackingNumber: json['no_resi']?.toString() ?? json['tracking_number']?.toString() ?? '',
      address: json['shipping_address']?.toString() ?? json['address']?.toString() ?? '',
      paymentProof: json['bukti_pembayaran']?.toString(),
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

// Dummy Data
class DummyData {
  static User currentUser = User(
    id: 'u1',
    name: 'Budi Santoso',
    email: 'budi@email.com',
    phone: '081234567890',
    avatarUrl: 'https://i.pravatar.cc/150?img=3',
    address: 'Jl. Raya Bandung No. 12, Kota Bandung, Jawa Barat',
    password: 'password123',
  );

  static final List<Product> products = [
    const Product(
      id: 'p1',
      name: 'Tenda Camping 4 Orang',
      description:
          'Tenda camping waterproof dengan kapasitas 4 orang, mudah dipasang, ventilasi baik, dan bahan berkualitas tinggi untuk petualangan outdoor.',
      price: 1200000,
      rentalPrice: 85000,
      imageUrl: 'https://images.unsplash.com/photo-1624923686627-514dd5e57bae?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8dGVudHxlbnwwfHwwfHx8MA%3D%3D',
      category: 'Camping',
      rating: 4.8,
      reviewCount: 124,
      isAvailable: true,
      isRentable: true,
      sellerName: 'Outdoor Adventure',
      sellerCity: 'Bandung',
      stock: 15,
    ),
    const Product(
      id: 'p2',
      name: 'Sleeping Bag Premium',
      description:
          'Sleeping bag hangat untuk camping, bahan fleece lembut, tahan dingin hingga -10°C, ringan dan mudah dibawa.',
      price: 450000,
      rentalPrice: 35000,
      imageUrl: 'https://images.unsplash.com/photo-1558477280-1bfed08ea5db?q=80&w=688&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      category: 'Camping',
      rating: 4.7,
      reviewCount: 89,
      isAvailable: true,
      isRentable: true,
      sellerName: 'Camping Gear Store',
      sellerCity: 'Jakarta',
      stock: 20,
    ),
    const Product(
      id: 'p3',
      name: 'Kompor Portable Camping',
      description:
          'Kompor gas portable untuk camping, efisien bahan bakar, mudah menyala, dan aman digunakan di outdoor.',
      price: 350000,
      rentalPrice: null,
      imageUrl: 'https://images.unsplash.com/photo-1773762159864-59966f6f82c7?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8c3RvdmUlMjBwb3J0YWJsZXxlbnwwfHwwfHx8MA%3D%3D',
      category: 'Camping',
      rating: 4.6,
      reviewCount: 56,
      isAvailable: true,
      isRentable: false,
      sellerName: 'Outdoor Adventure',
      sellerCity: 'Surabaya',
      stock: 12,
    ),
    const Product(
      id: 'p4',
      name: 'Tas Backpack Hiking 60L',
      description:
          'Tas backpack hiking kapasitas 60L dengan sistem punggung ergonomis, banyak kompartemen, tahan air.',
      price: 850000,
      rentalPrice: 55000,
      imageUrl: 'https://images.unsplash.com/photo-1622260614153-03223fb72052?w=400&h=300&fit=crop',
      category: 'Hiking',
      rating: 4.9,
      reviewCount: 203,
      isAvailable: true,
      isRentable: true,
      sellerName: 'Hiking Essentials',
      sellerCity: 'Yogyakarta',
      stock: 18,
    ),
    const Product(
      id: 'p5',
      name: 'Tongkat Hiking Trekking',
      description:
          'Tongkat trekking adjustable dari aluminium, anti-slip handle, ringan namun kuat untuk mendaki gunung.',
      price: 250000,
      rentalPrice: 15000,
      imageUrl: 'https://images.unsplash.com/photo-1776006535249-a12975cb2269?q=80&w=1632&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      category: 'Hiking',
      rating: 4.5,
      reviewCount: 87,
      isAvailable: true,
      isRentable: true,
      sellerName: 'Mountain Gear',
      sellerCity: 'Bandung',
      stock: 25,
    ),
    const Product(
      id: 'p6',
      name: 'Jaket Hiking Waterproof',
      description:
          'Jaket hiking waterproof dan breathable, tahan angin, cocok untuk cuaca dingin dan hujan ringan saat hiking.',
      price: 650000,
      rentalPrice: 45000,
      imageUrl: 'https://images.unsplash.com/photo-1641126324594-4526eaff068d?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      category: 'Hiking',
      rating: 4.8,
      reviewCount: 145,
      isAvailable: true,
      isRentable: true,
      sellerName: 'Outdoor Adventure',
      sellerCity: 'Jakarta',
      stock: 10,
    ),
    const Product(
      id: 'p7',
      name: 'Lampu Camping LED',
      description:
          'Lampu LED portable untuk camping dengan brightness tinggi, rechargeable battery, tahan air.',
      price: 180000,
      rentalPrice: null,
      imageUrl: 'https://images.unsplash.com/photo-1637013369304-191aa2b51232?q=80&w=688&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      category: 'Camping',
      rating: 4.4,
      reviewCount: 78,
      isAvailable: true,
      isRentable: false,
      sellerName: 'Camping Gear Store',
      sellerCity: 'Surabaya',
      stock: 30,
    ),
    const Product(
      id: 'p8',
      name: 'Sepatu Hiking Outdoor',
      description:
          'Sepatu hiking anti-air dengan sol grip kuat, nyaman dan tahan lama untuk medan berbatu.',
      price: 750000,
      rentalPrice: null,
      imageUrl: 'https://images.unsplash.com/photo-1520219306100-ec4afeeefe58?w=400&h=300&fit=crop',
      category: 'Hiking',
      rating: 4.7,
      reviewCount: 112,
      isAvailable: true,
      isRentable: false,
      sellerName: 'Mountain Gear',
      sellerCity: 'Yogyakarta',
      stock: 14,
    ),
  ];

  static final List<Order> orders = [
    Order(
      id: 'ORD-001',
      items: [CartItem(product: products[0], quantity: 1)],
      total: 3500000,
      status: 'Dikirim',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      courier: 'JNE',
      trackingNumber: 'JNE123456789',
      address: 'Jl. Raya Bandung No. 12',
    ),
    Order(
      id: 'ORD-002',
      items: [CartItem(product: products[2], quantity: 1)],
      total: 22000000,
      status: 'Selesai',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      courier: 'TIKI',
      trackingNumber: 'TIKI987654321',
      address: 'Jl. Raya Bandung No. 12',
    ),
    Order(
      id: 'ORD-003',
      items: [
        CartItem(product: products[3], quantity: 1),
        CartItem(product: products[4], quantity: 1),
      ],
      total: 10700000,
      status: 'Diproses',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      courier: 'SiCepat',
      trackingNumber: 'SC246813579',
      address: 'Jl. Raya Bandung No. 12',
    ),
  ];

  static final List<Review> reviews = [
    Review(
      id: 'r1',
      userName: 'Andi Wijaya',
      avatarUrl: 'https://i.pravatar.cc/50?img=7',
      rating: 5,
      comment: 'Produk sangat bagus! Sesuai deskripsi dan pengiriman cepat. Sangat puas!',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Review(
      id: 'r2',
      userName: 'Siti Rahayu',
      avatarUrl: 'https://i.pravatar.cc/50?img=15',
      rating: 4,
      comment: 'Kualitas oke, packing rapi. Minus sedikit di warna yg agak beda dari foto.',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Review(
      id: 'r3',
      userName: 'Dika Pratama',
      avatarUrl: 'https://i.pravatar.cc/50?img=12',
      rating: 5,
      comment: 'Top banget! Recommended seller, responsif dan produk original.',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];

  static final List<String> categories = [
    'Semua', 'Camping', 'Hiking'
  ];

  static final List<String> couriers = [
    'JNE', 'TIKI', 'SiCepat', 'Anteraja', 'J&T Express', 'GoSend', 'GrabExpress'
  ];

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
