import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import '../services/auth_service.dart';
import '../widgets/responsive_center.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSuccess = false;
  String _sentEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final authService = Provider.of<AuthService>(context, listen: false);
    final email = _emailController.text.trim();

    final success = await authService.sendPasswordResetEmail(email);

    if (mounted) {
      if (success) {
        setState(() {
          _isSuccess = true;
          _sentEmail = email;
        });
      } else if (authService.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.errorMessage!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = context.watch<AuthService>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: ResponsiveCenter(
            maxWidth: 500,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SingleChildScrollView(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _isSuccess
                      ? _buildSuccessView(theme)
                      : _buildFormView(theme, authService),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= FORM VIEW =================
  Widget _buildFormView(ThemeData theme, AuthService authService) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🔐 Icon Header
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_reset_outlined,
                size: 36,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 🔑 Title & Subtitle
          Text(
            "Forgot Password",
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Enter your registered email address and we'll send you a password reset link.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 32),

          // 📧 Email Input
          TextFormField(
            controller: _emailController,
            enabled: !authService.isLoading,
            decoration: const InputDecoration(
              labelText: "Email Address",
              hintText: "you@example.com",
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please enter your email address";
              }
              if (!EmailValidator.validate(value.trim())) {
                return "Please enter a valid email address";
              }
              return null;
            },
          ),

          const SizedBox(height: 28),

          // 🚀 Send Link Button
          ElevatedButton(
            onPressed: authService.isLoading ? null : _submit,
            child: authService.isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text("Send Reset Link"),
          ),

          const SizedBox(height: 16),

          // ⬅️ Back to Login Button
          OutlinedButton(
            onPressed: authService.isLoading
                ? null
                : () => Navigator.pop(context),
            child: const Text("Back to Login"),
          ),
        ],
      ),
    );
  }

  // ================= SUCCESS VIEW =================
  Widget _buildSuccessView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ✅ Success Icon
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 36,
              color: Colors.green,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Title
        Text(
          "Password Reset Link Sent",
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          "We've sent a password reset email to:",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),

        const SizedBox(height: 8),

        // Email Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _sentEmail,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          "Please check your inbox and follow the instructions to reset your password.",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            height: 1.4,
          ),
        ),

        const SizedBox(height: 32),

        // 🚀 Back to Login
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Back to Login"),
        ),

        const SizedBox(height: 12),

        // 🔄 Resend Email
        TextButton(
          onPressed: () {
            setState(() => _isSuccess = false);
          },
          child: const Text("Did not receive email? Try again"),
        ),
      ],
    );
  }
}
