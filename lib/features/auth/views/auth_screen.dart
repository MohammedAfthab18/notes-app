import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
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
      backgroundColor: const Color(0xFF050505),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 34),
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    onPressed: firebaseEnabled ? () => context.go('/') : null,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
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
                  onModeChanged: (mode) => setState(() => _mode = mode),
                  onTogglePassword: () =>
                      setState(() => _hidePassword = !_hidePassword),
                  onPrimaryAction: _submit,
                  onGoogle: _googleSignIn,
                ),
              ],
            ),
          ),
        ),
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
    final signIn = mode == AuthMode.signIn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: _NotesHubMark()),
        const SizedBox(height: 28),
        Text(
          signIn ? 'Welcome back' : 'Create account',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 29,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          signIn ? 'Let\'s get you into NotesHub' : 'Save and sync your notes',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF9B9BA1),
            fontSize: 17,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 34),
        CupertinoSlidingSegmentedControl<AuthMode>(
          groupValue: mode,
          backgroundColor: const Color(0xFF111113),
          thumbColor: CupertinoColors.white,
          children: {
            AuthMode.signIn: Text(
              'Sign in',
              style: TextStyle(
                color: signIn ? CupertinoColors.black : const Color(0xFFB7B7BC),
                fontWeight: FontWeight.w700,
              ),
            ),
            AuthMode.signUp: Text(
              'Register',
              style: TextStyle(
                color: !signIn ? CupertinoColors.black : const Color(0xFFB7B7BC),
                fontWeight: FontWeight.w700,
              ),
            ),
          },
          onValueChanged: (value) {
            if (value != null) onModeChanged(value);
          },
        ),
        const SizedBox(height: 18),
        if (!signIn) ...[
          _Field(controller: nameController, placeholder: 'Full name'),
          const SizedBox(height: 12),
        ],
        _Field(
          controller: emailController,
          placeholder: 'Email address',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _Field(
          controller: passwordController,
          placeholder: 'Password',
          obscureText: hidePassword,
          suffix: CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(34, 34),
            onPressed: onTogglePassword,
            child: Icon(
              hidePassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
              size: 19,
              color: const Color(0xFF8E8E93),
            ),
          ),
        ),
        if (!signIn) ...[
          const SizedBox(height: 12),
          _Field(
            controller: confirmController,
            placeholder: 'Confirm password',
            obscureText: hidePassword,
          ),
        ],
        if (signIn) ...[
          const SizedBox(height: 12),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 10),
            onPressed: () {},
            child: const Text(
              'Forgot password?',
              style: TextStyle(
                color: Color(0xFF9B9BA1),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: 10),
          Text(
            error!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.rose,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: 18),
        CupertinoButton(
          borderRadius: BorderRadius.circular(24),
          color: CupertinoColors.white,
          disabledColor: const Color(0xFF3A3A3C),
          padding: const EdgeInsets.symmetric(vertical: 17),
          onPressed: busy || !firebaseEnabled ? null : onPrimaryAction,
          child: busy
              ? const CupertinoActivityIndicator(color: CupertinoColors.black)
              : Text(
                  signIn ? 'Sign in' : 'Create account',
                  style: const TextStyle(
                    color: CupertinoColors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
        const SizedBox(height: 24),
        const _DividerLabel(),
        const SizedBox(height: 24),
        CupertinoButton(
          borderRadius: BorderRadius.circular(22),
          color: const Color(0xFF151516),
          disabledColor: const Color(0xFF101011),
          padding: const EdgeInsets.symmetric(vertical: 15),
          onPressed: busy || kIsWeb || !firebaseEnabled ? null : onGoogle,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GoogleLogo(size: 20),
              SizedBox(width: 12),
              Text(
                'Continue with Google',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        if (kIsWeb) ...[
          const SizedBox(height: 12),
          const Text(
            'Google sign-in is enabled for the Android build.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
          ),
        ],
        const SizedBox(height: 24),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () =>
              onModeChanged(signIn ? AuthMode.signUp : AuthMode.signIn),
          child: Text(
            signIn ? 'Don\'t have an account?' : 'Already have an account?',
            style: const TextStyle(
              color: Color(0xFF9B9BA1),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.placeholder,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
  });

  final TextEditingController controller;
  final String placeholder;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      cursorColor: CupertinoColors.white,
      style: const TextStyle(
        color: CupertinoColors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      placeholderStyle: const TextStyle(
        color: Color(0xFF747479),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
      suffix: suffix == null
          ? null
          : Padding(padding: const EdgeInsets.only(right: 12), child: suffix),
      decoration: BoxDecoration(
        color: CupertinoColors.black,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3B3B40), width: 1.2),
      ),
    );
  }
}

class _NotesHubMark extends StatelessWidget {
  const _NotesHubMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: CupertinoColors.white, width: 2.4),
          ),
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'NotesHub',
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 29,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: ColoredBox(
            color: Color(0xFF2C2C2E),
            child: SizedBox(height: 1),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'or',
            style: TextStyle(
              color: Color(0xFFB0B0B5),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ColoredBox(
            color: Color(0xFF2C2C2E),
            child: SizedBox(height: 1),
          ),
        ),
      ],
    );
  }
}

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({this.size = 20, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * .16;
    final arcRect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(arcRect, -.05, 1.45, false, paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(arcRect, 1.40, 1.22, false, paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(arcRect, 2.62, 1.22, false, paint);

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(arcRect, 3.84, 1.55, false, paint);

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.square;
    final y = size.height * .52;
    canvas.drawLine(
      Offset(size.width * .52, y),
      Offset(size.width * .92, y),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
