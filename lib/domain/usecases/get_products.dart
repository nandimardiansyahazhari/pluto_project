import 'package:fpdart/fpdart.dart';
import '../../core/failures.dart';
import '../entities/product.dart';
import '../repositories/top_up_repository.dart';

class GetProducts {
  final TopUpRepository repository;

  GetProducts(this.repository);

  Future<Either<Failure, List<Product>>> call() async {
    return await repository.getProducts();
  }
}
