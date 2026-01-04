import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String productName;
  final String category;
  final String brand;
  final String type;
  final String sellerName;
  final double price;
  final String buyerSkuCode;
  final bool buyerProductStatus;
  final bool sellerProductStatus;
  final bool unlimitedStock;
  final int stock;
  final bool multi;
  final String startCutOff;
  final String endCutOff;
  final String desc;

  const Product({
    required this.productName,
    required this.category,
    required this.brand,
    required this.type,
    required this.sellerName,
    required this.price,
    required this.buyerSkuCode,
    required this.buyerProductStatus,
    required this.sellerProductStatus,
    required this.unlimitedStock,
    required this.stock,
    required this.multi,
    required this.startCutOff,
    required this.endCutOff,
    required this.desc,
  });

  @override
  List<Object?> get props => [
        productName,
        category,
        brand,
        type,
        sellerName,
        price,
        buyerSkuCode,
        buyerProductStatus,
        sellerProductStatus,
        unlimitedStock,
        stock,
        multi,
        startCutOff,
        endCutOff,
        desc,
      ];
}
