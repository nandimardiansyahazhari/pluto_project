import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel extends Product {
  const ProductModel({
    required super.productName,
    required super.category,
    required super.brand,
    required super.type,
    required super.sellerName,
    required super.price,
    required super.buyerSkuCode,
    required super.buyerProductStatus,
    required super.sellerProductStatus,
    required super.unlimitedStock,
    required super.stock,
    required super.multi,
    required super.startCutOff,
    required super.endCutOff,
    required super.desc,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}
