import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/app_provider.dart';
import '../../services/ai_prediction_engine.dart';
import '../../widgets/common/risk_badge.dart';
import '../../widgets/home/stat_card.dart';
import '../../widgets/home/quick_action_card.dart';
import '../../widgets/home/risk_card.dart';
import '../food_input/food_input_screen.dart';
import '../insights/insights_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  final List<Widget> _tabs = const [
    _HomeTab(),
    InsightsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _selectedTab, children: _tabs),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
              _navItem(1, Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Insights'),
              _navItem(2, Icons.person_rounded, Icons.person_outlined, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData activeIcon, IconData icon, String label) {
    final selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? activeIcon : icon,
              color: selected ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: selected ? AppColors.primary : AppColors.textMuted,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        final profile = provider.userProfile;
        final risk = provider.currentRisk;
        final stats = provider.todayStats;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, profile?.name ?? 'User', risk),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    RiskCard(risk: risk),
                    const SizedBox(height: 20),
                    _buildStatsRow(stats),
                    const SizedBox(height: 24),
                    Text('Quick Actions', style: AppTextStyles.headlineMedium),
                    const SizedBox(height: 14),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    _buildTodayLog(provider),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, String name, RiskResult risk) {
    return SliverAppBar(
      expandedHeight: 130,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.textPrimary, const Color(0xFF1E3A5F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Good ${_getGreeting()}, 👋',
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                    ),
                    Text(
                      name,
                      style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              RiskBadge(level: risk.level, compact: true),
            ],
          ),
        ),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildStatsRow(Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Calories',
            value: '${stats['totalCalories']}',
            unit: 'kcal',
            icon: Icons.local_fire_department_rounded,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            label: 'Spent',
            value: '₹${(stats['totalCost'] as double).toStringAsFixed(0)}',
            unit: 'today',
            icon: Icons.account_balance_wallet_outlined,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            label: 'Junk',
            value: '${stats['junkCount']}',
            unit: 'items',
            icon: Icons.fastfood_rounded,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: QuickActionCard(
            icon: Icons.add_circle_outline_rounded,
            label: 'Log Food',
            color: AppColors.primary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FoodInputScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: QuickActionCard(
            icon: Icons.camera_alt_outlined,
            label: 'Scan Food',
            color: AppColors.secondary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const FoodInputScreen(initialTab: 1),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: QuickActionCard(
            icon: Icons.restaurant_menu_rounded,
            label: 'Meal Builder',
            color: AppColors.warning,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const FoodInputScreen(initialTab: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayLog(AppProvider provider) {
    final entries = provider.todayEntries;
    if (entries.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Log", style: AppTextStyles.headlineMedium),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(Icons.restaurant_outlined, size: 48, color: AppColors.textMuted),
                const SizedBox(height: 12),
                Text('No meals logged yet', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 4),
                Text('Tap "Log Food" to get started', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Today's Log", style: AppTextStyles.headlineMedium),
            const Spacer(),
            Text('${entries.length} items', style: AppTextStyles.bodySmall),
          ],
        ),
        const SizedBox(height: 12),
        ...entries.reversed.take(5).map((entry) => _logItem(entry)),
      ],
    );
  }

  Widget _logItem(entry) {
    final color = entry.isJunk
        ? AppColors.error
        : entry.isHealthy
            ? AppColors.success
            : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.restaurant_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: AppTextStyles.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${entry.calories} kcal • ₹${entry.cost.toStringAsFixed(0)}',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              entry.isJunk ? 'Junk' : entry.isHealthy ? 'Healthy' : 'Moderate',
              style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
