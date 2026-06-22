import 'package:flutter/cupertino.dart';

enum ResponsiveClass { phone, tablet, desktop }

ResponsiveClass responsiveClassForWidth(double width) {
  if (width >= 1100) return ResponsiveClass.desktop;
  if (width >= 720) return ResponsiveClass.tablet;
  return ResponsiveClass.phone;
}

bool isWideLayout(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= 900;
}

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    required this.child,
    this.maxWidth = 980,
    this.alignment = Alignment.topCenter,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = switch (responsiveClassForWidth(width)) {
      ResponsiveClass.phone => 0.0,
      ResponsiveClass.tablet => 20.0,
      ResponsiveClass.desktop => 32.0,
    };
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          child: child,
        ),
      ),
    );
  }
}
