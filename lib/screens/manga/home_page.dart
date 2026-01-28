// ignore_for_file: invalid_use_of_protected_member
import 'package:anymex/controllers/source/source_controller.dart';
import 'package:anymex/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:anymex/controllers/settings/settings.dart';
import 'package:get/get.dart';
import 'package:anymex/controllers/service_handler/service_handler.dart';
import 'package:anymex/widgets/common/scroll_aware_app_bar.dart';

class MangaHomePage extends StatefulWidget {
  const MangaHomePage({
    super.key,
  });
  
  @override
  State<MangaHomePage> createState() => _MangaHomePageState();
}

class _MangaHomePageState extends State<MangaHomePage> {
  late ScrollController _scrollController;
  final ValueNotifier<bool> _isAppBarVisibleExternally =
      ValueNotifier<bool>(true);
  
  FocusNode? _scrollFocusNode;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    sourceController.initNovelExtensions();
    
    if (Get.find<Settings>().isTV.value) {
      _scrollFocusNode = FocusNode();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusManager.instance.addListener(_handleFocusChange);
      });
    }
  }
  
  ScrollController get scrollController => _scrollController;
  
  void _handleFocusChange() {
    if (!mounted) return;
    final focusedContext = FocusManager.instance.primaryFocus?.context;
    if (focusedContext != null) {
      Scrollable.ensureVisible(
        focusedContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    }
  }
  
  KeyEventResult _handleTVScrollKeys(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _scrollController.animateTo(
          _scrollController.offset + 150,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _scrollController.animateTo(
          _scrollController.offset - 150,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _isAppBarVisibleExternally.dispose();
    
    if (Get.find<Settings>().isTV.value) {
      FocusManager.instance.removeListener(_handleFocusChange);
      _scrollFocusNode?.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final serviceHandler = Get.find<ServiceHandler>();
    bool isTV = Get.find<Settings>().isTV.value;
    final isDesktop = isTV ? true : MediaQuery.of(context).size.width > 600;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    const appBarHeight = kToolbarHeight + 20;
    final double bottomNavBarHeight = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          isTV
              ? Focus(
                  focusNode: _scrollFocusNode,
                  skipTraversal: true,
                  onKey: _handleTVScrollKeys,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: _buildScrollContent(
                      context,
                      serviceHandler,
                      isDesktop,
                      statusBarHeight,
                      appBarHeight,
                      bottomNavBarHeight,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  controller: _scrollController,
                  child: _buildScrollContent(
                    context,
                    serviceHandler,
                    isDesktop,
                    statusBarHeight,
                    appBarHeight,
                    bottomNavBarHeight,
                  ),
                ),
          CustomAnimatedAppBar(
            isVisible: _isAppBarVisibleExternally,
            scrollController: _scrollController,
            headerContent: const Header(type: PageType.manga),
            visibleStatusBarStyle: SystemUiOverlayStyle(
              statusBarIconBrightness:
                  Theme.of(context).brightness == Brightness.light
                      ? Brightness.dark
                      : Brightness.light,
              statusBarBrightness: Theme.of(context).brightness,
              statusBarColor: Colors.transparent,
            ),
            hiddenStatusBarStyle: SystemUiOverlayStyle(
              statusBarIconBrightness:
                  Theme.of(context).brightness == Brightness.light
                      ? Brightness.light
                      : Brightness.dark,
              statusBarBrightness:
                  Theme.of(context).brightness == Brightness.light
                      ? Brightness.dark
                      : Brightness.light,
              statusBarColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildScrollContent(
    BuildContext context,
    ServiceHandler serviceHandler,
    bool isDesktop,
    double statusBarHeight,
    double appBarHeight,
    double bottomNavBarHeight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: statusBarHeight + appBarHeight),
        const SizedBox(height: 10),
        Obx(() {
          return Column(
            children: serviceHandler.mangaWidgets(context),
          );
        }),
        if (!isDesktop)
          SizedBox(height: bottomNavBarHeight)
        else
          const SizedBox(height: 50),
      ],
    );
  }
}
