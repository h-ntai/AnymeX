import 'package:flutter/material.dart';
import 'package:anymex/utils/platform_utils.dart';

/// Widget das automatisch zwischen Mobile und Desktop Layout wechselt
class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget desktopLayout;
  final bool? forceDesktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobileLayout,
    required this.desktopLayout,
    this.forceDesktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (forceDesktop != null) {
      return forceDesktop! ? desktopLayout : mobileLayout;
    }

    return FutureBuilder<bool>(
      future: PlatformUtils.shouldUseDesktopLayout(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        return snapshot.data == true ? desktopLayout : mobileLayout;
      },
    );
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isDesktop) builder;
  
  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: PlatformUtils.shouldUseDesktopLayout(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return builder(context, snapshot.data ?? false);
      },
    );
  }
}
