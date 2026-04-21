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
  ScanMode _selectedMode = ScanMode.multispectral;
  bool _isScanning = false;
  String _scanStatus = 'READY';
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
      _scanStatus = _selectedMode == ScanMode.multispectral ? 'INITIALIZING...' : 'STARTING...';
    });
    _pulseController.repeat(reverse: true);

    if (_selectedMode == ScanMode.multispectral) {
      final phases = [
        'CAPTURING UV (395nm)',
        'CAPTURING VIS (550nm)',
        'CAPTURING RED (660nm)',
        'CAPTURING FAR RED (730nm)',
        'CAPTURING NIR (850nm)',
        'ANALYZING DATA...'
      ];

      for (var phase in phases) {
        if (!mounted) return;
        setState(() => _scanStatus = phase);
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }

    try {
      final result = await MockDataService.simulateScan(_selectedMode);
      if (mounted) {
        setState(() {
          _lastResult = result;
          _isScanning = false;
          _scanStatus = 'COMPLETED';
        });
        _pulseController.stop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _scanStatus = 'ERROR';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Subtitle or description instead of mode selector
            const Text(
              'MULTISPECTRAL ANALYSIS',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Automated 395nm - 850nm sequence for pesticide detection',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: 48),
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
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _isScanning
                              ? [Colors.grey[800]!, Colors.grey[900]!]
                              : [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isScanning ? Colors.black : Theme.of(context).primaryColor).withOpacity(0.3),
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
                            _isScanning ? 'SCANNING' : 'START SCAN',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isScanning) ...[
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Text(
                      _scanStatus,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 48),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _lastResult != null
                  ? ResultCard(result: _lastResult!)
                  : const SizedBox(height: 180, child: Center(child: Text('Press the button to analyze a sample'))),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
