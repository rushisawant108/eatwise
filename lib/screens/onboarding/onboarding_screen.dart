import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_profile.dart';
import '../../providers/app_provider.dart';
import '../home/home_screen.dart';
import '../../widgets/common/ew_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  // Form fields
  final _nameController = TextEditingController();
  int _age = 25;
  double _weight = 65;
  final List<String> _selectedConditions = ['None'];
  String _selectedFoodPref = 'Vegetarian';
  String _selectedRegion = 'North Indian';
  String _selectedBudget = 'Moderate (₹100–₹300)';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _fadeController.reset();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      _fadeController.forward();
    } else {
      _submitOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitOnboarding() async {
    final profile = UserProfile(
      id: const Uuid().v4(),
      name: _nameController.text.trim().isEmpty
          ? 'User'
          : _nameController.text.trim(),
      age: _age,
      weight: _weight,
      healthConditions: _selectedConditions,
      foodPreference: _selectedFoodPref,
      region: _selectedRegion,
      budgetPreference: _selectedBudget,
      createdAt: DateTime.now(),
    );

    if (!mounted) return;
    await context.read<AppProvider>().saveUserProfile(profile);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _buildWelcomePage(),
                    _buildPersonalInfoPage(),
                    _buildHealthPage(),
                    _buildFoodPrefPage(),
                    _buildBudgetPage(),
                  ],
                ),
              ),
            ),
            _buildNavButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
            child: Text('EATWISE', style: AppTextStyles.headlineLarge.copyWith(color: Colors.white)),
          ),
          const Spacer(),
          Text(
            '${_currentPage + 1} of $_totalPages',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: (_currentPage + 1) / _totalPages,
          backgroundColor: AppColors.border,
          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          minHeight: 4,
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 24),
          Text('Welcome to\nEATWISE 👋', style: AppTextStyles.displayLarge),
          const SizedBox(height: 12),
          Text(
            'Your AI-powered food intelligence assistant. Let\'s set up your profile to give you personalized insights.',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 32),
          _featureItem(Icons.shield_outlined, 'Junk food risk prediction'),
          _featureItem(Icons.notifications_outlined, 'Smart pre-order alerts'),
          _featureItem(Icons.bar_chart_rounded, 'Weekly behavior insights'),
          _featureItem(Icons.emoji_events_outlined, 'Reward points system'),
        ],
      ),
    );
  }

  Widget _featureItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Text(label, style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us about yourself', style: AppTextStyles.displayMedium),
          const SizedBox(height: 8),
          Text('This helps us personalize your risk assessment', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 24),
          Text('Age: $_age years', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Slider(
            value: _age.toDouble(),
            min: 10,
            max: 80,
            divisions: 70,
            activeColor: AppColors.primary,
            label: '$_age',
            onChanged: (v) => setState(() => _age = v.round()),
          ),
          const SizedBox(height: 24),
          Text('Weight: ${_weight.toStringAsFixed(1)} kg', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Slider(
            value: _weight,
            min: 30,
            max: 150,
            divisions: 120,
            activeColor: AppColors.primary,
            label: '${_weight.round()} kg',
            onChanged: (v) => setState(() => _weight = v),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Health Conditions', style: AppTextStyles.displayMedium),
          const SizedBox(height: 8),
          Text('Select all that apply', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 28),
          ...AppConstants.healthConditions.map(
            (cond) => _checkboxItem(
              cond,
              _selectedConditions.contains(cond),
              (val) {
                setState(() {
                  if (cond == 'None') {
                    _selectedConditions
                      ..clear()
                      ..add('None');
                  } else {
                    _selectedConditions.remove('None');
                    if (val == true) {
                      _selectedConditions.add(cond);
                    } else {
                      _selectedConditions.remove(cond);
                    }
                    if (_selectedConditions.isEmpty) _selectedConditions.add('None');
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkboxItem(String label, bool selected, ValueChanged<bool?> onChanged) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryLight : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: CheckboxListTile(
        value: selected,
        onChanged: onChanged,
        title: Text(label, style: AppTextStyles.bodyLarge),
        activeColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
    );
  }

  Widget _buildFoodPrefPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Food Preferences', style: AppTextStyles.displayMedium),
          const SizedBox(height: 8),
          Text('Helps us suggest the right alternatives', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 28),
          Text('Food Type', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppConstants.foodPreferences.map((pref) {
              final selected = _selectedFoodPref == pref;
              return GestureDetector(
                onTap: () => setState(() => _selectedFoodPref = pref),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    pref,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: selected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          Text('Regional Cuisine', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppConstants.regions.map((region) {
              final selected = _selectedRegion == region;
              return GestureDetector(
                onTap: () => setState(() => _selectedRegion = region),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.secondary : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.secondary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    region,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: selected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Budget Preference', style: AppTextStyles.displayMedium),
          const SizedBox(height: 8),
          Text('We track spending to show cost impact', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 28),
          ...AppConstants.budgetOptions.map((opt) {
            final selected = _selectedBudget == opt;
            return GestureDetector(
              onTap: () => setState(() => _selectedBudget = opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryLight : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: selected ? AppColors.primary : AppColors.textMuted,
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Text(opt, style: AppTextStyles.bodyLarge)),
                    if (selected)
                      const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You\'re all set! Tap "Get Started" to begin your healthier journey.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: OutlinedButton(
                  onPressed: _prevPage,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                  ),
                  child: const Text('Back'),
                ),
              ),
            ),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _nextPage,
              child: Text(
                _currentPage == _totalPages - 1 ? 'Get Started 🚀' : 'Continue',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
