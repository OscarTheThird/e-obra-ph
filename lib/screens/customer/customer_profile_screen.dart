// screens/customer/customer_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../widgets/bottom_nav_bar.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUserModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepPurple,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (user.location != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Text(user.location!),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.favorite),
                      title: const Text('Favorite Artists'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to favorites
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('Purchase History'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to purchase history
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Settings'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to settings
                      },
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const CustomerBottomNavBar(currentIndex: 2),
    );
  }
}
