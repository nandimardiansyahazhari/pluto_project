import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/failures.dart';
import '../../data/datasources/digiflazz_remote_datasource.dart';
import '../../data/repositories/top_up_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/top_up_repository.dart';
import '../../domain/usecases/get_products.dart';

// Core
final dioProvider = Provider<Dio>((ref) => Dio());

// Data Source
final remoteDataSourceProvider = Provider<DigiflazzRemoteDataSource>((ref) {
  return DigiflazzRemoteDataSourceImpl(dio: ref.read(dioProvider));
});

// Repository
final topUpRepositoryProvider = Provider<TopUpRepository>((ref) {
  return TopUpRepositoryImpl(remoteDataSource: ref.read(remoteDataSourceProvider));
});

// Use Cases
final getProductsProvider = Provider<GetProducts>((ref) {
  return GetProducts(ref.read(topUpRepositoryProvider));
});

// State Management
final productListProvider = FutureProvider<List<Product>>((ref) async {
  final getProducts = ref.read(getProductsProvider);
  final result = await getProducts();
  return result.fold(
    (failure) => throw failure,
    (products) => products,
  );
});
