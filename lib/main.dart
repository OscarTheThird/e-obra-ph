import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart'; // Import the Firebase options
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/customer_home_screen.dart';
import 'screens/customer/search_screen.dart';
import 'screens/customer/customer_profile_screen.dart';
import 'screens/customer/artist_profile_screen.dart'; // This should contain ArtistProfileViewScreen
import 'screens/artist/artist_home_screen.dart';
import 'screens/artist/create_post_screen.dart';
import 'screens/artist/artist_profile_screen.dart';
import 'screens/messaging/chat_screen.dart';

void main() async {
  print("🚀 Starting ArtMatch App...");
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print("🔥 Initializing Firebase with options...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Use the Firebase options
    );
    print("✅ Firebase initialized successfully");
    print("📊 Project: ${DefaultFirebaseOptions.currentPlatform.projectId}");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
    // Show error dialog in debug mode
    runApp(MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Firebase Error'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Firebase Initialization Failed'),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Restart the app
                  main();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    ));
    return;
  }
  
  print("📱 Starting Flutter app...");
  runApp(const ArtMatchApp());
}

class ArtMatchApp extends StatelessWidget {
  const ArtMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => FirestoreService()),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          return MaterialApp.router(
            title: 'E-Obra.PH',
            debugShowCheckedModeBanner: false, // Remove debug banner
            theme: ThemeData(
              primarySwatch: Colors.deepPurple,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                elevation: 2,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            routerConfig: _createRouter(authService),
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthService authService) {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final isLoggedIn = authService.currentUser != null;
        final currentLocation = state.uri.toString();
        
        print("🔄 Router redirect check:");
        print("   Current location: $currentLocation");
        print("   Is logged in: $isLoggedIn");
        print("   User type: ${authService.currentUserModel?.userType}");
        
        // If user is not logged in and not on login screen, redirect to login
        if (!isLoggedIn && currentLocation != '/login') {
          print("   ➡️ Redirecting to login (not authenticated)");
          return '/login';
        }
        
        // If user is logged in and on login screen, redirect based on user type
        if (isLoggedIn && currentLocation == '/login') {
          final userType = authService.currentUserModel?.userType;
          if (userType == 'customer') {
            print("   ➡️ Redirecting to customer home");
            return '/customer/home';
          } else if (userType == 'artist') {
            print("   ➡️ Redirecting to artist home");
            return '/artist/home';
          }
        }
        
        print("   ✅ No redirect needed");
        return null; // No redirect needed
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) {
            print("📱 Building LoginScreen");
            return const LoginScreen();
          },
        ),
        GoRoute(
          path: '/customer/home',
          builder: (context, state) {
            print("📱 Building CustomerHomeScreen");
            return const CustomerHomeScreen();
          },
        ),
        GoRoute(
          path: '/customer/search',
          builder: (context, state) {
            print("📱 Building SearchScreen");
            return const SearchScreen();
          },
        ),
        GoRoute(
          path: '/customer/profile',
          builder: (context, state) {
            print("📱 Building CustomerProfileScreen");
            return const CustomerProfileScreen();
          },
        ),
        GoRoute(
          path: '/artist/home',
          builder: (context, state) {
            print("📱 Building ArtistHomeScreen");
            return const ArtistHomeScreen();
          },
        ),
        GoRoute(
          path: '/artist/create',
          builder: (context, state) {
            print("📱 Building CreatePostScreen");
            return const CreatePostScreen();
          },
        ),
        GoRoute(
          path: '/artist/profile',
          builder: (context, state) {
            print("📱 Building ArtistProfileScreen");
            return const ArtistProfileScreen();
          },
        ),
        GoRoute(
          path: '/artist/:artistId',
          builder: (context, state) {
            final artistId = state.pathParameters['artistId']!;
            print("📱 Building ArtistProfileViewScreen for artist: $artistId");
            return ArtistProfileViewScreen(artistId: artistId);
          },
        ),
        GoRoute(
          path: '/chat/:chatId',
          builder: (context, state) {
            final chatId = state.pathParameters['chatId']!;
            print("📱 Building ChatScreen for chat: $chatId");
            return ChatScreen(chatId: chatId);
          },
        ),
      ],
      // Enhanced error handling
      errorBuilder: (context, state) {
        print("❌ Router error: ${state.error}");
        print("   Path: ${state.uri}");
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Page Not Found'),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Page Not Found',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The page "${state.uri}" could not be found.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Go to Login'),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}