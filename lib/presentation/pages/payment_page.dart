import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/product.dart';
import '../providers/payment_provider.dart';
import '../providers/auth_provider.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final Product product;

  const PaymentPage({super.key, required this.product});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  final _mlUserIdController = TextEditingController();
  final _mlZoneIdController = TextEditingController();
  bool _isCheckingNickname = false;
  bool _isVerifyingPayment = false;
  String? _detectedNickname;
  String? _lookupError;
  final Dio _dio = Dio();

  bool get _requiresMlAccount =>
      widget.product.brand.toLowerCase() == 'mobile legends';

  String? get _customerNo {
    if (!_requiresMlAccount) return null;
    final userId = _mlUserIdController.text.trim();
    final zoneId = _mlZoneIdController.text.trim();
    if (userId.isEmpty || zoneId.isEmpty) return null;
    return '$userId$zoneId';
  }

  @override
  void dispose() {
    _mlUserIdController.dispose();
    _mlZoneIdController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _lookupMlNickname() async {
    final userId = _mlUserIdController.text.trim();
    final zoneId = _mlZoneIdController.text.trim();

    if (userId.isEmpty || zoneId.isEmpty) {
      setState(() {
        _lookupError = 'User ID dan Zone ID wajib diisi.';
        _detectedNickname = null;
      });
      return;
    }

    if (!RegExp(r'^\d+$').hasMatch(userId) ||
        !RegExp(r'^\d+$').hasMatch(zoneId)) {
      setState(() {
        _lookupError = 'User ID dan Zone ID harus berupa angka.';
        _detectedNickname = null;
      });
      return;
    }

    setState(() {
      _isCheckingNickname = true;
      _lookupError = null;
      _detectedNickname = null;
    });

    try {
      final response = await _dio.post(
        'http://localhost:3000/api/game/mobile-legends/lookup',
        data: {
          'userId': userId,
          'zoneId': zoneId,
        },
      );

      final data = response.data;
      final nickname = data is Map<String, dynamic>
          ? data['nickname'] as String?
          : null;

      if (!mounted) return;
      setState(() {
        _isCheckingNickname = false;
        if (nickname == null || nickname.isEmpty) {
          _lookupError = 'Akun tidak ditemukan.';
          _detectedNickname = null;
        } else {
          _detectedNickname = nickname;
          _lookupError = null;
        }
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final serverError = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['error'] as String?)
          : null;

      setState(() {
        _isCheckingNickname = false;
        _detectedNickname = null;
        _lookupError = serverError ?? 'Gagal cek akun. Pastikan backend aktif.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isCheckingNickname = false;
        _detectedNickname = null;
        _lookupError = 'Terjadi kesalahan saat cek akun.';
      });
    }
  }

  bool _validateBeforePay() {
    if (!_requiresMlAccount) return true;

    final userId = _mlUserIdController.text.trim();
    final zoneId = _mlZoneIdController.text.trim();
    final isUserNumeric = RegExp(r'^\d+$').hasMatch(userId);
    final isZoneNumeric = RegExp(r'^\d+$').hasMatch(zoneId);

    if (userId.isEmpty || zoneId.isEmpty || !isUserNumeric || !isZoneNumeric) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi User ID & Zone ID Mobile Legends dengan benar.'),
        ),
      );
      return false;
    }

    if (_detectedNickname == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cek nickname dulu sebelum lanjut pembayaran.'),
        ),
      );
      return false;
    }

    return true;
  }

  void _resetPaymentDraft() {
    ref.read(paymentProvider.notifier).reset();
    setState(() {
      _detectedNickname = null;
      _lookupError = null;
      _isVerifyingPayment = false;
    });
  }

  void _generatePaymentQr() {
    if (!_validateBeforePay()) return;
    ref.read(paymentProvider.notifier).generateQR(widget.product.price);
  }

  Future<void> _verifyPayment() async {
    final paymentNotifier = ref.read(paymentProvider.notifier);

    setState(() {
      _isVerifyingPayment = true;
    });

    try {
      final response = await _dio.post(
        'http://localhost:3000/api/payment/verify',
        data: {
          'buyerSkuCode': widget.product.buyerSkuCode,
          'amount': widget.product.price,
          'customerNo': _customerNo,
        },
      );

      final data = response.data;
      final isSuccess = data is Map<String, dynamic>
          ? data['success'] == true
          : false;

      if (!mounted) return;

      if (isSuccess) {
        paymentNotifier.simulateSuccess();
      } else {
        paymentNotifier.markFailed();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran belum terverifikasi.'),
          ),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      paymentNotifier.markFailed();
      final serverError = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['error'] as String?)
          : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            serverError ?? 'Gagal memverifikasi pembayaran. Pastikan backend aktif.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      paymentNotifier.markFailed();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat verifikasi pembayaran.'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isVerifyingPayment = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final hasGeneratedQr = paymentState.qrData.isNotEmpty;

    ref.listen<PaymentState>(paymentProvider, (previous, next) {
      if (next.status == PaymentStatus.success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: Theme.of(context).cardTheme.color,
            title: const Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 64),
                SizedBox(height: 16),
                Text(
                  "Payment Successful!",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            content: const Text(
              "Your top-up has been processed.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close dialog
                  if (context.mounted) {
                    final isLoggedIn = ref.read(authProvider).isAuthenticated;
                    context.go(isLoggedIn ? '/dashboard' : '/');
                  }
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Order Summary
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    if (_requiresMlAccount) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Data Akun Mobile Legends',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _mlUserIdController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'User ID',
                          hintText: 'Contoh: 12345678',
                        ),
                        onChanged: (_) {
                          _resetPaymentDraft();
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _mlZoneIdController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Zone ID',
                          hintText: 'Contoh: 1234',
                        ),
                        onChanged: (_) {
                          _resetPaymentDraft();
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isCheckingNickname
                              ? null
                              : _lookupMlNickname,
                          icon: _isCheckingNickname
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.search),
                          label: Text(
                            _isCheckingNickname
                                ? 'Mengecek akun...'
                                : 'Cek User ID & Zone ID',
                          ),
                        ),
                      ),
                      if (_detectedNickname != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_user,
                              color: Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Atas nama: $_detectedNickname',
                                style: const TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_lookupError != null) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _lookupError!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                    Text(
                      "Scan QRIS to Pay",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: paymentState.qrData.isNotEmpty
                          ? QrImageView(
                              data: paymentState.qrData,
                              version: QrVersions.auto,
                              size: 200.0,
                            )
                          : const SizedBox(
                              height: 200,
                              width: 200,
                              child: Center(
                                child: Text(
                                  'Lengkapi data lalu buat QR pembayaran',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Total Amount",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                    Text(
                      "Rp ${widget.product.price.toStringAsFixed(0)}",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Time remaining: ${_formatDuration(paymentState.timeLeft)}",
                      style: TextStyle(
                        color: paymentState.timeLeft < 60
                            ? Colors.red
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Item:"),
                        Text(
                          widget.product.productName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Brand:"),
                        Text(widget.product.brand),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: hasGeneratedQr ? null : _generatePaymentQr,
                        child: const Text('Buat QR Pembayaran'),
                      ),
                    ),
                    if (hasGeneratedQr) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _isVerifyingPayment ? null : _verifyPayment,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          child: _isVerifyingPayment
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Saya Sudah Bayar, Verifikasi'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Demo mode: verifikasi pembayaran masih memakai backend mock.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
