import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/app_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final foodLog = provider.foodLog;

    // Group food logs by day
    final Map<String, List<dynamic>> groupedLogs = {};
    for (var entry in foodLog) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.timestamp);
      if (!groupedLogs.containsKey(dateKey)) {
        groupedLogs[dateKey] = [];
      }
      groupedLogs[dateKey]!.add(entry);
    }

    // Sort days descending
    final sortedDays = groupedLogs.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: sortedDays.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_rounded, size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('No history yet', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 8),
                  Text('Start logging your meals to see them here.', style: AppTextStyles.bodyMedium),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedDays.length,
              itemBuilder: (context, index) {
                final dateStr = sortedDays[index];
                final dateList = dateStr.split('-');
                final dateObj = DateTime(
                  int.parse(dateList[0]),
                  int.parse(dateList[1]),
                  int.parse(dateList[2]),
                );
                
                final dayLogs = groupedLogs[dateStr]!;
                
                // Calculate day totals
                int dailyCals = dayLogs.fold(0, (s, e) => s + (e.calories as int));
                int dailyJunk = dayLogs.where((e) => e.isJunk).length;
                
                String displayDate;
                final now = DateTime.now();
                if (dateObj.year == now.year && dateObj.month == now.month && dateObj.day == now.day) {
                  displayDate = 'Today';
                } else if (dateObj.year == now.year && dateObj.month == now.month && dateObj.day == now.day - 1) {
                  displayDate = 'Yesterday';
                } else {
                  displayDate = DateFormat('MMM d, yyyy').format(dateObj);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(displayDate, style: AppTextStyles.titleMedium),
                            Row(
                              children: [
                                Text('$dailyCals kcal', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryDark)),
                                if (dailyJunk > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text('$dailyJunk Junk', style: AppTextStyles.caption.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ...dayLogs.map((entry) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: entry.isJunk ? AppColors.error.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  entry.isJunk ? Icons.fastfood_rounded : Icons.restaurant_rounded,
                                  color: entry.isJunk ? AppColors.error : AppColors.success,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(entry.name, style: AppTextStyles.bodyLarge),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('h:mm a').format(entry.timestamp),
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${entry.calories} kcal', style: AppTextStyles.titleMedium),
                                  Text('₹${entry.cost.toStringAsFixed(0)}', style: AppTextStyles.bodySmall),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
