import 'package:fpdart/fpdart.dart';
import '../../core/failures.dart';
import '../entities/product.dart';

abstract class TopUpRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, bool>> purchaseCredit(String buyerSkuCode, String customerNo, String refId);
}
