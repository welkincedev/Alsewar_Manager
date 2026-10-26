import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../viewmodels/customer_viewmodel.dart';

/// Form to register a new customer for the manager's branch.
///
/// Required: username, email, password (≥ 6 chars).
/// Optional: phone, first_name, last_name.
/// The backend assigns the customer to the manager's branch automatically.
class CustomerRegisterScreen extends ConsumerStatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  ConsumerState<CustomerRegisterScreen> createState() =>
      _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState
    extends ConsumerState<CustomerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    ref.read(customerRegisterViewModelProvider.notifier).reset();
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(customerRegisterViewModelProvider.notifier)
        .register(
          username: _usernameCtrl.text,
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
          phone: _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : null,
          firstName: _firstNameCtrl.text.isNotEmpty
              ? _firstNameCtrl.text
              : null,
          lastName: _lastNameCtrl.text.isNotEmpty ? _lastNameCtrl.text : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(customerRegisterViewModelProvider);
    final isLoading = registerState is RegisterLoading;

    // Navigate to detail on success
    ref.listen<RegisterState>(customerRegisterViewModelProvider, (_, next) {
      if (next is RegisterSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Customer "${next.customer.displayName}" registered successfully.',
            ),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Pop back to list and let it refresh, then push detail.
        context.pop();
        context.push(AppRoutes.customerDetail(next.customer.id));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(title: const Text('Register Customer')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Section: Required ─────────────────────────────
              _SectionLabel(label: 'Required Information'),
              const SizedBox(height: 12),

              _Field(
                controller: _usernameCtrl,
                label: 'Username',
                icon: Icons.account_circle_outlined,
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Username is required.';
                  }
                  if (v.trim().length < 3) {
                    return 'Username must be at least 3 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              _Field(
                controller: _emailCtrl,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Email is required.';
                  }
                  if (!v.contains('@') || !v.contains('.')) {
                    return 'Enter a valid email address.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              _PasswordField(
                controller: _passwordCtrl,
                obscure: _obscurePassword,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24),

              // ── Section: Optional ─────────────────────────────
              _SectionLabel(label: 'Optional Information'),
              const SizedBox(height: 12),

              _Field(
                controller: _firstNameCtrl,
                label: 'First Name',
                icon: Icons.badge_outlined,
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
              ),
              const SizedBox(height: 14),

              _Field(
                controller: _lastNameCtrl,
                label: 'Last Name',
                icon: Icons.badge_outlined,
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
              ),
              const SizedBox(height: 14),

              _Field(
                controller: _phoneCtrl,
                label: 'Phone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                enabled: !isLoading,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 28),

              // ── Error banner ──────────────────────────────────
              if (registerState is RegisterError) ...[
                _ErrorBanner(message: registerState.message),
                const SizedBox(height: 20),
              ],

              // ── Submit button ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: AppColors.black,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Register Customer'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Form widgets ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool enabled;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      enabled: enabled,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final bool enabled;
  final TextInputAction textInputAction;

  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
    required this.enabled,
    required this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: onToggle,
          tooltip: obscure ? 'Show password' : 'Hide password',
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password is required.';
        if (v.length < 6) return 'Password must be at least 6 characters.';
        return null;
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.errorRed, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.errorRed,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
