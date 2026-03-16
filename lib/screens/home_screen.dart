import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/subscription_cubit.dart';
import '../models/article.dart';
import '../widgets/article_card.dart';
import '../widgets/premium_banner.dart';
import 'article_detail_screen.dart';
import 'paywall_screen.dart';
import 'subscription_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _articlesReadToday = 0;
  final int _freeLimit = ArticleService.freeDailyLimit;

  @override
  void initState() {
    super.initState();
    context.read<SubscriptionCubit>().loadSubscriptionStatus();
  }

  void _onArticleTap(Article article, bool isPremium) {
    // Premium article → gate it
    if (article.isPremium && !isPremium) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
      return;
    }

    // Free article → check daily read limit
    if (!article.isPremium && !isPremium && _articlesReadToday >= _freeLimit) {
      _showReadLimitDialog();
      return;
    }

    // Allow access
    if (!article.isPremium) {
      setState(() => _articlesReadToday++);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(article: article),
      ),
    );
  }

  void _showReadLimitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Daily Limit Reached'),
        content: Text(
          'You\'ve read $_freeLimit free articles today. '
              'Upgrade to ReadWise Premium for unlimited access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Maybe Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaywallScreen()),
              );
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        final isPremium = state is SubscriptionLoaded && state.isPremium;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_stories,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'ReadWise',
                  style: TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            actions: [
              if (isPremium)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.star, color: Color(0xFFFFD700), size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Premium',
                        style: TextStyle(
                          color: Color(0xFFB8860B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.manage_accounts_outlined,
                    color: Color(0xFF1A1A2E)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SubscriptionManagementScreen(),
                  ),
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () =>
                context.read<SubscriptionCubit>().loadSubscriptionStatus(),
            child: CustomScrollView(
              slivers: [
                // Free read counter (only for non-premium)
                if (!isPremium)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE9ECEF)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.article_outlined,
                              size: 18, color: Color(0xFF6C757D)),
                          const SizedBox(width: 8),
                          Text(
                            'Free articles today: $_articlesReadToday / $_freeLimit',
                            style: const TextStyle(
                              color: Color(0xFF6C757D),
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const PaywallScreen()),
                            ),
                            child: const Text(
                              'Go Premium →',
                              style: TextStyle(
                                color: Color(0xFF4361EE),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Premium upgrade banner
                if (!isPremium)
                  SliverToBoxAdapter(
                    child: PremiumBanner(
                      onUpgradeTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PaywallScreen()),
                      ),
                    ),
                  ),

                // Section: Today's Top Stories
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                    child: Text(
                      'Today\'s Top Stories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                ),

                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final articles = ArticleService.getAllArticles();
                      final article = articles[index];
                      return ArticleCard(
                        article: article,
                        isPremiumUser: isPremium,
                        onTap: () => _onArticleTap(article, isPremium),
                      );
                    },
                    childCount: ArticleService.getAllArticles().length,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        );
      },
    );
  }
}