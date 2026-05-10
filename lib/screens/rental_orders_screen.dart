// rental_orders_screen.dart - Screen for rental orders history
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../app_state.dart';
import '../models.dart';
import '../widgets.dart';

class RentalOrdersScreen extends StatelessWidget {
  const RentalOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<AppState>().rentalOrders;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Riwayat Pesanan Sewa'),
        backgroundColor: Colors.white,
      ),
      body: orders.isEmpty
          ? const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Belum Ada Pesanan Sewa',
              subtitle: 'Pesanan sewa yang kamu buat akan muncul di sini',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _RentalOrderCard(order: orders[i]),
            ),
    );
  }
}

class _RentalOrderCard extends StatelessWidget {
  final RentalOrder order;

  const _RentalOrderCard({required this.order});

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
          // Rental period
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Periode Sewa: ${_formatDate(order.rentalStartDate)} - ${_formatDate(order.rentalEndDate)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
                          '${item.quantity}x • ${item.rentalDays} hari',
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
          // Address
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppTheme.textLight),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.address,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                    CurrencyFormat.formatPrice(order.total),
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
                  if (order.status == 'Menunggu') ...[
                    ElevatedButton(
                      onPressed: () => _showPaymentProofDialog(context, state, order.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        textStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Upload Bukti'),
                    ),
                  ],
                  if (order.status == 'Selesai') ...[
                    OutlinedButton(
                      onPressed: () {},
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

  void _showPaymentProofDialog(BuildContext context, AppState state, String orderId) {
    final _ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Upload Bukti Pembayaran',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Silakan upload bukti pembayaran dengan memasukkan URL gambar atau informasi pembayaran.',
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                hintText: 'Masukkan URL bukti pembayaran',
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_ctrl.text.isNotEmpty) {
                state.uploadPaymentProof(orderId, _ctrl.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bukti pembayaran berhasil diupload!')),
                );
              }
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }
}
