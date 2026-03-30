import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../services/ai_prediction_engine.dart';

class InterventionScreen extends StatefulWidget {
  final String foodName;
  final RiskResult risk;

  const InterventionScreen({
    super.key,
    required this.foodName,
    required this.risk,
  });

  @override
  State<InterventionScreen> createState() => _InterventionScreenState();
}

class _InterventionScreenState extends State<InterventionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> get _healthAlerts {
    final alerts = <String>[];
    for (final w in widget.risk.healthWarnings) {
      alerts.add(w);
    }
    if (alerts.isEmpty) {
      final name = widget.foodName.toLowerCase();
      if (name.contains('pizza') || name.contains('burger')) {
        alerts.add('High calorie density may contribute to weight gain');
      } else if (name.contains('drink') || name.contains('cola')) {
        alerts.add('High sugar content may spike blood glucose');
      } else {
        alerts.add('This meal is high in calories and fat');
      }
    }
    return alerts;
  }

  List<String> get _alternatives {
    final name = widget.foodName.toLowerCase();
    for (final key in AppConstants.healthyAlternatives.keys) {
      if (name.contains(key)) {
        return AppConstants.healthyAlternatives[key]!;
      }
    }
    return AppConstants.healthyAlternatives['default']!;
  }

  @override
  Widget build(BuildContext context) {
    final isHighRisk = widget.risk.level == RiskLevel.high;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.6),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: isHighRisk
                          ? AppColors.dangerGradient
                          : const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFFB923C)],
                            ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.white, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          isHighRisk
                              ? '⚠️ High Risk Alert'
                              : '⚡ Heads Up!',
                          style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'You are likely to choose unhealthy food right now',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Food selected
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.fastfood_rounded, color: AppColors.error),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(widget.foodName, style: AppTextStyles.titleMedium),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Risk: ${widget.risk.score}%',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        Text('Health Impact', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 8),
                        ..._healthAlerts.map(
                          (alert) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(alert, style: AppTextStyles.bodySmall.copyWith(height: 1.4)),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Text('Healthier Alternatives', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 8),
                        ..._alternatives.map(
                          (alt) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.eco_rounded, color: AppColors.primary, size: 16),
                                const SizedBox(width: 8),
                                Text(alt, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context, false),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 48),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  minimumSize: const Size(0, 48),
                                ),
                                child: const Text('Log Anyway'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
