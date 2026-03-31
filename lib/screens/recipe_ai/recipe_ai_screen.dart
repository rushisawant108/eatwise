import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../providers/app_provider.dart';

class RecipeAIScreen extends StatefulWidget {
  const RecipeAIScreen({Key? key}) : super(key: key);

  @override
  State<RecipeAIScreen> createState() => _RecipeAIScreenState();
}

class _RecipeAIScreenState extends State<RecipeAIScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _ingredientController = TextEditingController();
  final List<String> _ingredients = [];
  bool _isGenerating = false;

  final List<Map<String, dynamic>> _quickRecipes = [
    {
      'name': 'Masala Oats',
      'time': '5 min',
      'calories': 220,
      'image': '🥣',
      'steps': [
        'Dry roast rolled oats for 2 minutes.',
        'Sauté onions, tomatoes, and peas with turmeric and chili powder.',
        'Add oats and water, cook until thick. Garnish with coriander.'
      ]
    },
    {
      'name': 'Paneer Bhurji',
      'time': '10 min',
      'calories': 320,
      'image': '🧀',
      'steps': [
        'Crumble fresh paneer in a bowl.',
        'Sauté finely chopped onions, tomatoes, green chilies, and ginger.',
        'Add paneer, turmeric, and garam masala. Cook for 2-3 minutes.'
      ]
    },
    {
      'name': 'Moong Dal Chilla',
      'time': '15 min',
      'calories': 180,
      'image': '🥞',
      'steps': [
        'Blend soaked moong dal with green chilies and ginger to a batter.',
        'Add salt and finely chopped coriander.',
        'Pour on a hot tawa, spread evenly like a dosa, and cook with minimal oil.'
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ingredientController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    if (_ingredientController.text.trim().isNotEmpty) {
      setState(() {
        _ingredients.add(_ingredientController.text.trim());
        _ingredientController.clear();
      });
    }
  }

  void _generateRecipe() async {
    if (_ingredients.isEmpty) return;
    
    final provider = context.read<AppProvider>();
    final biometrics = provider.userProfile?.toJson() ?? {};
    
    setState(() => _isGenerating = true);
    
    final recipe = await ApiService.generateRecipe(_ingredients, biometrics);
    
    if (!mounted) return;
    setState(() => _isGenerating = false);
    
    if (recipe != null) {
      _showGeneratedRecipe(recipe);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI is currently busy. Please try again!')),
      );
    }
  }

  void _showGeneratedRecipe(Map<String, dynamic> recipe) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Text(recipe['image'] ?? '🥗', style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text('AI Chef Suggestion', style: AppTextStyles.titleLarge),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(recipe['name'] ?? 'Custom Recipe', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
              const SizedBox(height: 8),
              Row(
                children: [
                   const Icon(Icons.timer_outlined, size: 14, color: AppColors.textMuted),
                   const SizedBox(width: 4),
                   Text(recipe['time'] ?? '15 min', style: AppTextStyles.bodySmall),
                   const SizedBox(width: 16),
                   const Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.secondary),
                   const SizedBox(width: 4),
                   Text('${recipe['calories'] ?? 300} kcal', style: AppTextStyles.bodySmall),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text('Instructions:', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              ...((recipe['steps'] as List<dynamic>?) ?? []).asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${e.key + 1}. ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      Expanded(child: Text(e.value.toString(), style: AppTextStyles.bodyMedium)),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _ingredients.clear();
              });
            },
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickRecipesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _quickRecipes.length,
      itemBuilder: (context, index) {
        final recipe = _quickRecipes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: AppColors.border.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4)),
            ],
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(
                  child: Text(recipe['image'], style: const TextStyle(fontSize: 48)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(recipe['name'], style: AppTextStyles.titleLarge),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 16, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(recipe['time'], style: AppTextStyles.labelMedium),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${recipe['calories']} kcal', style: AppTextStyles.labelMedium.copyWith(color: AppColors.secondary)),
                    ),
                    const SizedBox(height: 16),
                    Text('Instructions:', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 8),
                    ...(recipe['steps'] as List<String>).asMap().entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${e.key + 1}. ', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            Expanded(child: Text(e.value, style: AppTextStyles.bodyMedium)),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIngredientAITab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology_rounded, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Chef', style: AppTextStyles.titleLarge.copyWith(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Tell me what you have, and I will create a recipe for you.', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('Your Ingredients', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ingredientController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Chicken, Rice, Broccoli',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => _addIngredient(),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 56,
                height: 56,
                child: ElevatedButton(
                  onPressed: _addIngredient,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _ingredients.map((ing) {
              return Chip(
                label: Text(ing),
                deleteIconColor: AppColors.error,
                onDeleted: () {
                  setState(() {
                    _ingredients.remove(ing);
                  });
                },
                backgroundColor: AppColors.primaryLight,
              );
            }).toList(),
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_ingredients.isEmpty || _isGenerating) ? null : _generateRecipe,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isGenerating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Generate Recipe', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Recipe AI'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Quick Recipes', icon: Icon(Icons.fastfood_rounded)),
            Tab(text: 'Ingredient AI', icon: Icon(Icons.blender_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuickRecipesTab(),
          _buildIngredientAITab(),
        ],
      ),
    );
  }
}
