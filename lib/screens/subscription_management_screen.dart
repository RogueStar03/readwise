import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/subscription_cubit.dart';
import 'paywall_screen.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  State<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionCubit>().loadSubscriptionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Subscription',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          if (state is RestoreSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.isPremium
                      ? '✅ Premium restored successfully!'
                      : 'No active subscription found.',
                ),
                backgroundColor:
                state.isPremium ? Colors.green : Colors.orange,
              ),
            );
          } else if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final isPremium = state is SubscriptionLoaded && state.isPremium;
          final details =
          state is SubscriptionLoaded ? state.details : <String, dynamic>{};

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Status card
              _StatusCard(isPremium: isPremium, details: details),

              const SizedBox(height: 16),

              // What's included
              _SectionCard(
                title: isPremium ? 'Your Benefits' : 'Premium Benefits',
                children: [
                  _BenefitRow(
                    icon: Icons.all_inclusive,
                    title: 'Unlimited Articles',
                    subtitle: isPremium ? 'Active' : '3 free per day',
                    isActive: isPremium,
                  ),
                  _BenefitRow(
                    icon: Icons.science_outlined,
                    title: 'Science & Finance',
                    subtitle: isPremium ? 'Active' : 'Premium only',
                    isActive: isPremium,
                  ),
                  _BenefitRow(
                    icon: Icons.workspace_premium,
                    title: 'Exclusive Content',
                    subtitle: isPremium ? 'Active' : 'Premium only',
                    isActive: isPremium,
                  ),
                  _BenefitRow(
                    icon: Icons.block,
                    title: 'Ad-Free Experience',
                    subtitle: isPremium ? 'Active' : 'Premium only',
                    isActive: isPremium,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Subscription details (only for premium)
              if (isPremium && details.isNotEmpty) ...[
                _SectionCard(
                  title: 'Subscription Details',
                  children: [
                    if (details['productId'] != null)
                      _DetailRow(
                        label: 'Plan',
                        value: details['productId'].toString(),
                      ),
                    if (details['store'] != null)
                      _DetailRow(
                        label: 'Billed via',
                        value: details['store'].toString() == 'appStore'
                            ? 'App Store'
                            : 'Google Play',
                      ),
                    if (details['expirationDate'] != null)
                      _DetailRow(
                        label: 'Renews on',
                        value: _formatDate(details['expirationDate']),
                      ),
                    if (details['willRenew'] != null)
                      _DetailRow(
                        label: 'Auto-renew',
                        value: details['willRenew'] == true ? 'On' : 'Off',
                        valueColor: details['willRenew'] == true
                            ? Colors.green
                            : Colors.orange,
                      ),
                    if (details['periodType'] != null)
                      _DetailRow(
                        label: 'Period',
                        value: _formatPeriodType(details['periodType']),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Actions
              _SectionCard(
                title: 'Manage',
                children: [
                  if (!isPremium)
                    ListTile(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PaywallScreen()),
                      ),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4361EE).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.star,
                            color: Color(0xFF4361EE), size: 18),
                      ),
                      title: const Text('Upgrade to Premium',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Unlock all features'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ListTile(
                    onTap: () =>
                        context.read<SubscriptionCubit>().restorePurchases(),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.restore, size: 18),
                    ),
                    title: const Text('Restore Purchases',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Recover a previous subscription'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  if (isPremium)
                    ListTile(
                      onTap: () {
                        // In production: deep link to App Store / Play Store manage subscriptions
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Opens App Store or Play Store subscription settings'),
                          ),
                        );
                      },
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.cancel_outlined,
                            color: Colors.red, size: 18),
                      ),
                      title: const Text('Cancel Subscription',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w600)),
                      subtitle:
                      const Text('Managed through your app store'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // RevenueCat note (great talking point in interviews)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF4361EE).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF4361EE).withOpacity(0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline,
                        size: 16, color: Color(0xFF4361EE)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Subscription state is managed by RevenueCat. '
                            'Entitlements update in real-time across all your devices.',
                        style: TextStyle(
                          color: Color(0xFF4361EE),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return date.toString();
    }
  }

  String _formatPeriodType(dynamic type) {
    switch (type.toString()) {
      case 'normal':
        return 'Regular';
      case 'trial':
        return 'Free Trial';
      case 'intro':
        return 'Introductory';
      default:
        return type.toString();
    }
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final bool isPremium;
  final Map<String, dynamic> details;

  const _StatusCard({required this.isPremium, required this.details});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPremium
              ? [const Color(0xFF1A1A2E), const Color(0xFF4361EE)]
              : [const Color(0xFF6C757D), const Color(0xFF495057)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isPremium ? Icons.star : Icons.person_outline,
              color: isPremium ? const Color(0xFFFFD700) : Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPremium ? 'Premium Member' : 'Free Plan',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              Text(
                isPremium
                    ? 'Full access to all content'
                    : '3 free articles per day',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFF6C757D),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isActive;

  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.green.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? Colors.green : Colors.grey,
        ),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      trailing: Text(
        subtitle,
        style: TextStyle(
          color: isActive ? Colors.green : const Color(0xFF6C757D),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF6C757D), fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? const Color(0xFF1A1A2E),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}