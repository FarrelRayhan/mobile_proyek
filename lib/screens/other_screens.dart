// other_screens.dart - KF-15, KF-16, KF-17, KF-18, KF-19, KF-22, KF-23
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../app_state.dart';
import '../models.dart';
import '../widgets.dart';

// ─── Orders Screen ───────────────────────────────────────────────────────────
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<AppState>().orders;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        backgroundColor: Colors.white,
      ),
      body: orders.isEmpty
          ? const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Belum Ada Pesanan',
              subtitle: 'Pesanan yang kamu buat akan muncul di sini',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _OrderCard(order: orders[i]),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.id,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    _formatDate(order.createdAt),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
              OrderStatusBadge(status: order.status),
            ],
          ),
          const Divider(height: 16),
          // Items
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.product.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 56,
                        height: 56,
                        color: AppTheme.primary.withOpacity(0.1),
                        child: const Icon(Icons.image_outlined,
                            color: AppTheme.primary, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${item.quantity}x • ${DummyData.formatPrice(item.product.price)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 8),
          // Courier & Tracking (KF-16)
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined,
                  size: 14, color: AppTheme.textLight),
              const SizedBox(width: 4),
              Text(
                '${order.courier} • ${order.trackingNumber}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Total & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppTheme.textLight,
                    ),
                  ),
                  Text(
                    DummyData.formatPrice(order.total),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (order.status == 'Dikirim') ...[
                    ElevatedButton(
                      onPressed: () => state.confirmReceived(order.id),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        textStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Terima Barang'),
                    ),
                  ],
                  if (order.status == 'Selesai') ...[
                    OutlinedButton(
                      onPressed: () => _showReviewDialog(context, order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        textStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Beri Ulasan'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  void _showReviewDialog(BuildContext context, Order order) {
    double _rating = 5;
    final _ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Beri Ulasan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => GestureDetector(
                        onTap: () =>
                            setState(() => _rating = i + 1.0),
                        child: Icon(
                          i < _rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: AppTheme.accentWarm,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _ctrl,
                  maxLines: 3,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Tulis ulasanmu disini...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ulasan berhasil dikirim!',
                              style: GoogleFonts.plusJakartaSans()),
                          backgroundColor: AppTheme.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                    child: const Text('Kirim Ulasan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Checkout Screen ─────────────────────────────────────────────────────────
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.cartItems;
    final total = state.cartTotal;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Order Items
                ...items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.product.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${item.quantity}x ${DummyData.formatPrice(item.product.price)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DummyData.formatPrice(item.total),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 20),
                // Payment Method (placeholder)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Metode Pembayaran',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Transfer Bank - BCA',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        'No. Rekening: 1234567890',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DummyData.formatPrice(total),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to payment proof upload
                      Navigator.pushNamed(context, '/payment_proof_upload');
                    },
                    child: const Text('Bayar Sekarang'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Favorites Screen ────────────────────────────────────────────────────────
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final favorites = state.favorites;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Produk Favorit'),
        backgroundColor: Colors.white,
      ),
      body: favorites.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border,
              title: 'Belum Ada Favorit',
              subtitle: 'Produk yang kamu suka akan tersimpan di sini',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemCount: favorites.length,
              itemBuilder: (_, i) {
                final product = favorites[i];
                return ProductCard(
                  product: product,
                  isFavorite: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          _ProductDetailWrapper(product: product),
                    ),
                  ),
                  onFavorite: () => state.toggleFavorite(product),
                  onAddToCart: () => state.addToCart(product),
                );
              },
            ),
    );
  }
}

// Wrapper to avoid circular import
class _ProductDetailWrapper extends StatelessWidget {
  final Product product;

  const _ProductDetailWrapper({required this.product});

  @override
  Widget build(BuildContext context) {
    // Import and use product detail screen
    return Scaffold(
      body: Center(
        child: Text(product.name),
      ),
    );
  }
}

// ─── Profile Screen ──────────────────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser!;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.bgGradientStart, AppTheme.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundImage: NetworkImage(user.avatarUrl),
                    backgroundColor: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    user.email,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatBox(
                          value: '${state.orders.length}', label: 'Pesanan'),
                      const SizedBox(width: 16),
                      _StatBox(
                          value: '${state.favorites.length}', label: 'Favorit'),
                      const SizedBox(width: 16),
                      _StatBox(value: '0', label: 'Ulasan'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _MenuGroup(
                    title: 'Akun',
                    items: [
                      _MenuItem(
                          icon: Icons.person_outline,
                          label: 'Edit Profil',
                          onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const EditProfileScreen()),
                              )),
                      _MenuItem(
                          icon: Icons.location_on_outlined,
                          label: 'Alamat Pengiriman',
                          onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ChangeAddressScreen()),
                              )),
                      _MenuItem(
                          icon: Icons.lock_outline,
                          label: 'Ubah Password',
                          onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ChangePasswordScreen()),
                              )),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _MenuGroup(
                    title: 'Transaksi',
                    items: [
                      _MenuItem(
                          icon: Icons.receipt_outlined,
                          label: 'Riwayat Pesanan',
                          onTap: () =>
                              Navigator.pushNamed(context, '/orders')),
                      _MenuItem(
                          icon: Icons.favorite_border,
                          label: 'Produk Favorit',
                          onTap: () =>
                              Navigator.pushNamed(context, '/favorites')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _MenuGroup(
                    title: 'Lainnya',
                    items: [
                      _MenuItem(
                          icon: Icons.help_outline,
                          label: 'Bantuan',
                          onTap: () {}),
                      _MenuItem(
                          icon: Icons.info_outline,
                          label: 'Tentang Aplikasi',
                          onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Logout
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: AppTheme.error),
                      title: Text(
                        'Keluar',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.error,
                        ),
                      ),
                      onTap: () => state.logout(),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;

  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: items
                .asMap()
                .entries
                .map((e) => Column(
                      children: [
                        e.value,
                        if (e.key < items.length - 1)
                          const Divider(
                              height: 1, indent: 56, endIndent: 16),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 18),
      ),
      title: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      trailing:
          const Icon(Icons.chevron_right, color: AppTheme.textLight, size: 20),
      onTap: onTap,
    );
  }
}

// ─── Edit Profile Screen ─────────────────────────────────────────────────────────
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _avatarCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().currentUser!;
    _nameCtrl = TextEditingController(text: user.name);
    _phoneCtrl = TextEditingController(text: user.phone);
    _avatarCtrl = TextEditingController(text: user.avatarUrl);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _avatarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar preview
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_avatarCtrl.text),
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    onBackgroundImageError: (_, __) {},
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Form fields
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _avatarCtrl,
              decoration: const InputDecoration(
                labelText: 'URL Avatar',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image_outlined),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<AppState>().updateProfile(
                        name: _nameCtrl.text,
                        phone: _phoneCtrl.text,
                        avatarUrl: _avatarCtrl.text,
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profil berhasil diperbarui!',
                          style: GoogleFonts.plusJakartaSans()),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Change Address Screen ─────────────────────────────────────────────────────────
class ChangeAddressScreen extends StatefulWidget {
  const ChangeAddressScreen({super.key});

  @override
  State<ChangeAddressScreen> createState() => _ChangeAddressScreenState();
}

class _ChangeAddressScreenState extends State<ChangeAddressScreen> {
  late TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().currentUser!;
    _addressCtrl = TextEditingController(text: user.address);
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Ubah Alamat Pengiriman'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alamat Saat Ini',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Masukkan alamat lengkap pengiriman',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<AppState>().updateAddress(_addressCtrl.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Alamat berhasil diperbarui!',
                          style: GoogleFonts.plusJakartaSans()),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Simpan Alamat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Change Password Screen ─────────────────────────────────────────────────────────
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Ubah Password'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _currentPassCtrl,
              obscureText: _obscureCurrent,
              decoration: InputDecoration(
                labelText: 'Password Saat Ini',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureCurrent
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPassCtrl,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'Password Baru',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureNew ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPassCtrl,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password Baru',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_newPassCtrl.text != _confirmPassCtrl.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password baru tidak cocok!',
                            style: GoogleFonts.plusJakartaSans()),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                    return;
                  }
                  if (_newPassCtrl.text.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password minimal 6 karakter!',
                            style: GoogleFonts.plusJakartaSans()),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                    return;
                  }
                  final success = context.read<AppState>().changePassword(
                        _currentPassCtrl.text,
                        _newPassCtrl.text,
                      );
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password berhasil diubah!',
                            style: GoogleFonts.plusJakartaSans()),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password saat ini salah!',
                            style: GoogleFonts.plusJakartaSans()),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                  }
                },
                child: const Text('Ubah Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Invoice Screen ─────────────────────────────────────────────────────────
class InvoiceScreen extends StatelessWidget {
  final Order order;

  const InvoiceScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Invoice'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle,
                        color: AppTheme.success, size: 48),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pesanan Berhasil!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Terima kasih telah berbelanja',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Invoice Details
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InvoiceRow(label: 'Nomor Pesanan', value: order.id),
                  const Divider(height: 24),
                  _InvoiceRow(
                    label: 'Tanggal',
                    value: _formatDate(order.createdAt),
                  ),
                  const Divider(height: 24),
                  _InvoiceRow(label: 'Status', value: order.status),
                  const Divider(height: 24),
                  _InvoiceRow(label: 'Kurir', value: order.courier),
                  const Divider(height: 24),
                  _InvoiceRow(label: 'No. Resi', value: order.trackingNumber),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Alamat
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alamat Pengiriman',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order.address,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Items
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Pesanan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.product.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 50,
                                  height: 50,
                                  color: AppTheme.primary.withOpacity(0.1),
                                  child: const Icon(Icons.image_outlined,
                                      color: AppTheme.primary, size: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity}x • ${DummyData.formatPrice(item.product.price)}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              DummyData.formatPrice(item.total),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Total
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Pembayaran',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    DummyData.formatPrice(order.total),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Download/Print button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invoice berhasil diunduh!',
                          style: GoogleFonts.plusJakartaSans()),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Unduh Invoice'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Kembali ke Beranda'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}

class _InvoiceRow extends StatelessWidget {
  final String label;
  final String value;

  const _InvoiceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── Article Screen ─────────────────────────────────────────────────────────
class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final articles = [
      _Article(
        title: 'Tips Memilih Tenda yang Tepat untuk Camping',
        image: 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=400',
        category: 'Camping',
        readTime: '5 menit',
        excerpt: 'Pelajari cara memilih tenda yang sesuai dengan kebutuhan camping Anda, mulai dari kapasitas, material, hingga ketahanan cuaca.',
        content: '''Memilih tenda yang tepat adalah langkah pertama yang sangat penting dalam merencanakan camping Anda. Berikut adalah panduan lengkap untuk memilih tenda yang sesuai dengan kebutuhan.

**1. Pertimbangkan Kapasitas**
Pilih tenda dengan kapasitas yang lebih besar dari jumlah peserta. Misalnya, untuk 4 orang, pilih tenda 4-6 orang agar ada ruang ekstra untuk barang bawaan.

**2. Material dan Ketahanan**
- **Polyester**: Ringan, cepat kering, dan tahan UV
- **Nylon**: Ringan dan kuat, tapi menyerap air
- **Canvas**: Tahan lama dan insulated, tapi berat

**3. Tipe Tenda**
- **Dome**: Mudah dipasang, stabil di angin sedang
- **Tunnel**: Ruang lebih besar, butuh lebih banyak tiang
- **Cabin**: Ruang interior terbesar, tapi butuh setup lebih kompleks

**4. Fitur Penting**
- Ventilasi yang baik untuk mencegah kondensasi
- Rain fly untuk perlindungan hujan
- Floor yang waterproof
- Easy setup untuk pemula

Dengan mempertimbangkan faktor-faktor di atas, Anda dapat memilih tenda yang paling sesuai dengan kebutuhan camping Anda.''',
      ),
      _Article(
        title: 'Panduan Hiking untuk Pemula',
        image: 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=400',
        category: 'Hiking',
        readTime: '7 menit',
        excerpt: 'Ingin mulai hiking tapi bingung mulai dari mana? Simak panduan lengkap untuk pemula agar perjalanan Anda aman dan menyenangkan.',
        content: '''Hiking adalah cara yang luar biasa untuk menjelajahi alam sekaligus menjaga kebugaran tubuh. Bagi pemula, berikut panduan lengkap untuk memulai.

**1. Pilih Jalur yang Sesuai**
Mulai dari jalur yang mudah dan tidak terlalu curam. national parks atau jalur yang sudah ditandai dengan baik adalah pilihan yang tepat untuk pemula.

**2. Perlengkapan Dasar**
- Sepatu hiking yang nyaman dan support pergelangan kaki
- Backpack yang sesuai dengan kebutuhan
- Air minimal 2 liter
- Snack dan makanan ringan
- Peta atau GPS
- First aid kit

**3. Kondisi Fisik**
Lakukan pemanasan sebelum memulai hiking. Jangan ragu untuk istirahat secara berkala, terutama saat mendaki.

**4. Safety Tips**
- Selalu informasikan rencana hiking kepada keluarga atau teman
- Periksa cuaca sebelum berangkat
- Jangan偏离 jalur yang ditandai
- Bawa senter jika kemungkinan kembali malam

**5. Etika di Alam**
- Bawa pulang sampah Anda
- Jangan memberi makan野生动物
- Hindari membuat api敞开 kecuali di tempat yang diperbolehkan

Dengan persiapan yang tepat, hiking akan menjadi pengalaman yang menyenangkan dan aman.''',
      ),
      _Article(
        title: 'Perlengkapan Wajib Camping di Musim Hujan',
        image: 'https://images.unsplash.com/photo-1478131143081-80f7f84ca84d?w=400',
        category: 'Tips',
        readTime: '4 menit',
        excerpt: 'Camping saat musim hujan membutuhkan persiapan ekstra. Berikut perlengkapan yang wajib Anda bawa.',
        content: '''Camping di musim hujan bisa menjadi pengalaman yang menyenangkan jika Anda mempersiapkan diri dengan baik. Berikut perlengkapan wajib yang harus Anda bawa.

**1. Tenda dengan Rain Fly**
Pastikan tenda Anda memiliki rain fly yang berkualitas dan waterproof. Periksa juga semua zipper dan seam untuk memastikan tidak ada kebocoran.

**2. Sleeping Pad yang Tepat**
Jangan hanya mengandalkan sleeping bag. Gunakan sleeping pad yang tebal untuk insulation dari tanah yang dingin dan basah.

**3. Pakaian Berlapis**
- Layer pertama: bahan yang menyerap keringat
- Layer kedua: fleece untuk kehangatan
- Layer ketiga: rain jacket waterproof

**4. Perlengkapan Kedap Air**
- Dry bag untuk menyimpan barang elektronik
- Waterproof bag untuk pakaian cadangan
- Rain cover untuk backpack

**5. Pencahayaan**
Bawa headlamp dengan baterai cadangan. Senter juga berguna untuk aktivitas di malam hari.

**6. Persiapan Darurat**
- First aid kit lengkap
- Peta darurat
- Whistle untuk situasi darurat
- Makanan darurat

Dengan persiapan yang matang, camping di musim hujan akan tetap nyaman dan aman.''',
      ),
      _Article(
        title: 'Cara Merawat Peralatan Outdoor Agar Tahan Lama',
        image: 'https://images.unsplash.com/photo-1501555088652-021faa106b9b?w=400',
        category: 'Tips',
        readTime: '6 menit',
        excerpt: 'Peralatan outdoor yang terawat dengan baik akan lebih awet dan siap digunakan kapan saja. Simak cara merawatnya.',
        content: '''Investasi pada peralatan outdoor yang berkualitas akan sia-sia jika tidak dirawat dengan baik. Berikut cara merawat peralatan outdoor agar tahan lama.

**1. Tenda**
- Bersihkan setelah setiap penggunaan
- Keringkan sepenuhnya sebelum disimpan
- Hindari menyimpan dalam keadaan lembab
- Periksa kerusakan secara berkala
- Gunakan footprint untuk melindungi floor

**2. Sleeping Bag**
- Ventilasi setelah penggunaan
- Cuci sesuai petunjuk produsen
- Simpan dalam mesh bag, bukan compression sack
- Avoid menyimpan dalam keadaan terkompresi

**3. Sepatu Hiking**
- Bersihkan setelah setiap hiking
- Keringkan secara alami, jauh dari panas langsung
- Gunakan waterproofing treatment secara berkala
- Ganti insole jika sudah aus

**4. Kompor dan Burner**
- Bersihkan setelah setiap penggunaan
- Periksa tabung gas secara berkala
- Simpan di tempat yang kering
- Check regulator untuk kebocoran

**5. Backpack**
- Kosongkan dan bersihkan setelah setiap perjalanan
- Periksa semua zipper dan jahitan
- Simpan di tempat yang kering
- Avoid overloading untuk melindungi struktur

Dengan perawatan yang tepat, peralatan outdoor Anda akan bertahan bertahun-tahun.''',
      ),
      _Article(
        title: 'Destinasi Camping Terbaik di Indonesia',
        image: 'https://images.unsplash.com/photo-1523987355523-c7b5b0dd90a7?w=400',
        category: 'Destinasi',
        readTime: '8 menit',
        excerpt: 'Jelajahi berbagai destinasi camping terbaik di Indonesia yang menawarkan pemandangan alam yang menakjubkan.',
        content: '''Indonesia memiliki banyak sekali destinasi camping yang menakjubkan. Berikut beberapa yang wajib Anda coba.

**1. Kawah Ijen, Jawa Timur**
Camping di tepi kawah aktif dengan pemandangan blue fire yang ikonik. Suhu dingin menambah pengalaman yang tak terlupakan.

**2. Gunung Bromo, Jawa Timur**
Padang savana yang luas dengan pemandangan matahari terbit yang spektakuler. Sangat populer untuk camping dan fotografi.

**3. Lake Toba, Sumatera Utara**
Danau vulkanik terbesar di dunia dengan pemandangan yang tenang dan udara yang segar.

**4. Pulau Komodo, Nusa Tenggara Timur**
Camping di pulau yang terkenal dengan komodo ini menawarkan pengalaman alam yang unik.

**5. Dieng, Jawa Tengah**
Dataran tinggi dengan kawah-kawah yang menakjubkan dan udara yang sejuk. Cocok untuk camping semalam.

**6. Mandalika, Nusa Tenggara Barat**
Pantai yang indah dengan pasir putih dan air laut yang jernih. Cocok untuk beach camping.

**7. Bromo Tengger Semeru, Jawa Timur**
Kombinasi antara padang savana dan gunung berapi aktif yang menakjubkan.

Setiap destinasi memiliki keunikan sendiri. Pastikan untuk memeriksa kondisi cuaca dan izin sebelum berangkat.''',
      ),
      _Article(
        title: 'Teknik Memasak di Alam Terbuka',
        image: 'https://images.unsplash.com/photo-1533240332313-0db49b459ad6?w=400',
        category: 'Tips',
        readTime: '5 menit',
        excerpt: 'Belajar teknik memasak yang aman dan praktis saat camping di alam terbuka.',
        content: '''Memasak di alam terbuka membutuhkan teknik khusus agar aman dan efisien. Berikut panduan lengkapnya.

**1. Pemilihan Tempat Memasak**
- Pilih tempat yang jauh dari bahan mudah terbakar
- Pastikan ventilasi baik
- Hindari bawah pohon kering
- Gunakan kompor portable atau api di tempat yang diperbolehkan

**2. Jenis Kompor**
- **Kompor gas**: Mudah digunakan, cepat panas
- **Kompor multi-fuel**: Fleksibel dengan berbagai bahan bakar
- **Wood stove**: Eco-friendly jika kayu tersedia

**3. Teknik Memasak Dasar**
- **Rebus air**: Gunakan minimal 1 liter air per orang
- **Masak mie/instant**: Ikuti petunjuk waktu memasak
- **Panggang**: Gunakan tusukan atau grill grate

**4. Tips Keamanan**
- Jangan tinggalkan api tanpa pengawasan
- Matikan kompor sepenuhnya setelah digunakan
- Jauhkan dari tenda
- Simpan bahan bakar dengan aman

**5. Menu Sederhana untuk Pemula**
- Mie instan
- Nasi liwet dalam kaleng
- Hotdog panggang
- Kopi/susu panas
- Sup instan

Dengan teknik yang tepat, memasak saat camping akan menjadi pengalaman yang menyenangkan.''',
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Artikel'),
        backgroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: articles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, i) => _ArticleCard(article: articles[i]),
      ),
    );
  }
}

class _Article {
  final String title;
  final String image;
  final String category;
  final String readTime;
  final String excerpt;
  final String content;

  const _Article({
    required this.title,
    required this.image,
    required this.category,
    required this.readTime,
    required this.excerpt,
    required this.content,
  });
}

class _ArticleCard extends StatelessWidget {
  final _Article article;

  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _ArticleDetailScreen(article: article),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                article.image,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  color: AppTheme.primary.withOpacity(0.1),
                  child: const Icon(Icons.image_outlined,
                      color: AppTheme.primary, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          article.category,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time,
                          size: 12, color: AppTheme.textLight),
                      const SizedBox(width: 2),
                      Text(
                        article.readTime,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    article.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.excerpt,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Baca Selengkapnya',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward,
                          size: 14, color: AppTheme.primary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Article Detail Screen ───────────────────────────────────────────────────
class _ArticleDetailScreen extends StatelessWidget {
  final _Article article;

  const _ArticleDetailScreen({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppTheme.textPrimary),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                article.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppTheme.primary.withOpacity(0.1),
                  child: const Icon(Icons.image_outlined,
                      color: AppTheme.primary, size: 60),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          article.category,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time,
                          size: 14, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Text(
                        article.readTime,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    article.content,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
