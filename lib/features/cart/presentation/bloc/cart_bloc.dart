import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_go/features/cart/domain/entities/cart_entity.dart';
import 'package:universal_go/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:universal_go/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:universal_go/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:universal_go/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:universal_go/features/cart/domain/usecases/update_cart_quantity_usecase.dart';
import 'package:universal_go/features/cart/presentation/bloc/cart_event.dart';
import 'package:universal_go/features/cart/presentation/bloc/cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase getCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final UpdateCartQuantityUseCase updateCartQuantityUseCase;
  final ClearCartUseCase clearCartUseCase;

  CartBloc({
    required this.getCartUseCase,
    required this.addToCartUseCase,
    required this.removeFromCartUseCase,
    required this.updateCartQuantityUseCase,
    required this.clearCartUseCase,
  }) : super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartQuantity>(_onUpdateCartQuantity);
    on<ClearCart>(_onClearCart);
  }

  Future<void> _onLoadCart(
    LoadCart event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    final result = await getCartUseCase();
    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (cart) => emit(CartLoaded(cart: cart)),
    );
  }

  Future<void> _onAddToCart(
    AddToCart event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    final result = await addToCartUseCase(AddToCartParams(item: event.item));
    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (cart) {
        emit(CartLoaded(cart: cart));
        // Reload cart to ensure state is fresh
        add(LoadCart());
      },
    );
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    final result = await removeFromCartUseCase(
      RemoveFromCartParams(productId: event.productId),
    );
    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (cart) {
        emit(CartLoaded(cart: cart));
        // Reload cart to ensure state is fresh
        add(LoadCart());
      },
    );
  }

  Future<void> _onUpdateCartQuantity(
    UpdateCartQuantity event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    final result = await updateCartQuantityUseCase(
      UpdateQuantityParams(
        productId: event.productId,
        quantity: event.quantity,
      ),
    );
    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (cart) {
        emit(CartLoaded(cart: cart));
        // Reload cart to ensure state is fresh
        add(LoadCart());
      },
    );
  }

  Future<void> _onClearCart(
    ClearCart event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    final result = await clearCartUseCase();
    result.fold(
      (failure) => emit(CartError(message: failure.message)),
      (_) {
        emit(const CartLoaded(cart: CartEntity(items: [], shopId: null)));
        // Reload cart to ensure state is fresh
        add(LoadCart());
      },
    );
  }
}

