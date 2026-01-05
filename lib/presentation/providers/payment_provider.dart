import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PaymentStatus { initial, pending, success, failed }

class PaymentState {
  final PaymentStatus status;
  final String qrData;
  final int timeLeft;

  const PaymentState({
    this.status = PaymentStatus.initial,
    this.qrData = '',
    this.timeLeft = 300, // 5 minutes
  });

  PaymentState copyWith({
    PaymentStatus? status,
    String? qrData,
    int? timeLeft,
  }) {
    return PaymentState(
      status: status ?? this.status,
      qrData: qrData ?? this.qrData,
      timeLeft: timeLeft ?? this.timeLeft,
    );
  }
}

class PaymentNotifier extends Notifier<PaymentState> {
  Timer? _timer;

  @override
  PaymentState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const PaymentState();
  }

  void generateQR(double amount) {
    final qrString =
        "00020101021226680016ID.CO.DIGIFLAZZ0109DIGIFLAZZ51450015ID.OR.ID.QRIS5204481453033605802ID5909Digiflazz6007Jakarta61051234562070703A016304${amount.toInt().toString().padLeft(4, '0')}";

    state = state.copyWith(
      status: PaymentStatus.pending,
      qrData: qrString,
      timeLeft: 300,
    );

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft > 0) {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      } else {
        state = state.copyWith(status: PaymentStatus.failed);
        _timer?.cancel();
      }
    });

    // Simulate auto-success after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (state.status == PaymentStatus.pending) {
        state = state.copyWith(status: PaymentStatus.success);
        _timer?.cancel();
      }
    });
  }

  void simulateSuccess() {
    state = state.copyWith(status: PaymentStatus.success);
    _timer?.cancel();
  }
}

final paymentProvider = NotifierProvider<PaymentNotifier, PaymentState>(
  PaymentNotifier.new,
);
