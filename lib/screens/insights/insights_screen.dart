import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/app_provider.dart';
import '../../services/ai_prediction_engine.dart';
import '../../widgets/common/risk_badge.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        final weeklyStats = provider.weeklyStats;
        final todayStats = provider.todayStats;
        final rewardPoints = provider.rewardPoints;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Insights', style: AppTextStyles.headlineMedium),
            backgroundColor: AppColors.surface,
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRewardCard(rewardPoints),
                const SizedBox(height: 20),
                _buildTodaySummary(todayStats),
                const SizedBox(height: 24),
                _buildWeeklyChart(weeklyStats),
                const SizedBox(height: 24),
                _buildRiskTrend(weeklyStats),
                const SizedBox(height: 24),
                _buildWeeklyTable(weeklyStats),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRewardCard(int points) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reward Points', style: AppTextStyles.titleMedium.copyWith(color: Colors.white70)),
              Text(
                '$points pts',
                style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Healthy = +10', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
              Text('Junk = -5', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Summary", style: AppTextStyles.headlineMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            _summaryTile('Calories', '${stats['totalCalories']} kcal', Icons.local_fire_department_rounded, AppColors.warning),
            const SizedBox(width: 12),
            _summaryTile('Spent', '₹${(stats['totalCost'] as double).toStringAsFixed(0)}', Icons.account_balance_wallet_outlined, AppColors.secondary),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _summaryTile('Junk Items', '${stats['junkCount']}', Icons.fastfood_rounded, AppColors.error),
            const SizedBox(width: 12),
            _summaryTile('Entries', '${stats['entryCount']}', Icons.list_alt_rounded, AppColors.primary),
          ],
        ),
      ],
    );
  }

  Widget _summaryTile(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTextStyles.titleLarge.copyWith(color: color)),
                Text(label, style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(List<Map<String, dynamic>> weeklyStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Weekly Junk Food Trend', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 14),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 5,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.textPrimary,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final day = weeklyStats[groupIndex]['day'] as DateTime;
                    return BarTooltipItem(
                      '${DateFormat('EEE').format(day)}\n${rod.toY.toInt()} junk',
                      AppTextStyles.caption.copyWith(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, meta) {
                      final day = weeklyStats[val.toInt()]['day'] as DateTime;
                      return Text(
                        DateFormat('EEE').format(day),
                        style: AppTextStyles.caption,
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (val, meta) =>
                        Text(val.toInt().toString(), style: AppTextStyles.caption),
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.border,
                  strokeWidth: 1,
                ),
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(weeklyStats.length, (i) {
                final junk = (weeklyStats[i]['junkCount'] as int).toDouble();
                final color = junk >= 3
                    ? AppColors.error
                    : junk >= 2
                        ? AppColors.warning
                        : AppColors.success;

                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: junk == 0 ? 0.1 : junk,
                      color: color,
                      width: 28,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRiskTrend(List<Map<String, dynamic>> weeklyStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Risk Level Trend', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 12),
        Container(
          height: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(weeklyStats.length, (i) {
                    final risk = weeklyStats[i]['risk'] as RiskResult;
                    return FlSpot(i.toDouble(), risk.score.toDouble());
                  }),
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) {
                      final score = spot.y;
                      final color = score >= 60
                          ? AppColors.error
                          : score >= 30
                              ? AppColors.warning
                              : AppColors.success;
                      return FlDotCirclePainter(
                        radius: 5,
                        color: color,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withOpacity(0.08),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, meta) {
                      final day = weeklyStats[val.toInt()]['day'] as DateTime;
                      return Text(DateFormat('EEE').format(day), style: AppTextStyles.caption);
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: 25,
                    getTitlesWidget: (val, meta) =>
                        Text('${val.toInt()}%', style: AppTextStyles.caption),
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: AppColors.border, strokeWidth: 1),
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyTable(List<Map<String, dynamic>> weeklyStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Day-wise Breakdown', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: weeklyStats.asMap().entries.map((entry) {
              final i = entry.key;
              final stat = entry.value;
              final day = stat['day'] as DateTime;
              final risk = stat['risk'] as RiskResult;
              final isLast = i == weeklyStats.length - 1;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : const Border(bottom: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        DateFormat('EEE').format(day),
                        style: AppTextStyles.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${stat['junkCount']} junk',
                      style: AppTextStyles.bodySmall,
                    ),
                    const Spacer(),
                    Text(
                      '${stat['calories']} kcal',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(width: 12),
                    RiskBadge(level: risk.level, compact: true),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
