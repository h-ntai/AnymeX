// lib/screens/anime/watch/controller/tv_remote_handler.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// TV Remote D-Pad handler for video playback
/// Implements menu-state-driven behavior
class TVRemoteHandler {
  final Function(Duration) onSeek;
  final Function() onToggleMenu;
  final Function() onExitPlayer;
  final Function() getCurrentPosition;
  final Function() getVideoDuration;
  final Function() isMenuVisible;
  final BuildContext context;

  TVRemoteHandler({
    required this.onSeek,
    required this.onToggleMenu,
    required this.onExitPlayer,
    required this.getCurrentPosition,
    required this.getVideoDuration,
    required this.isMenuVisible,
    required this.context
  });


  // Seek configuration
  static const int shortPressSeekSeconds = 10;
  static const int longPressAccumulationStart = 5;
  static const int longPressAccumulationStep = 5;

  void dispose() {
  }

  /// Main key event handler
  bool handleKeyEvent(KeyEvent event) {
    final menuVisible = isMenuVisible();

    if (event is KeyDownEvent) {
      return _handleKeyDown(event, menuVisible);
    } else if (event is KeyUpEvent) {
      return _handleKeyUp(event, menuVisible);
    }

    return false;
  }


  bool _handleKeyDown(KeyDownEvent event, bool menuVisible) {
    final key = event.logicalKey;

    // Menu visible state
    if (menuVisible) {
      if (key == LogicalKeyboardKey.goBack ||
          key == LogicalKeyboardKey.escape) {
        onToggleMenu(); // Close menu
        return true;
      }
      // Handle arrow keys for navigation when menu is visible
      if (key == LogicalKeyboardKey.arrowLeft ||
          key == LogicalKeyboardKey.arrowRight ||
          key == LogicalKeyboardKey.arrowUp ||
          key == LogicalKeyboardKey.arrowDown) {
        // Consume arrow keys for focus navigation
        _handleFocusNavigation(key);
        return true;
      }

      // Handle Enter/Select for activating focused item
      if (key == LogicalKeyboardKey.select ||
          key == LogicalKeyboardKey.enter) {
        // Let Flutter handle activation via FocusManager
        return false; // Allow default behavior
      }

      // Consume all other keys when menu is visible
      return true;
    }

    // Menu hidden state - playback controls active
    if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter) {
      onToggleMenu(); // Open menu
      return true;
    }

    if (key == LogicalKeyboardKey.goBack ||
        key == LogicalKeyboardKey.escape) {
      onExitPlayer(); // Exit player
      return true;
    }

    if (key == LogicalKeyboardKey.arrowLeft) {
      _handleLeftKey(event);
      return true;
    }

    if (key == LogicalKeyboardKey.arrowRight) {
      _handleRightKey(event);
      return true;
    }

    return false;
    }


  bool _handleKeyUp(KeyUpEvent event, bool menuVisible) {
    final key = event.logicalKey;

    // Only handle directional releases when menu is hidden
    if (!menuVisible) {
      if (key == LogicalKeyboardKey.arrowLeft ||
          key == LogicalKeyboardKey.arrowRight) {
        return true;
      }
    }

    return false;
  }

  void _handleFocusNavigation(LogicalKeyboardKey key) {
    final focusScope = FocusScope.of(context);
    
    switch (key) {
      case LogicalKeyboardKey.arrowLeft:
        focusScope.focusInDirection(TraversalDirection.left);
        break;
      case LogicalKeyboardKey.arrowRight:
        focusScope.focusInDirection(TraversalDirection.right);
        break;
      case LogicalKeyboardKey.arrowUp:
        focusScope.focusInDirection(TraversalDirection.up);
        break;
      case LogicalKeyboardKey.arrowDown:
        focusScope.focusInDirection(TraversalDirection.down);
        break;
      default:
        break;
    }
  }

  void _handleLeftKey(KeyDownEvent event) {

    _executeShortPress(SeekDirection.backward);

  }


  void _handleRightKey(KeyDownEvent event) {

    _executeShortPress(SeekDirection.forward);

  }



  void _executeShortPress(SeekDirection direction) {
    final currentPos = getCurrentPosition() as Duration;
    final duration = getVideoDuration() as Duration;

    int seekSeconds = direction == SeekDirection.backward
        ? -shortPressSeekSeconds
        : shortPressSeekSeconds;

    final targetPosition = _clampPosition(
      currentPos.inSeconds + seekSeconds,
      duration.inSeconds,
    );

    onSeek(Duration(seconds: targetPosition));
    
  }






  int _clampPosition(int targetSeconds, int maxSeconds) {
    return targetSeconds.clamp(0, maxSeconds);
  }
}

enum SeekDirection {
  none,
  forward,
  backward,
}