import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_go/core/errors/exceptions.dart';
import 'package:universal_go/features/cart/data/models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> saveCartItems(List<CartItemModel> items);
  Future<void> clearCartItems();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String cartItemsKey = 'CART_ITEMS';

  CartLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<CartItemModel>> getCartItems() async {
    try {
      final jsonString = sharedPreferences.getString(cartItemsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => CartItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get cart items: ${e.toString()}');
    }
  }

  @override
  Future<void> saveCartItems(List<CartItemModel> items) async {
    try {
      final jsonList = items.map((item) => item.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await sharedPreferences.setString(cartItemsKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to save cart items: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCartItems() async {
    try {
      await sharedPreferences.remove(cartItemsKey);
    } catch (e) {
      throw CacheException('Failed to clear cart items: ${e.toString()}');
    }
  }
}

