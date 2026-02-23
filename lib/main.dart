// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'services/group_service.dart';
// import 'services/auth_service.dart';
// import 'storage/storage_service.dart';
// import 'screens/group_list_screen.dart';
// import 'screens/login_screen.dart';
// import 'screens/verify_email_screen.dart';
// import 'theme/app_theme.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   bool firebaseReady = false;
//   String? firebaseError;
//
//   try {
//     await Firebase.initializeApp();
//     firebaseReady = true;
//   } catch (e) {
//     firebaseError = e.toString();
//     // Firebase not configured yet - app will still work locally (without login)
//     debugPrint('Firebase initialization error: $e');
//     debugPrint('Please set up Firebase to use authentication');
//   }
//
//   // Initialize storage
//   final storageService = StorageService();
//   await storageService.init();
//
//   runApp(
//     MultiProvider(
//       providers: [
//         if (firebaseReady) ChangeNotifierProvider(create: (_) => AuthService()),
//         ChangeNotifierProvider(create: (_) => GroupService()..loadGroups()),
//       ],
//       child: MyApp(firebaseReady: firebaseReady, firebaseError: firebaseError),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   final bool firebaseReady;
//   final String? firebaseError;
//
//   const MyApp({super.key, required this.firebaseReady, this.firebaseError});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Mini Splitwise',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.darkTheme,
//       themeMode: ThemeMode.system,
//       home: AuthWrapper(
//         firebaseReady: firebaseReady,
//         firebaseError: firebaseError,
//       ),
//     );
//   }
// }
//
// class AuthWrapper extends StatelessWidget {
//   final bool firebaseReady;
//   final String? firebaseError;
//
//   const AuthWrapper({
//     super.key,
//     required this.firebaseReady,
//     this.firebaseError,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (!firebaseReady) {
//       // Firebase not initialized: show a friendly message
//       return Scaffold(
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'Firebase not configured',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   firebaseError ??
//                       'Please add Firebase config files and retry.',
//                   style: const TextStyle(color: Colors.grey),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//     return Consumer<AuthService>(
//       builder: (context, authService, child) {
//         // Listen to auth state changes
//         return StreamBuilder<User?>(
//           stream: authService.authStateChanges,
//           builder: (context, snapshot) {
//             // Show loading while checking auth state
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Scaffold(
//                 body: Center(child: CircularProgressIndicator()),
//               );
//             }
//
//             final user = snapshot.data;
//
//             // If user is authenticated but email not verified, show verify screen
//             if (user != null && !user.emailVerified) {
//               return const VerifyEmailScreen();
//             }
//
//             // If user is authenticated and verified, show app
//             if (user != null && authService.isAuthenticated) {
//               return const GroupListScreen();
//             }
//
//             // Otherwise, show login screen
//             return const LoginScreen();
//           },
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/expense.dart';
import 'services/group_service.dart';
import 'services/auth_service.dart';
import 'storage/storage_service.dart';
import 'screens/group_list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/verify_email_screen.dart';
import 'theme/app_theme.dart';
// IMPORTANT: Ye file flutterfire configure ne generate ki hai
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive Setup
  final storageService = StorageService();
  await storageService.init();


  bool firebaseReady = false;
  String? firebaseError;

  try {
    // UPDATED: Ab ye options: DefaultFirebaseOptions.currentPlatform use karega
    // Isse Web aur Mobile dono par Firebase initialize ho jayega.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (e) {
    firebaseError = e.toString();
    debugPrint('Firebase initialization error: $e');
  }

  // Initialize storage (Hive)
  // final storageService = StorageService();
  // await storageService.init();

  runApp(
    MultiProvider(
      providers: [
        // AuthService ko hamesha provide karein taaki wrapper crash na ho
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => GroupService()..loadGroups()),
      ],
      child: MyApp(firebaseReady: firebaseReady, firebaseError: firebaseError),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool firebaseReady;
  final String? firebaseError;

  const MyApp({super.key, required this.firebaseReady, this.firebaseError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Splitwise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: AuthWrapper(
        firebaseReady: firebaseReady,
        firebaseError: firebaseError,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final bool firebaseReady;
  final String? firebaseError;

  const AuthWrapper({
    super.key,
    required this.firebaseReady,
    this.firebaseError,
  });

  @override
  Widget build(BuildContext context) {
    // Agar Firebase config missing hai (Khaas kar Web par initialization fail hone par)
    if (!firebaseReady) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Firebase Configuration Error',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  firebaseError ?? 'Make sure firebase_options.dart is correct.',
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return StreamBuilder<User?>(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final user = snapshot.data;

            // Email verification check
            if (user != null && !user.emailVerified) {
              return const VerifyEmailScreen();
            }

            // Authenticated users
            if (user != null) {
              return const GroupListScreen();
            }

            // Guest or Logged out
            return const LoginScreen();
          },
        );
      },
    );
  }
}