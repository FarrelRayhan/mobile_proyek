import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_state.dart';
import '../theme.dart';
import '../models.dart';
import 'rental_return_detail_screen.dart'; // ⬅️ penting

class RentalReturnScreen extends StatelessWidget {
  const RentalReturnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final orders = state.rentalOrders;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Pengembalian Produk'),
        backgroundColor: Colors.white,
      ),
      body: orders.isEmpty
          ? const Center(child: Text('Belum ada pesanan sewa'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, i) {
                final order = orders[i];
                final item = order.items.first;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Nama produk
                      Text(
                        item.product.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // 🔹 Durasi sewa
                      Text(
                        'Durasi: ${item.rentalDays} hari',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // 🔹 Status
                      Text(
                        "Status: ${order.status}",
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 🔹 Tombol ke halaman detail
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: order.status == 'Dikembalikan'
                              ? null // disable kalau sudah
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          RentalReturnDetailScreen(order: order),
                                    ),
                                  );
                                },
                          child: Text(
                            order.status == 'Dikembalikan'
                                ? 'Sudah Dikembalikan'
                                : 'Kembalikan Produk',
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}