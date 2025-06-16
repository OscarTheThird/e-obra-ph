// screens/customer/customer_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../widgets/bottom_nav_bar.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> with TickerProviderStateMixin {
  late AnimationController _profileAnimationController;
  late AnimationController _menuAnimationController;
  late Animation<double> _profileFadeAnimation;
  late Animation<Offset> _profileSlideAnimation;
  late Animation<double> _menuFadeAnimation;
  late Animation<Offset> _menuSlideAnimation;

  // Color palette
  static const Color primaryOrange = Color(0xFFE8541D);
  static const Color primaryGreen = Color(0xFF00BF63);
  static const Color primaryPurple = Color(0xFF5E17EB);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color darkGray = Color(0xFF6C757D);

  final List<ProfileMenuItem> _menuItems = [
    ProfileMenuItem(
      icon: Icons.favorite_rounded,
      title: 'Favorite Artists',
      subtitle: 'Discover your saved artists',
      color: const Color(0xFFE8541D),
      route: '/customer/favorites',
    ),
    ProfileMenuItem(
      icon: Icons.shopping_bag_rounded,
      title: 'Purchase History',
      subtitle: 'View your art collection',
      color: const Color(0xFF00BF63),
      route: '/customer/purchases',
    ),
    ProfileMenuItem(
      icon: Icons.bookmark_rounded,
      title: 'Saved Artworks',
      subtitle: 'Your wishlist items',
      color: const Color(0xFF5E17EB),
      route: '/customer/saved',
    ),
    ProfileMenuItem(
      icon: Icons.notifications_rounded,
      title: 'Notifications',
      subtitle: 'Manage your alerts',
      color: const Color(0xFFE8541D),
      route: '/customer/notifications',
    ),
    ProfileMenuItem(
      icon: Icons.help_rounded,
      title: 'Help & Support',
      subtitle: 'Get assistance',
      color: const Color(0xFF00BF63),
      route: '/customer/help',
    ),
    ProfileMenuItem(
      icon: Icons.settings_rounded,
      title: 'Settings',
      subtitle: 'Account preferences',
      color: const Color(0xFF5E17EB),
      route: '/customer/settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _profileAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _menuAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _profileFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _profileAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _profileSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _profileAnimationController,
      curve: Curves.easeOutBack,
    ));
    
    _menuFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _menuAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _menuSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _menuAnimationController,
      curve: Curves.easeOutBack,
    ));
    
    // Start animations
    _profileAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _menuAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _profileAnimationController.dispose();
    _menuAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUserModel;

    return Scaffold(
      backgroundColor: lightGray,
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildModernAppBar(authService, user),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildProfileSection(user),
                      _buildMenuSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const CustomerBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildModernAppBar(AuthService authService, dynamic user) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryPurple,
              primaryPurple.withOpacity(0.8),
              primaryOrange.withOpacity(0.6),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          centerTitle: false,
          titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
          title: AnimatedBuilder(
            animation: _profileAnimationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _profileFadeAnimation,
                child: SlideTransition(
                  position: _profileSlideAnimation,
                  child: Text(
                    'My Profile',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
          background: AnimatedBuilder(
            animation: _profileAnimationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _profileFadeAnimation,
                child: SlideTransition(
                  position: _profileSlideAnimation,
                  child: Container(
                    padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryGreen, primaryGreen.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        if (user.location != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                user.location!,
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: () async {
              await authService.signOut();
              context.go('/login');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection(dynamic user) {
    return AnimatedBuilder(
      animation: _profileAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _profileFadeAnimation,
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (user.bio != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: backgroundWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.info_outline,
                                color: primaryPurple,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'About Me',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryPurple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.bio!,
                          style: TextStyle(
                            fontSize: 14,
                            color: darkGray,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                _buildStatsCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.favorite,
              title: 'Favorites',
              value: '12',
              color: primaryOrange,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: lightGray,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.shopping_bag,
              title: 'Purchases',
              value: '5',
              color: primaryGreen,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: lightGray,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.bookmark,
              title: 'Saved',
              value: '24',
              color: primaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: darkGray,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return AnimatedBuilder(
      animation: _menuAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _menuFadeAnimation,
          child: SlideTransition(
            position: _menuSlideAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Access',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _menuItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      return _buildMenuItem(item, index);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(ProfileMenuItem item, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    // Handle navigation based on item.route
                    print('Navigate to: ${item.route}');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            item.icon,
                            color: item.color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: primaryPurple,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.subtitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: darkGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.chevron_right,
                            color: item.color,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProfileMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String route;

  ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
  });
}