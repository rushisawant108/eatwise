import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/food_database.dart';
import '../../models/food_entry.dart';
import '../../providers/app_provider.dart';
import '../post_feedback/post_feedback_screen.dart';
import '../intervention/intervention_screen.dart';
import '../../services/ai_prediction_engine.dart';

class FoodInputScreen extends StatefulWidget {
  final int initialTab;
  const FoodInputScreen({super.key, this.initialTab = 0});

  @override
  State<FoodInputScreen> createState() => _FoodInputScreenState();
}

class _FoodInputScreenState extends State<FoodInputScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedFood;
  bool _isLogging = false;

  final List<Map<String, dynamic>> _mealItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _searchResults = FoodDatabase.allItems.take(12).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {
      _searchResults = query.isEmpty
          ? FoodDatabase.allItems.take(12).toList()
          : FoodDatabase.search(query);
    });
  }

  Future<void> _logFood(Map<String, dynamic> item) async {
    if (_isLogging) return;

    final provider = context.read<AppProvider>();
    final risk = provider.currentRisk;

    // Pre-order intervention check
    if (risk.level == RiskLevel.high ||
        (DateTime.now().hour >= 22 || DateTime.now().hour < 4)) {
      if (!mounted) return;
      final proceed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => InterventionScreen(
            foodName: item['name'],
            risk: risk,
          ),
        ),
      );
      if (proceed != true) return;
    }

    if (!mounted) return;
    setState(() => _isLogging = true);
    final entry = await provider.logFood(item);
    setState(() => _isLogging = false);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PostFeedbackScreen(entry: entry)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Log Food'),
        backgroundColor: AppColors.surface,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          labelStyle: AppTextStyles.labelLarge,
          tabs: const [
            Tab(text: 'Search'),
            Tab(text: 'Scan'),
            Tab(text: 'Meal Builder'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(),
          _buildScanTab(),
          _buildMealBuilderTab(),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: _search,
            decoration: InputDecoration(
              hintText: 'Search food (e.g. pizza, dal)',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _search('');
                      },
                    )
                  : null,
            ),
          ),
        ),
        Expanded(
          child: _searchResults.isEmpty
              ? Center(
                  child: Text('No food found', style: AppTextStyles.bodyMedium),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _foodListTile(_searchResults[i]),
                ),
        ),
      ],
    );
  }

  Widget _foodListTile(Map<String, dynamic> item) {
    final cat = item['category'] as String;
    final color = cat == 'junk'
        ? AppColors.error
        : cat == 'healthy'
            ? AppColors.success
            : AppColors.warning;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedFood = item;
        _showFoodDetail(item);
      }),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.restaurant_rounded, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'], style: AppTextStyles.titleMedium),
                  Text(
                    '${item['calories']} kcal • ₹${(item['cost'] as double).toStringAsFixed(0)}',
                    style: AppTextStyles.bodySmall,
                  ),
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
                cat[0].toUpperCase() + cat.substring(1),
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFoodDetail(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FoodDetailSheet(
        item: item,
        onLog: () {
          Navigator.pop(context);
          _logFood(item);
        },
      ),
    );
  }

  Widget _buildScanTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withOpacity(0.08),
                  AppColors.primary.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner_rounded, size: 64, color: AppColors.secondary),
                const SizedBox(height: 16),
                Text('Simulated Food Scanner', style: AppTextStyles.titleLarge),
                const SizedBox(height: 6),
                Text('Tap a food below to simulate scan', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Scan a Food Item (Demo)', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: FoodDatabase.allItems.take(8).map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => _showScanResult(item),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.camera_alt_outlined, color: AppColors.secondary),
                          const SizedBox(width: 12),
                          Text(item['name'], style: AppTextStyles.bodyLarge),
                          const Spacer(),
                          const Icon(Icons.chevron_right, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showScanResult(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 8),
            const Text('Scan Result'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['name'], style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text('${item['calories']} kcal detected', style: AppTextStyles.bodyMedium),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logFood(item);
            },
            child: const Text('Log This'),
          ),
        ],
      ),
    );
  }

  Widget _buildMealBuilderTab() {
    int totalCal = _mealItems.fold(0, (s, e) => s + (e['calories'] as int));
    double totalCost = _mealItems.fold(0.0, (s, e) => s + (e['cost'] as double));

    return Column(
      children: [
        if (_mealItems.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.restaurant_menu_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Meal Summary', style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
                      Text(
                        '${_mealItems.length} items • $totalCal kcal • ₹${totalCost.toStringAsFixed(0)}',
                        style: AppTextStyles.caption.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _logMeal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Log Meal'),
                ),
              ],
            ),
          ),
        ] else
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Add items to build a meal', style: AppTextStyles.bodyMedium),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: FoodDatabase.allItems.map((item) {
              final added = _mealItems.any((e) => e['name'] == item['name']);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: added ? AppColors.primaryLight : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: added ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name'], style: AppTextStyles.titleMedium),
                            Text('${item['calories']} kcal • ₹${(item['cost'] as double).toStringAsFixed(0)}',
                                style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (added) {
                              _mealItems.removeWhere((e) => e['name'] == item['name']);
                            } else {
                              _mealItems.add(item);
                            }
                          });
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: added ? AppColors.primary : AppColors.background,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: added ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: Icon(
                            added ? Icons.check : Icons.add,
                            color: added ? Colors.white : AppColors.textMuted,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _logMeal() async {
    if (_mealItems.isEmpty) return;
    for (final item in _mealItems) {
      await context.read<AppProvider>().logFood(item);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_mealItems.length} items logged successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() => _mealItems.clear());
    Navigator.of(context).pop();
  }
}

class _FoodDetailSheet extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onLog;

  const _FoodDetailSheet({required this.item, required this.onLog});

  @override
  Widget build(BuildContext context) {
    final cat = item['category'] as String;
    final color = cat == 'junk'
        ? AppColors.error
        : cat == 'healthy'
            ? AppColors.success
            : AppColors.warning;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.restaurant_rounded, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'], style: AppTextStyles.headlineMedium),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        cat[0].toUpperCase() + cat.substring(1),
                        style: AppTextStyles.caption.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _nutrientChip('Calories', '${item['calories']} kcal', AppColors.warning),
              const SizedBox(width: 10),
              _nutrientChip('Fat', '${item['fat']}g', AppColors.error),
              const SizedBox(width: 10),
              _nutrientChip('Sugar', '${item['sugar']}g', AppColors.secondary),
              const SizedBox(width: 10),
              _nutrientChip('Protein', '${item['protein']}g', AppColors.success),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onLog,
            child: const Text('Log This Food'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _nutrientChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.titleMedium.copyWith(color: color)),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
