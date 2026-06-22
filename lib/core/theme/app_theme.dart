import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';

enum AppAppearance { system, light, dark }

enum ReaderTone { white, sepia, amoled }

final appThemeProvider = Provider<AppTheme>((ref) {
  final box = Hive.box<dynamic>(AppConstants.settingsBox);
  final appearanceName =
      box.get('appearance', defaultValue: AppAppearance.system.name) as String;
  final brightness = PlatformDispatcher.instance.platformBrightness;
  final appearance = AppAppearance.values.byName(appearanceName);
  final isDark =
      appearance == AppAppearance.dark ||
      (appearance == AppAppearance.system && brightness == Brightness.dark);
  return AppTheme(isDark: isDark);
});

class AppTheme {
  const AppTheme({required this.isDark});

  final bool isDark;

  Color get background =>
      isDark ? const Color(0xFF0B0B0D) : const Color(0xFFF6F4EF);
  Color get elevated =>
      isDark ? const Color(0xFF17171B) : const Color(0xFFFFFFFF);
  Color get text => isDark ? const Color(0xFFF8F8F8) : const Color(0xFF171717);
  Color get secondaryText =>
      isDark ? const Color(0xFFA7A7AD) : const Color(0xFF6F6E73);
  Color get tint => const Color(0xFF0A84FF);
  Color get mint => const Color(0xFF32D74B);
  Color get amber => const Color(0xFFFFB340);
  Color get rose => const Color(0xFFFF5D73);
  Color get purple => const Color(0xFF8E8CFF);
  Color get glass =>
      (isDark ? const Color(0xFF24242A) : const Color(0xFFFFFFFF)).withValues(
        alpha: .62,
      );
  Color get hairline => (isDark ? CupertinoColors.white : CupertinoColors.black)
      .withValues(alpha: .08);

  CupertinoThemeData get cupertinoTheme {
    final baseText =
        GoogleFonts.interTextTheme().bodyMedium?.fontFamily ?? 'Inter';
    return CupertinoThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: tint,
      scaffoldBackgroundColor: background,
      barBackgroundColor: background.withValues(alpha: .78),
      textTheme: CupertinoTextThemeData(
        primaryColor: text,
        textStyle: TextStyle(
          fontFamily: baseText,
          color: text,
          fontSize: 16,
          height: 1.35,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: baseText,
          color: text,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: baseText,
          color: text,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class GlassSurface extends StatelessWidget {
  const GlassSurface({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = AppConstants.borderRadius,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ProviderScope.containerOf(context).read(appThemeProvider);
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.glass,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: theme.hairline),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withValues(
                  alpha: theme.isDark ? .24 : .08,
                ),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
    if (onTap == null) return content;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: content,
    );
  }
}
