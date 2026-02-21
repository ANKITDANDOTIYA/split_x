// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'login_screen.dart';
// import 'group_list_screen.dart';
//
// class VerifyEmailScreen extends StatelessWidget {
//   const VerifyEmailScreen({super.key});
//
//   Future<void> _checkVerified(BuildContext context) async {
//     final user = FirebaseAuth.instance.currentUser;
//     await user?.reload();
//     final refreshed = FirebaseAuth.instance.currentUser;
//
//     if (refreshed != null && refreshed.emailVerified) {
//       // Go into the app
//       // AuthWrapper would also handle this, but we can go directly
//       // and the stream will keep things in sync.
//       // Clear back stack.
//       // ignore: use_build_context_synchronously
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const GroupListScreen()),
//         (route) => false,
//       );
//     } else {
//       // ignore: use_build_context_synchronously
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Email not verified yet. Please check your inbox.'),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Verify Email')),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'A verification email has been sent to your inbox.\n\n'
//                 'Please click the link in the email to verify your account.',
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: () => _checkVerified(context),
//                 child: const Text('I have verified, continue'),
//               ),
//               const SizedBox(height: 12),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => const LoginScreen(),
//                     ),
//                     (route) => false,
//                   );
//                 },
//                 child: const Text('Back to Login'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'group_list_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isChecking = false;

  Future<void> _checkVerified() async {
    if (_isChecking) return;

    setState(() => _isChecking = true);

    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    final refreshed = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (refreshed != null && refreshed.emailVerified) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const GroupListScreen()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Email not verified yet. Please check your inbox.",
          ),
        ),
      );
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 📧 Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color:
                        theme.colorScheme.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mark_email_read_outlined,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 🔐 Title
                    Text(
                      "Verify your email",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "We’ve sent a verification link to your email address.\n"
                          "Please open your inbox and click the link to continue.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                        theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ✅ Continue Button
                    ElevatedButton(

                      onPressed: _isChecking ? null : _checkVerified,
                      child: _isChecking
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Text("I’ve verified, continue"),
                    ),

                    const SizedBox(height: 16),

                    // 🔙 Back to login
                    TextButton(
                      onPressed: _isChecking
                          ? null
                          : () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                              (route) => false,
                        );
                      },
                      child: const Text("Back to Login"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
