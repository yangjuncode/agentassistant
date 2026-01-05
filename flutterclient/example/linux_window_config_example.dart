import 'package:flutter/material.dart';
import 'package:agentassistant/services/window_service.dart';

/// Example showing how to configure Linux X11 window behavior
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window service
  await WindowService().initialize();

  // Configure Linux X11 behavior for different scenarios
  await configureForDifferentScenarios();

  runApp(const LinuxWindowConfigExample());
}

/// Configure window behavior for different use cases
Future<void> configureForDifferentScenarios() async {
  final windowService = WindowService();

  // Scenario 1: Conservative mode (less intrusive)
  print('Configuring conservative mode...');
  windowService.configureLinuxBehavior(
    alwaysOnTopDuration: const Duration(seconds: 2),
    useAggressiveMode: false,
  );

  // Wait a bit
  await Future.delayed(const Duration(seconds: 1));

  // Scenario 2: Aggressive mode (ensures visibility)
  print('Configuring aggressive mode...');
  windowService.configureLinuxBehavior(
    alwaysOnTopDuration: const Duration(seconds: 5),
    useAggressiveMode: true,
  );

  // Scenario 3: Very persistent mode (for critical notifications)
  print('Configuring persistent mode...');
  windowService.configureLinuxBehavior(
    alwaysOnTopDuration: const Duration(seconds: 10),
    useAggressiveMode: true,
  );
}

class LinuxWindowConfigExample extends StatefulWidget {
  const LinuxWindowConfigExample({super.key});

  @override
  State<LinuxWindowConfigExample> createState() =>
      _LinuxWindowConfigExampleState();
}

class _LinuxWindowConfigExampleState extends State<LinuxWindowConfigExample> {
  final WindowService _windowService = WindowService();
  Duration _currentDuration = const Duration(seconds: 5);
  bool _aggressiveMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linux Window Config Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Linux X11 Window Configuration'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configure Linux X11 Window Behavior',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Always on top duration configuration
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Always On Top Duration',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Text('Current: ${_currentDuration.inSeconds} seconds'),
                      Slider(
                        value: _currentDuration.inSeconds.toDouble(),
                        min: 1,
                        max: 15,
                        divisions: 14,
                        label: '${_currentDuration.inSeconds}s',
                        onChanged: (value) {
                          setState(() {
                            _currentDuration = Duration(seconds: value.round());
                          });
                          _updateConfiguration();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Aggressive mode toggle
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aggressive Mode',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Aggressive mode uses multiple focus attempts and longer delays to ensure the window comes to front on Linux X11.',
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        title: const Text('Enable Aggressive Mode'),
                        subtitle: Text(_aggressiveMode
                            ? 'Multiple focus attempts, longer delays'
                            : 'Standard window operations'),
                        value: _aggressiveMode,
                        onChanged: (value) {
                          setState(() {
                            _aggressiveMode = value;
                          });
                          _updateConfiguration();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Test button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _testWindowBringToFront,
                  icon: const Icon(Icons.launch),
                  label: const Text('Test Window Bring to Front'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Instructions
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Instructions',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '1. Minimize this window or hide it behind other windows\n'
                        '2. Click the test button to simulate bringing window to front\n'
                        '3. Observe how the window behaves with different settings\n'
                        '4. Adjust the configuration based on your desktop environment',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateConfiguration() {
    _windowService.configureLinuxBehavior(
      alwaysOnTopDuration: _currentDuration,
      useAggressiveMode: _aggressiveMode,
    );
  }

  Future<void> _testWindowBringToFront() async {
    // Simulate a delay as if this was triggered by a message
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      await _windowService.bringToFrontAndStay();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Window bring to front triggered! '
                'Duration: ${_currentDuration.inSeconds}s, '
                'Aggressive: $_aggressiveMode'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
