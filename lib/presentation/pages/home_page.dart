import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/providers.dart';
import '../widgets/product_card.dart';
import '../widgets/banner_carousel.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _selectedBrand = "All";
  final List<String> _brands = [
    "All",
    "Mobile Legends",
    "Free Fire",
    "PUBG Mobile",
  ];

  @override
  Widget build(BuildContext context) {
    final productsAsyncValue = ref.watch(productListProvider);
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Top Up Games"),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton.icon(
              onPressed: () => context.go(isLoggedIn ? '/dashboard' : '/login'),
              icon: Icon(isLoggedIn ? Icons.person : Icons.login),
              label: Text(isLoggedIn ? 'Account' : 'Login'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: productsAsyncValue.when(
        data: (products) {
          // Filter products based on selection
          final filteredProducts = _selectedBrand == "All"
              ? products
              : products.where((p) => p.brand == _selectedBrand).toList();

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: BannerCarousel(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Popular Games",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _brands.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final brand = _brands[index];
                            final isSelected = brand == _selectedBrand;
                            return ChoiceChip(
                              label: Text(brand),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedBrand = brand;
                                  });
                                }
                              },
                              selectedColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              backgroundColor: Theme.of(
                                context,
                              ).cardTheme.color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              showCheckmark: false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.crossAxisExtent > 600
                        ? 4
                        : 2;
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = filteredProducts[index];
                        return ProductCard(
                              product: product,
                              onTap: () {
                                if (!isLoggedIn) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'You cannot continue transaction. Please login first from Home page.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                context.push('/payment', extra: product);
                              },
                            )
                            .animate()
                            .fade(duration: 400.ms)
                            .scale(delay: (50 * index).ms);
                      }, childCount: filteredProducts.length),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text("Error: $err"),
              TextButton(
                onPressed: () => ref.refresh(productListProvider),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home),
                  tooltip: 'Home',
                ),
                IconButton(
                  onPressed: () {
                    if (!isLoggedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'You cannot open transaction report as guest. Please login first from Home page.',
                          ),
                        ),
                      );
                      return;
                    }
                    context.go('/dashboard');
                  },
                  icon: const Icon(Icons.receipt_long),
                  tooltip: 'Transactions',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
