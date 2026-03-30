import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/app_provider.dart';
import '../onboarding/onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        final profile = provider.userProfile;
        final pts = provider.rewardPoints;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Profile', style: AppTextStyles.headlineMedium),
            backgroundColor: AppColors.surface,
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar + Name
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white.withOpacity(0.25),
                        child: Text(
                          profile?.name.isNotEmpty == true
                              ? profile!.name[0].toUpperCase()
                              : 'U',
                          style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile?.name ?? 'User',
                        style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile != null ? '${profile.age} yrs • ${profile.weight.toStringAsFixed(0)} kg' : '—',
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text('$pts Reward Points', style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                if (profile != null) ...[
                  _sectionCard('Personal Info', [
                    _infoRow(Icons.cake_outlined, 'Age', '${profile.age} years'),
                    _infoRow(Icons.monitor_weight_outlined, 'Weight', '${profile.weight.toStringAsFixed(1)} kg'),
                    _infoRow(Icons.restaurant_outlined, 'Diet', profile.foodPreference),
                    _infoRow(Icons.location_on_outlined, 'Region', profile.region),
                    _infoRow(Icons.account_balance_wallet_outlined, 'Budget', profile.budgetPreference),
                  ]),

                  const SizedBox(height: 16),

                  _sectionCard('Health Conditions', [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.healthConditions.map((c) {
                        final isNone = c == 'None';
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isNone ? AppColors.primaryLight : AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isNone ? AppColors.primary : AppColors.error.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            c,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isNone ? AppColors.primary : AppColors.error,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ]),

                  const SizedBox(height: 16),
                ],

                _sectionCard('Reward System', [
                  _rewardRow('Healthy food logged', '+10 pts', AppColors.success),
                  _rewardRow('Moderate food logged', '+3 pts', AppColors.warning),
                  _rewardRow('Junk food logged', '-5 pts', AppColors.error),
                ]),

                const SizedBox(height: 24),

                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile / Re-onboard'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.bodyMedium),
          const Spacer(),
          Text(value, style: AppTextStyles.titleMedium),
        ],
      ),
    );
  }

  Widget _rewardRow(String label, String pts, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          Text(pts, style: AppTextStyles.titleMedium.copyWith(color: color)),
        ],
      ),
    );
  }
}
