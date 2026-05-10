import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models.dart';
import '../theme.dart';

class RentalReturnDetailScreen extends StatefulWidget {
  final RentalOrder order;

  const RentalReturnDetailScreen({super.key, required this.order});

  @override
  State<RentalReturnDetailScreen> createState() => _RentalReturnDetailScreenState();
}

class _RentalReturnDetailScreenState extends State<RentalReturnDetailScreen> {
  final TextEditingController _resiCtrl = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.order.items.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengembalian Produk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PRODUCT
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Image.network(
                    item.product.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Durasi Sewa: ${item.rentalDays} hari',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ALAMAT TOKO
            Text('Alamat Toko (Tujuan Pengembalian)'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Campify Outdoor Store\nJl. Petualangan No. 123, Kota Bandung, Jawa Barat\nSilakan kirimkan barang ke alamat di atas.',
              ),
            ),

            const SizedBox(height: 16),

            // DENDA + STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Total Denda'),
                    Text('Rp 0', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      'Dihitung otomatis jika terlambat',
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('Status Barang'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('DALAM MASA SEWA'),
                    )
                  ],
                )
              ],
            ),

            const SizedBox(height: 20),

            // INPUT RESI
            Text('Input Resi Pengembalian'),
            const SizedBox(height: 6),
            TextField(
              controller: _resiCtrl,
              decoration: const InputDecoration(
                hintText: 'Masukkan nomor resi pengiriman balik',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // UPLOAD DENDA
            Text('Bukti Pembayaran Denda (Jika Ada)'),
            const SizedBox(height: 6),

            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _image == null
                    ? const Center(child: Text('Upload gambar'))
                    : Image.file(_image!, fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 24),

            // BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pengembalian diproses')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Kirim Pengembalian'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
