# ReadWise — RevenueCat Flutter Integration

A quick practice project I built to learn in-app subscription and payment handling in Flutter using [RevenueCat](https://www.revenuecat.com/).

I hadn't worked with payments in mobile apps before, so I built a simple news reader with a free/premium tier to get hands-on with the RevenueCat SDK — entitlements, offerings, paywalls, restore purchases, and real-time subscription state.

## What's in the app

A content/news reader with two tiers:

- **Free** — 3 articles per day, general & tech categories
- **Premium** — unlimited articles, Science, Finance & Exclusive categories

## Features

- **Free vs Premium feature gating** — 3 free articles/day + locked premium categories
- **Subscription status & management** — real-time entitlement checks, renewal info
- **Paywall screen** — dynamically loads offerings from RevenueCat dashboard
- **Restore purchases** — required by App Store & Play Store guidelines
- **Real-time listener** — subscription state updates across the app instantly

---

## Setup

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Configure RevenueCat

1. Create a free account at [app.revenuecat.com](https://app.revenuecat.com)
2. Create a new project → add iOS and/or Android app
3. Copy your API keys into `lib/services/revenue_cat_service.dart`:
   ```dart
   static const String _appleApiKey = 'appl_YOUR_KEY_HERE';
   static const String _googleApiKey = 'goog_YOUR_KEY_HERE';
   ```

### 3. Configure products in RevenueCat dashboard

1. Go to **Products** → add your App Store / Play Store product IDs
2. Go to **Entitlements** → create one called `premium`
3. Attach your products to the `premium` entitlement
4. Go to **Offerings** → create a `default` offering with monthly + annual packages

### 4. Add native platform setup

**Android** (`android/app/src/main/AndroidManifest.xml`):

```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

**iOS** — No extra config needed. Make sure StoreKit is linked (it is by default).

### 5. Run the app

```bash
flutter run
```

> **Testing tip:** Use RevenueCat's sandbox environment. On Android use a test account in Google Play Console. On iOS use a Sandbox Apple ID.

---

## Project Structure

```
lib/
├── main.dart                          # RC initialization + app entry
├── services/
│   └── revenue_cat_service.dart       # All RevenueCat SDK calls
├── cubit/
│   └── subscription_cubit.dart        # Subscription state management
├── models/
│   └── article.dart                   # Article model + mock data
├── screens/
│   ├── home_screen.dart               # Feed with gating logic
│   ├── paywall_screen.dart            # Dynamic offerings paywall
│   ├── subscription_management_screen.dart
│   └── article_detail_screen.dart
└── widgets/
    ├── article_card.dart              # Card with lock overlay
    └── premium_banner.dart            # Inline upgrade prompt
```

---

## Key RevenueCat Concepts Demonstrated

### Entitlements

The app uses a single `premium` entitlement. Rather than checking product IDs directly,
entitlements abstract the subscription logic — so adding a new product tier never
requires an app update.

```dart
customerInfo.entitlements.active.containsKey('premium')
```

### Offerings

Prices and packages are fetched from the RevenueCat dashboard at runtime.
This means you can run A/B tests on pricing without releasing a new app version.

```dart
final offerings = await Purchases.getOfferings();
final packages = offerings.current!.availablePackages;
```

### CustomerInfo listener

The app registers a real-time listener so subscription state (e.g., a renewal or
cancellation) is reflected across all screens immediately — no polling required.

```dart
Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
```

### Restore purchases

Required by both App Store and Google Play guidelines. Allows users who reinstall
the app, switch devices, or reinstall to recover their subscription.

```dart
await Purchases.restorePurchases();
```

---

## Things I learned

- **Entitlements over product IDs** — checking `entitlements.active` instead of hardcoded product strings means you can add new plans without touching app code
- **Offerings are dashboard-driven** — prices and packages load from RevenueCat at runtime, so you can adjust or A/B test pricing without a release
- **CustomerInfo listener** — subscribing to real-time updates means the UI reacts immediately to renewals or cancellations, no polling needed
- **Restore purchases** — this is required by both App Store and Play Store, easy to miss when you're first starting out
