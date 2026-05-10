// cart_screen.dart - KF-09, KF-10, KF-11, KF-12, KF-13, KF-14
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../app_state.dart';
import '../models.dart';
import '../widgets.dart';
import 'other_screens.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.cartItems;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text('Keranjang (${state.cartCount})'),
        backgroundColor: Colors.white,
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: state.clearCart,
              child: Text(
                'Kosongkan',
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: items.isEmpty
          ? const EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Keranjang Kosong',
              subtitle: 'Tambahkan produk ke keranjang untuk mulai belanja',
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _CartItemCard(item: items[i]),
                  ),
                ),
                // Order Summary
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
                            'Subtotal (${state.cartCount} item)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            DummyData.formatPrice(state.cartTotal),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckoutScreen(),
                            ),
                          ),
                          child: Text(
                              'Lanjut ke Checkout • ${DummyData.formatPrice(state.cartTotal)}'),
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

class _CartItemCard extends StatelessWidget {
  final CartItem item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item.product.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: AppTheme.primary.withOpacity(0.1),
                child: const Icon(Icons.image_outlined, color: AppTheme.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DummyData.formatPrice(item.product.price),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity controls
                    Row(
                      children: [
                        _QtyBtn(
                          icon: Icons.remove,
                          onTap: () => state.updateCartQuantity(
                              item.product.id, item.quantity - 1),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${item.quantity}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _QtyBtn(
                          icon: Icons.add,
                          onTap: () => state.updateCartQuantity(
                              item.product.id, item.quantity + 1),
                        ),
                      ],
                    ),
                    // Total
                    Text(
                      DummyData.formatPrice(item.total),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Delete
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
            onPressed: () => state.removeFromCart(item.product.id),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 16),
      ),
    );
  }
}

// ─── Checkout Screen ─────────────────────────────────────────────────────────
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _imagePicker = ImagePicker();
  final ImagePicker _picker = ImagePicker();
  XFile? _paymentProof;
  String _selectedCourier = 'JNE';
  String _selectedPayment = 'Transfer Bank';
  bool _loading = false;
  final _addressCtrl =
      TextEditingController(text: 'Jl. Raya Bandung No. 12, Kota Bandung');
  final _nameCtrl = TextEditingController(text: 'Ahmad Fauzi');
  final _postalCtrl = TextEditingController(text: '40111');
  final _phoneCtrl = TextEditingController(text: '081234567890');
  String _selectedCity = RegionData.cities.first;
  String _selectedDistrict = RegionData.districts[RegionData.cities.first]!.first;

  // Bank options for Transfer Bank
  final _banks = ['BCA', 'Mandiri', 'BNI', 'BRI', 'BTN'];
  String? _selectedBank;

  // Card options for Kartu Kredit
  final _cards = ['Visa', 'Mastercard', 'JCB', 'Amex'];
  String? _selectedCard;

  final _payments = [
    'Transfer Bank',
    'GoPay',
    'OVO',
    'DANA',
    'Kartu Kredit',
    'COD',
  ];

  double _getShippingCost() {
    switch (_selectedCourier) {
      case 'JNE':
        return 18000;
      case 'TIKI':
        return 16000;
      case 'SiCepat':
        return 14000;
      case 'J&T Express':
        return 15000;
      default:
        return 20000;
    }
  }

  Future<void> _pickPaymentProof() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _paymentProof = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final shipping = _getShippingCost();
    final total = state.cartTotal + shipping;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alamat
            _SectionCard(
              title: 'Alamat Pengiriman',
              icon: Icons.location_on_outlined,
              child: Column(
                children: [
                  // Full Name
                  TextField(
                    controller: _nameCtrl,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      hintText: 'Masukkan nama lengkap',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Address
                  TextField(
                    controller: _addressCtrl,
                    maxLines: 2,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Alamat Lengkap',
                      hintText: 'Masukkan alamat lengkap',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // City and District
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCity,
                          decoration: const InputDecoration(
                            labelText: 'Kota',
                            border: OutlineInputBorder(),
                          ),
                          items: RegionData.cities
                              .map((city) => DropdownMenuItem(
                                    value: city,
                                    child: Text(city),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCity = value;
                                _selectedDistrict = RegionData.districts[value]!.first;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedDistrict,
                          decoration: const InputDecoration(
                            labelText: 'Kecamatan',
                            border: OutlineInputBorder(),
                          ),
                          items: RegionData.districts[_selectedCity]!
                              .map((district) => DropdownMenuItem(
                                    value: district,
                                    child: Text(district),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedDistrict = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Phone
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Nomor Telepon',
                      hintText: 'Masukkan nomor telepon',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Bukti Pembayaran',
              icon: Icons.photo_camera_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_paymentProof != null)
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _paymentProof!.path,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 180,
                              color: AppTheme.surface,
                              child: const Center(
                                child: Icon(Icons.image_not_supported,
                                    size: 40, color: AppTheme.textSecondary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickPaymentProof,
                      icon: const Icon(Icons.upload_file),
                      label: Text(_paymentProof == null
                          ? 'Unggah Bukti Pembayaran'
                          : 'Ganti Bukti Pembayaran'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unggah foto bukti transfer setelah melakukan pembayaran.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Pilih Kurir (KF-12, KF-13)
            _SectionCard(
              title: 'Jasa Pengiriman',
              icon: Icons.local_shipping_outlined,
              child: Column(
                children: DummyData.couriers.map((c) {
                  final cost = _getCost(c);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCourier = c),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _selectedCourier == c
                            ? AppTheme.primary.withOpacity(0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedCourier == c
                              ? AppTheme.primary
                              : AppTheme.divider,
                          width: _selectedCourier == c ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: c,
                            groupValue: _selectedCourier,
                            onChanged: (v) =>
                                setState(() => _selectedCourier = v!),
                            activeColor: AppTheme.primary,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              c,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            DummyData.formatPrice(cost),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Payment (KF-14)
            _SectionCard(
              title: 'Metode Pembayaran',
              icon: Icons.payment_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _payments.map((p) {
                      final selected = _selectedPayment == p;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedPayment = p),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.divider,
                            ),
                          ),
                          child: Text(
                            p,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  // Bank options for Transfer Bank
                  if (_selectedPayment == 'Transfer Bank') ...[
                    const SizedBox(height: 16),
                    Text(
                      'Pilih Bank',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _banks.map((bank) {
                        final selected = _selectedBank == bank;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedBank = bank),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppTheme.accent
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? AppTheme.accent
                                    : AppTheme.divider,
                              ),
                            ),
                            child: Text(
                              bank,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  // Card options for Kartu Kredit
                  if (_selectedPayment == 'Kartu Kredit') ...[
                    const SizedBox(height: 16),
                    Text(
                      'Pilih Jenis Kartu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _cards.map((card) {
                        final selected = _selectedCard == card;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCard = card),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppTheme.accent
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? AppTheme.accent
                                    : AppTheme.divider,
                              ),
                            ),
                            child: Text(
                              card,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Summary
            _SectionCard(
              title: 'Ringkasan Pesanan',
              icon: Icons.receipt_outlined,
              child: Column(
                children: [
                  _SummaryRow(
                      label: 'Subtotal', value: state.cartTotal),
                  _SummaryRow(
                      label: 'Ongkos Kirim ($_selectedCourier)',
                      value: shipping),
                  const Divider(height: 16),
                  _SummaryRow(
                      label: 'Total',
                      value: total,
                      isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
        child: ElevatedButton(
          onPressed: _loading ? null : () => _placeOrder(context, state),
          child: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Text('Bayar ${DummyData.formatPrice(total)}'),
        ),
      ),
    );
  }

  void _placeOrder(BuildContext context, AppState state) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _loading = true);
    final shippingAddress = '${_addressCtrl.text.trim()}, $_selectedDistrict, $_selectedCity';
    final error = await state.placeOrder(
      _selectedCourier,
      shippingAddress,
      city: _selectedCity,
      district: _selectedDistrict,
      paymentMethod: _selectedPayment,
      paymentProof: _paymentProof?.path,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    if (state.orders.isNotEmpty) {
      final newOrder = state.orders.first;
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => InvoiceScreen(order: newOrder),
        ),
      );
    }
  }

  double _getCost(String courier) {
    switch (courier) {
      case 'JNE': return 18000;
      case 'TIKI': return 16000;
      case 'SiCepat': return 14000;
      case 'J&T Express': return 15000;
      case 'Anteraja': return 13000;
      default: return 20000;
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isTotal;

  const _SummaryRow(
      {required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
          Text(
            DummyData.formatPrice(value),
            style: GoogleFonts.plusJakartaSans(
              fontSize: isTotal ? 18 : 13,
              fontWeight: FontWeight.w700,
              color: isTotal ? AppTheme.primary : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSuccessDialog extends StatelessWidget {
  final VoidCallback onDone;

  const _OrderSuccessDialog({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppTheme.success, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              'Pesanan Berhasil!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pesananmu sedang diproses oleh penjual. Kami akan memberi notifikasi saat pesanan dikirim.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDone,
                child: const Text('Kembali ke Beranda'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
