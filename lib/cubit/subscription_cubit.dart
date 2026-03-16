import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/revenue_cat_service.dart';

// ─── States ───────────────────────────────────────────────────────────────────

abstract class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final bool isPremium;
  final Map<String, dynamic> details;

  SubscriptionLoaded({required this.isPremium, required this.details});
}

class SubscriptionError extends SubscriptionState {
  final String message;
  SubscriptionError(this.message);
}

class OfferingsLoaded extends SubscriptionState {
  final bool isPremium;
  final Offerings offerings;

  OfferingsLoaded({required this.isPremium, required this.offerings});
}

class PurchaseSuccess extends SubscriptionState {
  final CustomerInfo customerInfo;
  PurchaseSuccess(this.customerInfo);
}

class RestoreSuccess extends SubscriptionState {
  final bool isPremium;
  RestoreSuccess(this.isPremium);
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit() : super(SubscriptionInitial()) {
    // Listen for real-time subscription updates from RevenueCat
    RevenueCatService.addCustomerInfoListener(_onCustomerInfoUpdated);
  }

  /// Load current subscription status and details
  Future<void> loadSubscriptionStatus() async {
    emit(SubscriptionLoading());
    try {
      final isPremium = await RevenueCatService.isPremium();
      final details = await RevenueCatService.getSubscriptionDetails();
      emit(SubscriptionLoaded(isPremium: isPremium, details: details));
    } catch (e) {
      emit(SubscriptionError('Failed to load subscription: ${e.toString()}'));
    }
  }

  /// Load available offerings to show on the paywall
  Future<void> loadOfferings() async {
    emit(SubscriptionLoading());
    try {
      final isPremium = await RevenueCatService.isPremium();

      // If already premium, no need to show offerings
      if (isPremium) {
        final details = await RevenueCatService.getSubscriptionDetails();
        emit(SubscriptionLoaded(isPremium: true, details: details));
        return;
      }

      final offerings = await RevenueCatService.getOfferings();
      if (offerings == null || offerings.current == null) {
        emit(SubscriptionError('No offerings available. Check RevenueCat dashboard.'));
        return;
      }

      emit(OfferingsLoaded(isPremium: false, offerings: offerings));
    } catch (e) {
      emit(SubscriptionError('Failed to load offerings: ${e.toString()}'));
    }
  }

  /// Purchase a package
  Future<void> purchase(Package package) async {
    emit(SubscriptionLoading());
    try {
      final customerInfo = await RevenueCatService.purchasePackage(package);
      if (customerInfo != null) {
        emit(PurchaseSuccess(customerInfo));
      } else {
        // User cancelled
        await loadOfferings();
      }
    } catch (e) {
      emit(SubscriptionError('Purchase failed: ${e.toString()}'));
    }
  }

  /// Restore purchases — required by app stores
  Future<void> restorePurchases() async {
    emit(SubscriptionLoading());
    try {
      final customerInfo = await RevenueCatService.restorePurchases();
      final isPremium = customerInfo.entitlements.active
          .containsKey(RevenueCatService.premiumEntitlement);
      emit(RestoreSuccess(isPremium));
    } catch (e) {
      emit(SubscriptionError('Restore failed: ${e.toString()}'));
    }
  }

  /// Called by RevenueCat listener when subscription state changes externally
  void _onCustomerInfoUpdated(CustomerInfo customerInfo) {
    final isPremium = customerInfo.entitlements.active
        .containsKey(RevenueCatService.premiumEntitlement);
    emit(SubscriptionLoaded(isPremium: isPremium, details: {
      'isActive': isPremium,
    }));
  }

  @override
  Future<void> close() {
    RevenueCatService.removeCustomerInfoListener(_onCustomerInfoUpdated);
    return super.close();
  }
}