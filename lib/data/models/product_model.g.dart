// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  productName: json['productName'] as String,
  category: json['category'] as String,
  brand: json['brand'] as String,
  type: json['type'] as String,
  sellerName: json['sellerName'] as String,
  price: (json['price'] as num).toDouble(),
  buyerSkuCode: json['buyerSkuCode'] as String,
  buyerProductStatus: json['buyerProductStatus'] as bool,
  sellerProductStatus: json['sellerProductStatus'] as bool,
  unlimitedStock: json['unlimitedStock'] as bool,
  stock: (json['stock'] as num).toInt(),
  multi: json['multi'] as bool,
  startCutOff: json['startCutOff'] as String,
  endCutOff: json['endCutOff'] as String,
  desc: json['desc'] as String,
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'productName': instance.productName,
      'category': instance.category,
      'brand': instance.brand,
      'type': instance.type,
      'sellerName': instance.sellerName,
      'price': instance.price,
      'buyerSkuCode': instance.buyerSkuCode,
      'buyerProductStatus': instance.buyerProductStatus,
      'sellerProductStatus': instance.sellerProductStatus,
      'unlimitedStock': instance.unlimitedStock,
      'stock': instance.stock,
      'multi': instance.multi,
      'startCutOff': instance.startCutOff,
      'endCutOff': instance.endCutOff,
      'desc': instance.desc,
    };
