import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Centralizes all RevenueCat SDK interactions.
/// This is the layer DSEs help developers get right.
class RevenueCatService {
  // Replace with your actual keys from RevenueCat dashboard
  static const String _appleApiKey = 'test_oExVijGRMtdlcwvQBpnIFpaVdqJ';
  static const String _googleApiKey = 'test_oExVijGRMtdlcwvQBpnIFpaVdqJ';

  // Entitlement identifier set in RevenueCat dashboard
  static const String premiumEntitlement = 'premium';

  // Offering identifier (set in RevenueCat dashboard)
  static const String defaultOffering = 'default';

  /// Initialize RevenueCat SDK. Call this in main() before runApp().
  static Future<void> initialize() async {
    // Enable debug logs in development
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;

    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_googleApiKey);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_appleApiKey);
    } else {
      throw UnsupportedError('Platform not supported by RevenueCat');
    }

    await Purchases.configure(configuration);
  }

  /// Fetch current customer info and check entitlement status.
  /// CustomerInfo is RevenueCat's source of truth for subscription state.
  static Future<bool> isPremium() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return _checkPremiumEntitlement(customerInfo);
    } catch (e) {
      // Always fail gracefully — assume free tier if we can't reach RC
      return false;
    }
  }

  /// Fetch available offerings from RevenueCat dashboard.
  /// Offerings let you A/B test pricing without app updates — a key RC concept.
  static Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      return null;
    }
  }

  /// Purchase a package from an offering.
  /// Returns updated CustomerInfo on success, null on cancellation.
  static Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      return customerInfo;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        // User cancelled — not an error, just return null
        return null;
      }
      rethrow;
    }
  }

  /// Restore purchases — REQUIRED by App Store / Play Store guidelines.
  /// DSEs frequently help developers implement this correctly.
  static Future<CustomerInfo> restorePurchases() async {
    return await Purchases.restorePurchases();
  }

  /// Listen to subscription status changes in real time.
  /// Useful for handling subscription renewals, expirations, etc.
  static void addCustomerInfoListener(
      void Function(CustomerInfo) onCustomerInfoUpdated,
      ) {
    Purchases.addCustomerInfoUpdateListener(onCustomerInfoUpdated);
  }

  static void removeCustomerInfoListener(
      void Function(CustomerInfo) onCustomerInfoUpdated,
      ) {
    Purchases.removeCustomerInfoUpdateListener(onCustomerInfoUpdated);
  }

  // Helper: check if premium entitlement is active
  static bool _checkPremiumEntitlement(CustomerInfo customerInfo) {
    return customerInfo.entitlements.active.containsKey(premiumEntitlement);
  }

  /// Get active subscription details for the management screen
  static Future<Map<String, dynamic>> getSubscriptionDetails() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.active[premiumEntitlement];

      if (entitlement == null) return {'isActive': false};

      return {
        'isActive': true,
        'productId': entitlement.productIdentifier,
        'expirationDate': entitlement.expirationDate,
        'willRenew': entitlement.willRenew,
        'store': entitlement.store.name,
        'periodType': entitlement.periodType.name,
      };
    } catch (e) {
      return {'isActive': false, 'error': e.toString()};
    }
  }
}