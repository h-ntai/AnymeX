import 'package:flutter/material.dart';
import 'package:anymex/utils/platform_utils.dart';

class ExperimentalFeaturesPage extends StatefulWidget {
  const ExperimentalFeaturesPage({Key? key}) : super(key: key);

  @override
  State<ExperimentalFeaturesPage> createState() => _ExperimentalFeaturesPageState();
}

class _ExperimentalFeaturesPageState extends State<ExperimentalFeaturesPage> {
  bool _isLoading = true;
  bool _isTV = false;
  bool _forceDesktop = false;
  String _uiMode = 'normal';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final tv = await PlatformUtils.isAndroidTV();
    final desktop = await PlatformUtils.getForceDesktopLayout();
    final mode = await PlatformUtils.getUIMode();
    
    if (mounted) {
      setState(() {
        _isTV = tv;
        _forceDesktop = desktop;
        _uiMode = mode;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Experimental Features'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Platform Info Card
                if (_isTV || _forceDesktop)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isTV ? Icons.tv : Icons.desktop_windows,
                          size: 32,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isTV ? 'Android TV Detected' : 'Desktop Layout Active',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'UI Mode: $_uiMode',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // TV/Desktop Layout Section
                Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.tv,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'TV / Desktop Layout',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Force Desktop Layout'),
                        subtitle: Text(
                          _isTV
                              ? 'Already using TV layout (auto-detected)\nCannot be disabled on TV devices'
                              : 'Enable desktop/TV optimized interface with sidebar navigation\n\n⚠️ Requires app restart to take effect',
                          style: TextStyle(fontSize: 13),
                        ),
                        value: _forceDesktop || _isTV,
                        onChanged: _isTV
                            ? null // Disable toggle if TV
                            : (value) async {
                                await PlatformUtils.setForceDesktopLayout(value);
                                
                                if (mounted) {
                                  setState(() {
                                    _forceDesktop = value;
                                  });
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        '✓ Setting saved. Please restart the app to apply changes.',
                                      ),
                                      duration: const Duration(seconds: 4),
                                      action: SnackBarAction(
                                        label: 'OK',
                                        onPressed: () {},
                                      ),
                                    ),
                                  );
                                }
                              },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'About Desktop Layout',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Desktop layout features:\n'
                          '• macOS-style sidebar navigation\n'
                          '• Optimized for large screens\n'
                          '• Better D-Pad navigation on TV\n'
                          '• Larger touch targets\n\n'
                          'This layout is automatically enabled on:\n'
                          '• Android TV devices\n'
                          '• Windows, macOS, Linux\n'
                          '• Web browsers',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
