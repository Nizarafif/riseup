import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../config/revenue_cat_config.dart';

class RevenueCatService {
  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Inisialisasi SDK RevenueCat menggunakan API Key yang sesuai.
  static Future<void> initialize() async {
    try {
      if (_initialized) return;

      // Set tingkat log ke mode debug untuk mempermudah pelacakan error
      await Purchases.setLogLevel(LogLevel.debug);

      String apiKey = '';
      if (Platform.isAndroid) {
        apiKey = RevenueCatConfig.apiKeyAndroid;
      } else if (Platform.isIOS) {
        apiKey = RevenueCatConfig.apiKeyIOS;
      }

      // Cegah crash jika API Key masih menggunakan placeholder default
      if (apiKey.isEmpty || apiKey.contains('example') || apiKey.contains('api_key')) {
        debugPrint('RevenueCat: API Key masih berupa contoh. SDK berjalan dalam simulasi mode mock.');
        return;
      }

      PurchasesConfiguration configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);
      _initialized = true;
      debugPrint('RevenueCat: SDK Berhasil diinisialisasi.');
    } catch (e) {
      debugPrint('RevenueCat: Gagal menginisialisasi SDK: $e');
    }
  }

  /// Mengambil penawaran paket (Offerings) dari Dashboard RevenueCat.
  static Future<Offerings?> getOfferings() async {
    if (!_initialized) {
      debugPrint('RevenueCat: Gagal mengambil Offerings karena SDK tidak aktif.');
      return null;
    }
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('RevenueCat: Gagal mengambil data penawaran: $e');
      return null;
    }
  }

  /// Melakukan pembelian paket langganan.
  /// Jika SDK tidak diaktifkan (kunci masih default), ini akan mensimulasikan pembelian sukses setelah delay 1.5 detik.
  static Future<bool> purchasePackage(Package? package) async {
    if (!_initialized || package == null) {
      debugPrint('RevenueCat (Simulasi): Menjalankan pembelian simulasi sukses untuk pengujian UI.');
      await Future.delayed(const Duration(milliseconds: 1500)); // Delay simulasi ~1.5 detik
      return true;
    }
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      return customerInfo.entitlements.all[RevenueCatConfig.entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint('RevenueCat: Transaksi gagal atau dibatalkan oleh pengguna: $e');
      return false;
    }
  }

  /// Mengecek status langganan premium pengguna dari profil pelanggan RevenueCat.
  static Future<bool> checkPremiumStatus() async {
    if (!_initialized) return false;
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[RevenueCatConfig.entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint('RevenueCat: Gagal mengecek status premium: $e');
      return false;
    }
  }
}
