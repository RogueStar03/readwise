import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/subscription_cubit.dart';
import 'screens/home_screen.dart';
import 'services/revenue_cat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize RevenueCat before the app starts.
  // This is the #1 integration step DSEs help developers get right.
  await RevenueCatService.initialize();

  runApp(const ReadWiseApp());
}

class ReadWiseApp extends StatelessWidget {
  const ReadWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // SubscriptionCubit is provided at the root so any screen
      // can access subscription state without re-fetching.
      create: (_) => SubscriptionCubit(),
      child: MaterialApp(
        title: 'ReadWise',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4361EE),
            brightness: Brightness.light,
          ),
          fontFamily: 'SF Pro Display', // Falls back to system font
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}