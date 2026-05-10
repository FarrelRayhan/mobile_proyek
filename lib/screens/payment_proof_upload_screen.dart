import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'other_screens.dart';

class PaymentProofUploadScreen extends StatefulWidget {
  const PaymentProofUploadScreen({super.key});

  @override
  PaymentProofUploadScreenState createState() => PaymentProofUploadScreenState();
}

class PaymentProofUploadScreenState extends State<PaymentProofUploadScreen> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  Future<void> _submitProof() async {
    if (_image != null) {
      final messenger = ScaffoldMessenger.of(context);
      final state = Provider.of<AppState>(context, listen: false);
      final address = state.currentUser?.address ?? 'Alamat tidak tersedia';
      final error = await state.placeOrder('JNE', address, paymentProofFile: _image);
      if (!mounted) return;
      if (error != null) {
        messenger.showSnackBar(
          SnackBar(content: Text(error)),
        );
        return;
      }

      // Get the newly created order (first in list)
      final newOrder = state.orders.first;

      // Navigate to invoice
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => InvoiceScreen(order: newOrder),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih gambar bukti pembayaran.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Bukti Pembayaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Silakan upload bukti pembayaran Anda setelah melakukan checkout.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _image != null
                ? Image.network(_image!.path, height: 200, fit: BoxFit.cover)
                : Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(child: Text('Tidak ada gambar dipilih')),
                  ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.photo_library),
                  label: Text('Galeri'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt),
                  label: Text('Kamera'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitProof,
              child: Text('Upload Bukti'),
            ),
          ],
        ),
      ),
    );
  }
}
