import 'package:flutter/material.dart';
import '../models/scan_models.dart';
import '../services/mock_data_service.dart';
import '../widgets/result_card.dart';

class ScanTab extends StatefulWidget {
  const ScanTab({super.key});

  @override
  State<ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> with SingleTickerProviderStateMixin {
  ScanMode _selectedMode = ScanMode.vis;
  bool _isScanning = false;
  ScanResult? _lastResult;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _lastResult = null;
    });
    _pulseController.repeat(reverse: true);

    try {
      final result = await MockDataService.simulateScan(_selectedMode);
      if (mounted) {
        setState(() {
          _lastResult = result;
          _isScanning = false;
        });
        _pulseController.stop();
      }
    } catch (e) {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            'Scanner Mode',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: ScanMode.values.map((mode) {
              final isSelected = _selectedMode == mode;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMode = mode),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          mode.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.white70,
                          ),
                        ),
                        Text(
                          mode.description.split(' ').first,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white70 : Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Expanded(child: SizedBox()),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isScanning)
                  ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.2).animate(_pulseController),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: _isScanning ? null : _startScan,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isScanning ? Colors.grey[800] : Theme.of(context).primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isScanning ? Icons.sync_rounded : Icons.sensors_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isScanning ? 'SCANNING...' : 'START SCAN',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Expanded(child: SizedBox()),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _lastResult != null
                ? ResultCard(result: _lastResult!)
                : const SizedBox(height: 180, child: Center(child: Text('Press the button to analyze a sample'))),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
