import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../providers/auth_providers.dart';

enum AuthMode { signIn, signUp }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _error = ValueNotifier<String?>(null);
  var _mode = AuthMode.signIn;
  var _busy = false;
  var _hidePassword = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _error.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final firebaseEnabled = ref.watch(firebaseEnabledProvider);

    return CupertinoPageScaffold(
      backgroundColor: theme.background,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.tint.withValues(alpha: .08),
                    theme.mint.withValues(alpha: .08),
                    theme.background,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: ResponsiveContent(
              maxWidth: 1120,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 900;
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: wide
                        ? Row(
                            children: [
                              Expanded(child: _BrandPane(theme: theme)),
                              const SizedBox(width: 24),
                              SizedBox(
                                width: 440,
                                child: _FormPane(
                                  theme: theme,
                                  firebaseEnabled: firebaseEnabled,
                                  mode: _mode,
                                  busy: _busy,
                                  hidePassword: _hidePassword,
                                  nameController: _name,
                                  emailController: _email,
                                  passwordController: _password,
                                  confirmController: _confirm,
                                  error: _error.value,
                                  onModeChanged: (mode) =>
                                      setState(() => _mode = mode),
                                  onTogglePassword: () => setState(
                                    () => _hidePassword = !_hidePassword,
                                  ),
                                  onPrimaryAction: _submit,
                                  onGoogle: _googleSignIn,
                                ),
                              ),
                            ],
                          )
                        : ListView(
                            children: [
                              _BrandPane(theme: theme),
                              const SizedBox(height: 18),
                              _FormPane(
                                theme: theme,
                                firebaseEnabled: firebaseEnabled,
                                mode: _mode,
                                busy: _busy,
                                hidePassword: _hidePassword,
                                nameController: _name,
                                emailController: _email,
                                passwordController: _password,
                                confirmController: _confirm,
                                error: _error.value,
                                onModeChanged: (mode) =>
                                    setState(() => _mode = mode),
                                onTogglePassword: () => setState(
                                  () => _hidePassword = !_hidePassword,
                                ),
                                onPrimaryAction: _submit,
                                onGoogle: _googleSignIn,
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_busy) return;
    _error.value = null;
    setState(() => _busy = true);
    try {
      final service = ref.read(authServiceProvider);
      if (_mode == AuthMode.signIn) {
        await service.signInWithEmail(
          email: _email.text,
          password: _password.text,
        );
      } else {
        if (_name.text.trim().isEmpty) {
          throw FirebaseAuthException(
            code: 'name-required',
            message: 'Please enter your name.',
          );
        }
        if (_password.text != _confirm.text) {
          throw FirebaseAuthException(
            code: 'password-mismatch',
            message: 'Passwords do not match.',
          );
        }
        await service.registerWithEmail(
          name: _name.text,
          email: _email.text,
          password: _password.text,
        );
      }
      if (mounted) context.go('/');
    } on FirebaseAuthException catch (e) {
      _error.value = e.message ?? e.code;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _googleSignIn() async {
    if (_busy || kIsWeb) return;
    _error.value = null;
    setState(() => _busy = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      if (mounted) context.go('/');
    } catch (e) {
      _error.value = e.toString();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _BrandPane extends StatelessWidget {
  const _BrandPane({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.elevated.withValues(alpha: .92),
            theme.background.withValues(alpha: .86),
          ],
        ),
        border: Border.all(color: theme.hairline),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: .12),
            blurRadius: 36,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NotesHub',
            style: TextStyle(
              color: theme.text,
              fontSize: 44,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'An elegant offline notes system with cloud-backed identity and sync.',
            style: TextStyle(
              color: theme.secondaryText,
              fontSize: 18,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),
          _Feature(theme: theme, title: 'Email and Google sign-in'),
          _Feature(theme: theme, title: 'Firestore cloud sync'),
          _Feature(theme: theme, title: 'Apple Notes-style reading and editing'),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.theme, required this.title});

  final AppTheme theme;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.tint.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(CupertinoIcons.check_mark, size: 16, color: theme.tint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: theme.text,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormPane extends StatelessWidget {
  const _FormPane({
    required this.theme,
    required this.firebaseEnabled,
    required this.mode,
    required this.busy,
    required this.hidePassword,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.error,
    required this.onModeChanged,
    required this.onTogglePassword,
    required this.onPrimaryAction,
    required this.onGoogle,
  });

  final AppTheme theme;
  final bool firebaseEnabled;
  final AuthMode mode;
  final bool busy;
  final bool hidePassword;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final String? error;
  final ValueChanged<AuthMode> onModeChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onPrimaryAction;
  final VoidCallback onGoogle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.elevated.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.hairline),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: .14),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoSlidingSegmentedControl<AuthMode>(
            groupValue: mode,
            children: const {
              AuthMode.signIn: Text('Login'),
              AuthMode.signUp: Text('Register'),
            },
            onValueChanged: (value) {
              if (value != null) onModeChanged(value);
            },
          ),
          const SizedBox(height: 18),
          if (mode == AuthMode.signUp) ...[
            _Field(
              controller: nameController,
              placeholder: 'Full name',
              icon: CupertinoIcons.person,
            ),
            const SizedBox(height: 12),
          ],
          _Field(
            controller: emailController,
            placeholder: 'Email address',
            icon: CupertinoIcons.mail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _Field(
            controller: passwordController,
            placeholder: 'Password',
            icon: CupertinoIcons.lock,
            obscureText: hidePassword,
            suffix: CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 28,
              onPressed: onTogglePassword,
              child: Icon(
                hidePassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                size: 18,
                color: theme.secondaryText,
              ),
            ),
          ),
          if (mode == AuthMode.signUp) ...[
            const SizedBox(height: 12),
            _Field(
              controller: confirmController,
              placeholder: 'Confirm password',
              icon: CupertinoIcons.lock_shield,
              obscureText: hidePassword,
            ),
          ],
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(
              error!,
              style: TextStyle(
                color: theme.rose,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 18),
          CupertinoButton.filled(
            borderRadius: BorderRadius.circular(18),
            onPressed: busy || !firebaseEnabled ? null : onPrimaryAction,
            child: busy
                ? const CupertinoActivityIndicator()
                : Text(mode == AuthMode.signIn ? 'Login' : 'Create account'),
          ),
          const SizedBox(height: 12),
          CupertinoButton(
            borderRadius: BorderRadius.circular(18),
            color: CupertinoColors.white.withValues(alpha: .06),
            onPressed: busy || kIsWeb || !firebaseEnabled ? null : onGoogle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4B400),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'G',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('Continue with Google'),
              ],
            ),
          ),
          if (kIsWeb) ...[
            const SizedBox(height: 12),
            Text(
              'Firebase sign-in is enabled for the Android build in this workspace.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.secondaryText,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.placeholder,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
  });

  final TextEditingController controller;
  final String placeholder;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      prefix: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Icon(icon, size: 18, color: theme.primaryColor),
      ),
      suffix: suffix == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: 12),
              child: suffix,
            ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CupertinoColors.separator.resolveFrom(context)),
      ),
    );
  }
}
