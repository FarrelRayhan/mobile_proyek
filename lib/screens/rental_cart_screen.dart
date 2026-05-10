// rental_cart_screen.dart - Screen for rental cart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../app_state.dart';
import '../models.dart';
import '../widgets.dart';
import 'other_screens.dart';
import 'package:image_picker/image_picker.dart';

class RentalCartScreen extends StatelessWidget {
  const RentalCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.rentalCartItems;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text('Keranjang Sewa (${state.rentalCartCount})'),
        backgroundColor: Colors.white,
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: state.clearRentalCart,
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
              icon: Icons.inventory_2_outlined,
              title: 'Keranjang Sewa Kosong',
              subtitle: 'Tambahkan produk sewa ke keranjang untuk mulai',
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _RentalCartItemCard(item: items[i]),
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
                            'Total Sewa (${state.rentalCartCount} item)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            CurrencyFormat.formatPrice(state.rentalCartTotal),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
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
                              builder: (_) => const RentalCheckoutScreen(),
                            ),
                          ),
                          child: Text(
                              'Lanjut ke Checkout Sewa • ${CurrencyFormat.formatPrice(state.rentalCartTotal)}'),
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

class _RentalCartItemCard extends StatelessWidget {
  final RentalCartItem item;

  const _RentalCartItemCard({required this.item});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      '${CurrencyFormat.formatPrice(item.product.rentalPrice ?? 0)}/hari',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // Delete button
              IconButton(
                onPressed: () => state.removeFromRentalCart(item.product.id),
                icon: const Icon(Icons.delete_outline, color: AppTheme.error),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Rental dates
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_formatDate(item.rentalStartDate)} - ${_formatDate(item.rentalEndDate)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${item.rentalDays} hari',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Quantity controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _QtyBtn(
                    icon: Icons.remove,
                    onTap: () => state.updateRentalCartQuantity(
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
                    onTap: () => state.updateRentalCartQuantity(
                        item.product.id, item.quantity + 1),
                  ),
                ],
              ),
              Text(
                CurrencyFormat.formatPrice(item.total),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${months[dt.month - 1]}';
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
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppTheme.textPrimary),
      ),
    );
  }
}

// ─── Rental Checkout Screen ─────────────────────────────────────────────────
class RentalCheckoutScreen extends StatefulWidget {
  const RentalCheckoutScreen({super.key});

  @override
  State<RentalCheckoutScreen> createState() => _RentalCheckoutScreenState();
}

class _RentalCheckoutScreenState extends State<RentalCheckoutScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _paymentProof;
  XFile? _ktpFile;
  String _selectedCourier = 'JNE';
  String _selectedPayment = 'Transfer Bank';
  bool _loading = false;
  final _addressCtrl = TextEditingController(text: 'Jl. Raya Bandung No. 12, Kota Bandung');
  final _nameCtrl = TextEditingController(text: 'Ahmad Fauzi');
  final _phoneCtrl = TextEditingController(text: '081234567890');
  String _selectedCity = RegionData.cities.first;
  String _selectedDistrict = RegionData.districts[RegionData.cities.first]!.first;

  final _banks = ['BCA', 'Mandiri', 'BNI', 'BRI', 'BTN'];
  String? _selectedBank;
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

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().currentUser;
    if (user != null) {
      _addressCtrl.text = user.address.isNotEmpty ? user.address : _addressCtrl.text;
      _nameCtrl.text = user.name.isNotEmpty ? user.name : _nameCtrl.text;
      _phoneCtrl.text = user.phone.isNotEmpty ? user.phone : _phoneCtrl.text;
    }
  }

  double _getShippingCost() {
    switch (_selectedCourier) {
      case 'JNE': return 18000;
      case 'TIKI': return 16000;
      case 'SiCepat': return 14000;
      case 'J&T Express': return 15000;
      case 'Anteraja': return 13000;
      default: return 20000;
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

  Future<void> _pickKtp() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _ktpFile = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.rentalCartItems;
    final shipping = _getShippingCost();
    final total = state.rentalCartTotal + shipping;
    final user = state.currentUser;
    final needsKtp = user == null || (!user.hasKtpUploaded && !user.isKtpVerified);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Checkout Sewa'),
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
            // Items
            _SectionCard(
              title: 'Produk Sewa',
              icon: Icons.inventory_2_outlined,
              child: Column(
                children: items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                            child: const Icon(Icons.image_outlined, color: AppTheme.primary),
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
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${item.quantity}x • ${item.rentalDays} hari',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormat.formatPrice(item.total),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              )
            ),
            const SizedBox(height: 14),

            // Alamat
            _SectionCard(
              title: 'Alamat Pengiriman',
              icon: Icons.location_on_outlined,
              child: Column(
                children: [
                  TextField(
                    controller: _nameCtrl,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressCtrl,
                    maxLines: 2,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Alamat Lengkap',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                              .map((city) => DropdownMenuItem(value: city, child: Text(city)))
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
                              .map((district) => DropdownMenuItem(value: district, child: Text(district)))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedDistrict = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Nomor Telepon',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            
            if (needsKtp) ...[
              _SectionCard(
                title: 'Upload KTP',
                icon: Icons.badge_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_ktpFile != null)
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _ktpFile!.path,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _pickKtp,
                        icon: const Icon(Icons.upload_file),
                        label: Text(_ktpFile == null
                            ? 'Unggah Foto KTP'
                            : 'Ganti Foto KTP'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'KTP wajib diunggah untuk transaksi sewa barang.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.error,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

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

            // Pilih Kurir
            _SectionCard(
              title: 'Jasa Pengiriman',
              icon: Icons.local_shipping_outlined,
              child: Column(
                children: AppConstants.couriers.map((c) {
                  final cost = _getShippingCost();
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
                            CurrencyFormat.formatPrice(cost),
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

            // Payment
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
                      label: 'Total Sewa', value: state.rentalCartTotal),
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
          onPressed: _loading ? null : () => _placeOrder(context, state, needsKtp),
          child: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Text('Bayar Sewa ${CurrencyFormat.formatPrice(total)}'),
        ),
      ),
    );
  }

  void _placeOrder(BuildContext context, AppState state, bool needsKtp) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    
    if (_addressCtrl.text.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Mohon isi alamat lengkap')));
      return;
    }
    if (needsKtp && _ktpFile == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Mohon unggah foto KTP untuk transaksi sewa')));
      return;
    }
    
    setState(() => _loading = true);
    final shippingAddress = '${_addressCtrl.text.trim()}, $_selectedDistrict, $_selectedCity';
    
    String apiPaymentMethod = 'transfer';
    if (_selectedPayment == 'COD') {
      apiPaymentMethod = 'cod';
    }

    final error = await state.placeRentalOrder(
      shippingAddress,
      courier: _selectedCourier,
      paymentMethod: apiPaymentMethod,
      phone: _phoneCtrl.text,
      receiverName: _nameCtrl.text,
      paymentProofFile: _paymentProof,
      ktpFile: needsKtp ? _ktpFile : null,
    );
    
    if (!mounted) return;
    setState(() => _loading = false);
    
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    navigator.popUntil((route) => route.isFirst);
    messenger.showSnackBar(
      const SnackBar(content: Text('Pesanan sewa berhasil dibuat!')),
    );
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
            CurrencyFormat.formatPrice(value),
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
