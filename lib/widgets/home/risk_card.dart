import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../services/ai_prediction_engine.dart';

class RiskCard extends StatelessWidget {
  final RiskResult risk;

  const RiskCard({super.key, required this.risk});

  Color get _color {
    switch (risk.level) {
      case RiskLevel.low:
        return AppColors.riskLow;
      case RiskLevel.medium:
        return AppColors.riskMedium;
      case RiskLevel.high:
        return AppColors.riskHigh;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: _color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Junk Food Risk', style: AppTextStyles.titleMedium),
              const Spacer(),
              _riskChip(),
            ],
          ),
          const SizedBox(height: 14),
          _buildProgressBar(),
          const SizedBox(height: 16),
          if (risk.reasons.isNotEmpty) ...[
            Text('Today\'s Factors', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            ...risk.reasons.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: _color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(r, style: AppTextStyles.bodySmall.copyWith(height: 1.4)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _riskChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${risk.score}%',
        style: AppTextStyles.titleMedium.copyWith(color: _color),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: risk.score / 100,
            backgroundColor: _color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation(_color),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('Low', style: AppTextStyles.caption),
            const Spacer(),
            Text('Medium', style: AppTextStyles.caption),
            const Spacer(),
            Text('High', style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }
}
