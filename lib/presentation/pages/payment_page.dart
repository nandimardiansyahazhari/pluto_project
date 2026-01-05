import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../domain/entities/product.dart';
import '../providers/payment_provider.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final Product product;

  const PaymentPage({super.key, required this.product});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  @override
  void initState() {
    super.initState();
    // Generate QR when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentProvider.notifier).generateQR(widget.product.price);
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);

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
                  // Use the outer context (PaymentPage's context) to navigate
                  if (context.mounted) {
                    context.go('/dashboard');
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
                              child: Center(child: CircularProgressIndicator()),
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
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(paymentProvider.notifier).simulateSuccess();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        child: const Text("Simulate Success (Test Mode)"),
                      ),
                    ),
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
