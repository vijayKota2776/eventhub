import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub/providers/auth_provider.dart';
import 'package:eventhub/models/app_user.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  UserRole _selectedRole = UserRole.attendee;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter both email and password.');
      return;
    }

    if (!_isLogin && _nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your full name.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        await ref.read(authControllerProvider.notifier).signIn(
              email,
              password,
            );
      } else {
        await ref.read(authControllerProvider.notifier).signUp(
              email,
              password,
              _nameController.text.trim(),
              _selectedRole,
            );
      }
    } catch (e) {
      final errStr = e.toString();
      setState(() {
        if (errStr.contains('over_email_send_rate_limit') ||
            errStr.contains('security purposes')) {
          _errorMessage =
              '⏱️ Supabase Email Rate Limit: You can only request 1 email per minute.\n'
              'If you already created an account, click "Already have an account? Sign in" below!';
        } else if (errStr.contains('Invalid login credentials')) {
          _errorMessage =
              '❌ Invalid email or password. Please check your credentials or register a new account.';
        } else if (errStr.contains('User already registered')) {
          _errorMessage =
              'ℹ️ This email is already registered! Switch to "Sign in" below to log in.';
        } else {
          _errorMessage = errStr.replaceAll('Exception:', '').trim();
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.confirmation_number,
                        size: 32, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      'EventHub',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin ? 'Welcome Back — Sign In' : 'Join EventHub — Register',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 28),

                // ── Full Name (Register only) ──────────────────────
                if (!_isLogin) ...[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Email ───────────────────────────────────────────
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // ── Password ────────────────────────────────────────
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                // ── Role Selector (Register only) ───────────────────
                if (!_isLogin) ...[
                  DropdownButtonFormField<UserRole>(
                    initialValue: _selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Account Type',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: UserRole.attendee,
                        child: Text('Attendee (Discover & Book)'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.organizer,
                        child: Text('Event Organizer (Host & Manage)'),
                      ),
                    ],
                    onChanged: (role) {
                      if (role != null) setState(() => _selectedRole = role);
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Error Message Banner ────────────────────────────
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                          color: colorScheme.onErrorContainer, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // ── Submit Button ───────────────────────────────────
                FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _isLogin ? 'Sign In' : 'Create Account',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 12),

                // ── Toggle Login / Sign Up ──────────────────────────
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _errorMessage = null;
                    });
                  },
                  child: Text(_isLogin
                      ? "Don't have an account? Sign up"
                      : "Already have an account? Sign in"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
