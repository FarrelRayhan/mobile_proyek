import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';

class RentalReturnDetailScreen extends StatefulWidget {
  final RentalOrder order;

  const RentalReturnDetailScreen({super.key, required this.order});

  @override
  State<RentalReturnDetailScreen> createState() =>
      _RentalReturnDetailScreenState();
}

class _RentalReturnDetailScreenState extends State<RentalReturnDetailScreen> {
  final TextEditingController _resiCtrl = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String _metodeReturn = 'antar';
  bool _isSubmitting = false;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
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

            Text('Metode Pengembalian'),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    value: 'antar',
                    groupValue: _metodeReturn,
                    onChanged: (v) => setState(() => _metodeReturn = v!),
                    title: const Text('Antar Langsung'),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    value: 'kurir',
                    groupValue: _metodeReturn,
                    onChanged: (v) => setState(() => _metodeReturn = v!),
                    title: const Text('Kurir'),
                  ),
                ),
              ],
            ),

            // INPUT RESI
            if (_metodeReturn == 'kurir') Text('Input Resi Pengembalian'),
            const SizedBox(height: 6),
            if (_metodeReturn == 'kurir')
              TextField(
                controller: _resiCtrl,
                decoration: const InputDecoration(
                  hintText: 'Masukkan nomor resi pengiriman balik',
                  border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 20),

            // FOTO KONDISI BARANG
            Text(
              'Foto Kondisi Barang',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Upload gambar kondisi barang sebelum dikembalikan.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _image == null
                    ? const Center(child: Text('Upload foto kondisi barang'))
                    : Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galeri'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Kamera'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (item.orderDetailId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Detail pesanan tidak ditemukan')),
                          );
                          return;
                        }
                        if (_metodeReturn == 'kurir' &&
                            _resiCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Nomor resi wajib diisi')),
                          );
                          return;
                        }
                        if (_image == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Foto kondisi wajib diupload')),
                          );
                          return;
                        }

                        setState(() => _isSubmitting = true);
                        final error =
                            await context.read<AppState>().returnRentalOrder(
                                  orderId: widget.order.id,
                                  detailId: item.orderDetailId,
                                  metodeReturn: _metodeReturn,
                                  resiReturn: _resiCtrl.text.trim(),
                                  fotoKondisi: XFile(_image!.path),
                                );
                        if (!context.mounted) return;
                        setState(() => _isSubmitting = false);
                        if (error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error)),
                          );
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Pengembalian diproses')),
                        );
                        Navigator.pop(context);
                      },
                child:
                    Text(_isSubmitting ? 'Mengirim...' : 'Kirim Pengembalian'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
