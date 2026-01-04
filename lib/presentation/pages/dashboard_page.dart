import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      // Basic protection, though Router redirect is better
      return const Scaffold(body: Center(child: Text("Unauthorized")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      
                      if (isMobile) {
                        // Mobile Layout (Vertical)
                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text(
                                user.name[0],
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              user.email,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                            const Divider(height: 32, color: Colors.white10),
                            Text(
                              "Balance",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                            Text(
                              "Rp ${user.balance.toStringAsFixed(0)}",
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                            ),
                          ],
                        );
                      } else {
                        // Desktop Layout (Horizontal)
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text(
                                user.name[0],
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    user.email,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Colors.grey,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Balance",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey,
                                      ),
                                ),
                                Text(
                                  "Rp ${user.balance.toStringAsFixed(0)}",
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 32),
                
                // Transaction History Title
                 Text(
                   "Recent Transactions",
                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
                     fontWeight: FontWeight.bold,
                   ),
                 ),
                 const SizedBox(height: 16),

                 // Transaction List (Mock)
                 ListView.separated(
                   shrinkWrap: true,
                   physics: const NeverScrollableScrollPhysics(),
                   itemCount: 5,
                   separatorBuilder: (context, index) => const SizedBox(height: 12),
                   itemBuilder: (context, index) {
                     return ListTile(
                       contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                       tileColor: Theme.of(context).cardTheme.color,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(12),
                         side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                       ),
                       leading: Container(
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(
                           color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: Icon(
                           Icons.videogame_asset,
                           color: Theme.of(context).colorScheme.primary,
                         ),
                       ),
                       title: const Text("Mobile Legends 100 Diamonds"),
                       subtitle: Text("Jan ${10 - index}, 2026"),
                       trailing: Text(
                         "- Rp 30,000",
                         style: Theme.of(context).textTheme.titleMedium?.copyWith(
                           color: Theme.of(context).colorScheme.error,
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                     );
                   },
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
