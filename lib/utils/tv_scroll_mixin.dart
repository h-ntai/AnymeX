// lib/utils/tv_scroll_mixin.dart
// Universal Mixin for TV Auto-Scroll with improved navigation
import 'package:anymex/controllers/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Improved TV scroll mixin that handles dynamic content and better focus management
/// 
/// Usage:
/// ```dart
/// class _MyPageState extends State<MyPage> with TVScrollMixin {
///   @override
///   void initState() {
///     super.initState();
///     initTVScroll();
///   }
///   
///   @override
///   void dispose() {
///     disposeTVScroll();
///     super.dispose();
///   }
/// }
/// ```
mixin TVScrollMixin<T extends StatefulWidget> on State<T> {
  
  void initTVScroll() {
    if (Get.find<Settings>().isTV.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusManager.instance.addListener(_handleTVFocusChange);
      });
    }
  }
  
  void disposeTVScroll() {
    if (Get.find<Settings>().isTV.value) {
      FocusManager.instance.removeListener(_handleTVFocusChange);
    }
  }
  
  void _handleTVFocusChange() {
    if (!mounted) return;
    final focusedContext = FocusManager.instance.primaryFocus?.context;
    if (focusedContext != null) {
      _ensureVisibleWithDynamicCheck(focusedContext);
    }
  }
  
  void _ensureVisibleWithDynamicCheck(BuildContext context) {
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final scrollable = Scrollable.maybeOf(context);
      if (scrollable != null) {
        final position = scrollable.position;
        
        if (position.pixels >= position.maxScrollExtent - 200) {
          if (mounted) {
            setState(() {
            });
          }
        }
      }
    });
  }
  
  ScrollPhysics getTVScrollPhysics() {
    return Get.find<Settings>().isTV.value
        ? const BouncingScrollPhysics()
        : const AlwaysScrollableScrollPhysics();
  }
  
  /// Call this after dynamically adding items to the view
  void refreshTVFocusableItems() {
    if (Get.find<Settings>().isTV.value && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).requestFocus();
        }
      });
    }
  }
}
