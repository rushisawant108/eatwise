import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../models/food_entry.dart';
import '../../providers/app_provider.dart';
import '../../services/ai_prediction_engine.dart';
import '../home/home_screen.dart';

class PostFeedbackScreen extends StatefulWidget {
  final FoodEntry entry;

  const PostFeedbackScreen({super.key, required this.entry});

  @override
  State<PostFeedbackScreen> createState() => _PostFeedbackScreenState();
}

class _PostFeedbackScreenState extends State<PostFeedbackScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> get _healthWarnings {
    final profile = context.read<AppProvider>().userProfile;
    final warnings = <String>[];

    if (widget.entry.isJunk) {
      if (widget.entry.sugar > 20) {
        warnings.add('🍬 High sugar content — avoid other sweet foods today');
      }
      if (widget.entry.fat > 20) {
        warnings.add('🧈 High fat content — watch fat intake for rest of the day');
      }

      if (profile != null) {
        if (profile.healthConditions.contains('Diabetes') && widget.entry.sugar > 15) {
          warnings.add('⚠️ Diabetes Alert: May increase blood sugar levels significantly');
        }
        if (profile.healthConditions.contains('High Cholesterol') && widget.entry.fat > 15) {
          warnings.add('⚠️ Cholesterol Alert: High fat risk for your condition');
        }
        if (profile.healthConditions.contains('PCOS')) {
          warnings.add('⚠️ PCOS: Processed food may cause hormonal imbalance');
        }
        if (profile.healthConditions.contains('Hypertension') && widget.entry.fat > 15) {
          warnings.add('⚠️ Hypertension: High sodium/fat may raise blood pressure');
        }
      }
    }

    return warnings;
  }

  List<String> get _damageControlTips {
    final tips = <String>[];
    if (widget.entry.isJunk) {
      tips.add(AppConstants.damageControlTips[0]);
      tips.add(AppConstants.damageControlTips[1]);
      tips.add(widget.entry.sugar > 20
          ? AppConstants.damageControlTips[2]
          : AppConstants.damageControlTips[4]);
    } else if (widget.entry.category == FoodCategory.moderate) {
      tips.add(AppConstants.damageControlTips[5]);
    }
    return tips;
  }

  Color get _categoryColor {
    if (widget.entry.isHealthy) return AppColors.success;
    if (widget.entry.isJunk) return AppColors.error;
    return AppColors.warning;
  }

  int get _pointsEarned {
    if (widget.entry.isHealthy) return 10;
    if (widget.entry.isJunk) return -5;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final color = _categoryColor;
    final pts = _pointsEarned;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────────────────────
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        ),
                        icon: const Icon(Icons.home_rounded),
                      ),
                      const Spacer(),
                      Text('Food Analysis', style: AppTextStyles.titleLarge),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Food Card ──────────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.restaurant_rounded, color: color, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(entry.name, style: AppTextStyles.headlineMedium),
                                  Text(
                                    AIPredictionEngine.getFoodJunkLabel(entry),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Points earned
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: pts > 0 ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                pts > 0 ? '+$pts pts' : '$pts pts',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: pts > 0 ? AppColors.success : AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Nutrient Grid
                        Row(
                          children: [
                            _nutrientTile('Calories', '${entry.calories}', 'kcal', AppColors.warning),
                            _nutrientTile('Fat', '${entry.fat.toStringAsFixed(1)}', 'g', AppColors.error),
                            _nutrientTile('Sugar', '${entry.sugar.toStringAsFixed(1)}', 'g', AppColors.secondary),
                            _nutrientTile('Protein', '${entry.protein.toStringAsFixed(1)}', 'g', AppColors.success),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Health Warnings ────────────────────────────────────────
                  if (_healthWarnings.isNotEmpty) ...[
                    Text('Health Warnings', style: AppTextStyles.headlineMedium),
                    const SizedBox(height: 10),
                    ..._healthWarnings.map(
                      (w) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error.withOpacity(0.2)),
                        ),
                        child: Text(w, style: AppTextStyles.bodyMedium.copyWith(height: 1.4)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Good feedback for healthy ──────────────────────────────
                  if (entry.isHealthy) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.success.withOpacity(0.12), AppColors.success.withOpacity(0.04)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.thumb_up_rounded, color: AppColors.success, size: 28),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Great choice! 🎉', style: AppTextStyles.titleLarge.copyWith(color: AppColors.success)),
                                const SizedBox(height: 4),
                                Text('You earned +10 reward points for eating healthy!',
                                    style: AppTextStyles.bodySmall.copyWith(height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Damage Control ────────────────────────────────────────
                  if (_damageControlTips.isNotEmpty) ...[
                    Text('💡 Damage Control Tips', style: AppTextStyles.headlineMedium),
                    const SizedBox(height: 10),
                    ..._damageControlTips.map(
                      (tip) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(tip,
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark, height: 1.4)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Done Button ───────────────────────────────────────────
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    ),
                    child: const Text('Back to Dashboard'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Log Another Food'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _nutrientTile(String label, String value, String unit, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.titleMedium.copyWith(color: color)),
            Text(unit, style: AppTextStyles.caption.copyWith(color: color)),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
