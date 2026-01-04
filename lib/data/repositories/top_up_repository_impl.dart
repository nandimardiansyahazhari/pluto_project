import 'package:fpdart/fpdart.dart';
import '../../core/failures.dart';
import '../../domain/repositories/top_up_repository.dart';
import '../../domain/entities/product.dart';
import '../datasources/digiflazz_remote_datasource.dart';

class TopUpRepositoryImpl implements TopUpRepository {
  final DigiflazzRemoteDataSource remoteDataSource;

  TopUpRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final remoteProducts = await remoteDataSource.getProducts();
      return Right(remoteProducts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> purchaseCredit(String buyerSkuCode, String customerNo, String refId) async {
    try {
      final result = await remoteDataSource.purchaseCredit(buyerSkuCode, customerNo, refId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
