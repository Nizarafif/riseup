import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File('assets/images/Logo.jpg');
  if (!file.existsSync()) {
    print('Error: assets/images/Logo.jpg tidak ditemukan.');
    return;
  }

  print('Membaca Logo.jpg...');
  final bytes = file.readAsBytesSync();
  final image = img.decodeJpg(bytes);
  if (image == null) {
    print('Error: Gagal men-decode Logo.jpg.');
    return;
  }

  print('Mengubah ukuran logo menjadi 350x350...');
  final resized = img.copyResize(image, width: 350, height: 350);

  print('Membuat kanvas putih 512x512...');
  final canvas = img.Image(width: 512, height: 512);
  // Isi dengan warna putih (RGB: 255, 255, 255)
  img.fill(canvas, color: img.ColorRgb8(255, 255, 255));

  print('Menempelkan logo di tengah kanvas...');
  img.compositeImage(canvas, resized, dstX: 81, dstY: 81);

  print('Menyimpan Logo_padded.png...');
  final pngBytes = img.encodePng(canvas);
  File('assets/images/Logo_padded.png').writeAsBytesSync(pngBytes);
  print('Sukses membuat assets/images/Logo_padded.png!');
}
