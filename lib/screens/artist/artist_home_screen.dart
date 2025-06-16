// screens/artist/artist_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../widgets/bottom_nav_bar.dart';

class ArtistHomeScreen extends StatelessWidget {
  const ArtistHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUserModel;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user?.name ?? 'Artist'}'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            child: SizedBox(
              width: double.infinity,
              height: 120,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/artist/create');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'Create New Post',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.message, color: Colors.white),
                    ),
                    title: const Text('New Message'),
                    subtitle: const Text('You have 3 new messages'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to messages
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.shopping_cart, color: Colors.white),
                    ),
                    title: const Text('Order Inquiry'),
                    subtitle: const Text('Someone is interested in your painting'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to order details
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.event, color: Colors.white),
                    ),
                    title: const Text('Upcoming Event'),
                    subtitle: const Text('Art Exhibition - Tomorrow 2PM'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to event details
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ArtistBottomNavBar(currentIndex: 0),
    );
  }
}
