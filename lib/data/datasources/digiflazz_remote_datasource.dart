import 'package:dio/dio.dart';
import '../../core/failures.dart';
import '../models/product_model.dart';

abstract class DigiflazzRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<bool> purchaseCredit(
    String buyerSkuCode,
    String customerNo,
    String refId,
  );
}

class DigiflazzRemoteDataSourceImpl implements DigiflazzRemoteDataSource {
  final Dio dio;
  final bool useMock;

  DigiflazzRemoteDataSourceImpl({required this.dio, this.useMock = true});

  @override
  Future<List<ProductModel>> getProducts() async {
    if (useMock) {
      // Mock data based on Digiflazz structure
      await Future.delayed(const Duration(seconds: 1)); // Simulate network
      return [
        const ProductModel(
          productName: "Mobile Legends 10 Diamonds",
          category: "Games",
          brand: "Mobile Legends",
          type: "Game Direct",
          sellerName: "Digiflazz",
          price: 3000,
          buyerSkuCode: "ml10",
          buyerProductStatus: true,
          sellerProductStatus: true,
          unlimitedStock: true,
          stock: 999,
          multi: true,
          startCutOff: "00:00",
          endCutOff: "23:59",
          desc: "10 Diamonds direct topup",
        ),
        const ProductModel(
          productName: "Mobile Legends 50 Diamonds",
          category: "Games",
          brand: "Mobile Legends",
          type: "Game Direct",
          sellerName: "Digiflazz",
          price: 14000,
          buyerSkuCode: "ml50",
          buyerProductStatus: true,
          sellerProductStatus: true,
          unlimitedStock: true,
          stock: 999,
          multi: true,
          startCutOff: "00:00",
          endCutOff: "23:59",
          desc: "50 Diamonds direct topup",
        ),
        const ProductModel(
          productName: "Free Fire 100 Diamonds",
          category: "Games",
          brand: "Free Fire",
          type: "Game Direct",
          sellerName: "Digiflazz",
          price: 15000,
          buyerSkuCode: "ff100",
          buyerProductStatus: true,
          sellerProductStatus: true,
          unlimitedStock: true,
          stock: 999,
          multi: true,
          startCutOff: "00:00",
          endCutOff: "23:59",
          desc: "100 Diamonds",
        ),
        const ProductModel(
          productName: "PUBG Mobile 60 UC",
          category: "Games",
          brand: "PUBG Mobile",
          type: "Game Direct",
          sellerName: "Digiflazz",
          price: 15000,
          buyerSkuCode: "pubg60",
          buyerProductStatus: true,
          sellerProductStatus: true,
          unlimitedStock: true,
          stock: 999,
          multi: true,
          startCutOff: "00:00",
          endCutOff: "23:59",
          desc: "60 UC Global",
        ),
        const ProductModel(
          productName: "PUBG Mobile 325 UC",
          category: "Games",
          brand: "PUBG Mobile",
          type: "Game Direct",
          sellerName: "Digiflazz",
          price: 75000,
          buyerSkuCode: "pubg325",
          buyerProductStatus: true,
          sellerProductStatus: true,
          unlimitedStock: true,
          stock: 999,
          multi: true,
          startCutOff: "00:00",
          endCutOff: "23:59",
          desc: "325 UC Global",
        ),
      ];
    } else {
      // Real API implementation
      // final response = await dio.post('https://api.digiflazz.com/v1/price-list', ...);
      // For now, only Mock is active until credentials are provided.
      throw const ServerFailure("Real API not implemented yet");
    }
  }

  @override
  Future<bool> purchaseCredit(
    String buyerSkuCode,
    String customerNo,
    String refId,
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    return true; // Mock success
  }
}
