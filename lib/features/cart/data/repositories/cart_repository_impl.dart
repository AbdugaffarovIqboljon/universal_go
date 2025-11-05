import 'package:dartz/dartz.dart';
import 'package:universal_go/core/constants/app_constants.dart';
import 'package:universal_go/core/errors/exceptions.dart';
import 'package:universal_go/core/errors/failures.dart';
import 'package:universal_go/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:universal_go/features/cart/data/models/cart_item_model.dart';
import 'package:universal_go/features/cart/domain/entities/cart_entity.dart';
import 'package:universal_go/features/cart/domain/entities/cart_item_entity.dart';
import 'package:universal_go/features/cart/domain/repositories/cart_repository.dart';
import 'package:universal_go/features/shops/data/models/product_model.dart';
import 'package:universal_go/features/shops/domain/entities/product_entity.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      final items = await localDataSource.getCartItems();
      final shopId = items.isNotEmpty ? items.first.product.storeId : null;
      return Right(CartEntity(items: items, shopId: shopId));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> addItem(CartItemEntity item) async {
    try {
      final items = await localDataSource.getCartItems();
      
      // Check if product already exists in cart
      final existingIndex = items.indexWhere(
        (cartItem) => cartItem.product.id == item.product.id,
      );

      List<CartItemModel> updatedItems;
      if (existingIndex >= 0) {
        // Increment quantity if item exists (keep existing marked-up price)
        updatedItems = List.from(items);
        final existingItem = items[existingIndex];
        final existingProduct = existingItem.product;
        updatedItems[existingIndex] = CartItemModel(
          product: existingProduct is ProductModel
              ? existingProduct
              : ProductModel.fromEntity(existingProduct),
          quantity: existingItem.quantity + item.quantity,
          notes: item.notes ?? existingItem.notes,
        );
      } else {
        // Add new item with price markup applied
        final markedUpProduct = _applyPriceMarkup(item.product);
        final markedUpItem = CartItemEntity(
          product: markedUpProduct,
          quantity: item.quantity,
          notes: item.notes,
        );
        updatedItems = [
          ...items,
          CartItemModel.fromEntity(markedUpItem),
        ];
      }

      await localDataSource.saveCartItems(updatedItems);
      final shopId = updatedItems.isNotEmpty ? updatedItems.first.product.storeId : null;
      return Right(CartEntity(items: updatedItems, shopId: shopId));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  /// Applies price markup to a product when adding to cart
  ProductModel _applyPriceMarkup(ProductEntity product) {
    final markedUpPrice = product.price * (1 + AppConstants.priceMarkupRate);
    return ProductModel(
      id: product.id,
      storeId: product.storeId,
      name: product.name,
      price: markedUpPrice,
      inStock: product.inStock,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      image: product.image,
      description: product.description,
      stockQuantity: product.stockQuantity,
      category: product.category,
    );
  }

  @override
  Future<Either<Failure, CartEntity>> removeItem(String productId) async {
    try {
      final items = await localDataSource.getCartItems();
      final updatedItems = items.where(
        (item) => item.product.id != productId,
      ).toList();
      
      await localDataSource.saveCartItems(updatedItems);
      final shopId = updatedItems.isNotEmpty ? updatedItems.first.product.storeId : null;
      return Right(CartEntity(items: updatedItems, shopId: shopId));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) {
        // If quantity is 0 or less, remove the item
        return removeItem(productId);
      }

      final items = await localDataSource.getCartItems();
      final updatedItems = items.map((item) {
        if (item.product.id == productId) {
          final product = item.product;
          return CartItemModel(
            product: product is ProductModel
                ? product
                : ProductModel.fromEntity(product),
            quantity: quantity,
            notes: item.notes,
          );
        }
        return item;
      }).toList();

      await localDataSource.saveCartItems(updatedItems);
      final shopId = updatedItems.isNotEmpty ? updatedItems.first.product.storeId : null;
      return Right(CartEntity(items: updatedItems, shopId: shopId));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await localDataSource.clearCartItems();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

