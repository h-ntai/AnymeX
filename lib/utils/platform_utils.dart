import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlatformUtils {
  static const String _forceDesktopLayoutKey = 'force_desktop_layout';
  static const MethodChannel _platformChannel = MethodChannel('app.anymex/platform');
  
  static bool? _isTV;
  static bool? _forceDesktopLayout;

  static Future<bool> isAndroidTV() async {
    if (_isTV != null) return _isTV!;
    
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final result = await _platformChannel.invokeMethod<bool>('isTV');
        _isTV = result ?? false;
        return _isTV!;
      } catch (e) {
        print('Error checking TV mode: $e');
        _isTV = false;
        return false;
      }
    }
    return false;
  }

  static Future<String> getUIMode() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final result = await _platformChannel.invokeMethod<String>('getUIMode');
        return result ?? 'normal';
      } catch (e) {
        print('Error getting UI mode: $e');
        return 'normal';
      }
    }
    return 'normal';
  }

  static Future<bool> shouldUseDesktopLayout() async {
    final prefs = await SharedPreferences.getInstance();
    _forceDesktopLayout = prefs.getBool(_forceDesktopLayoutKey);
    
    if (_forceDesktopLayout == true) return true;
    
    if (await isAndroidTV()) return true;
    
    return kIsWeb || 
           defaultTargetPlatform == TargetPlatform.macOS ||
           defaultTargetPlatform == TargetPlatform.windows ||
           defaultTargetPlatform == TargetPlatform.linux;
  }

  static Future<void> setForceDesktopLayout(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_forceDesktopLayoutKey, value);
    _forceDesktopLayout = value;
    _isTV = null;
  }

  static Future<bool> getForceDesktopLayout() async {
    if (_forceDesktopLayout != null) return _forceDesktopLayout!;
    final prefs = await SharedPreferences.getInstance();
    _forceDesktopLayout = prefs.getBool(_forceDesktopLayoutKey) ?? false;
    return _forceDesktopLayout!;
  }

  static void resetCache() {
    _isTV = null;
    _forceDesktopLayout = null;
  }
}
