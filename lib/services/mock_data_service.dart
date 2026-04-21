import 'dart:math';
import '../models/scan_models.dart';

class MockDataService {
  static List<ScanResult> getMockHistory() {
    return [
      ScanResult(
        id: '1',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        mode: ScanMode.vis,
        status: SafetyStatus.safe,
        confidence: 0.98,
        spectralData: _generateMockSpectralData(),
      ),
      ScanResult(
        id: '2',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        mode: ScanMode.uv,
        status: SafetyStatus.caution,
        confidence: 0.76,
        spectralData: _generateMockSpectralData(),
      ),
      ScanResult(
        id: '3',
        timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
        mode: ScanMode.nir,
        status: SafetyStatus.unsafe,
        confidence: 0.89,
        spectralData: _generateMockSpectralData(),
      ),
      ScanResult(
        id: '4',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        mode: ScanMode.vis,
        status: SafetyStatus.safe,
        confidence: 0.94,
        spectralData: _generateMockSpectralData(),
      ),
    ];
  }

  static List<double> _generateMockSpectralData() {
    final random = Random();
    return List.generate(50, (index) {
      // Create a wavy pattern with some noise
      return 0.5 + 0.3 * sin(index / 5) + 0.1 * random.nextDouble();
    });
  }

  static Future<ScanResult> simulateScan(ScanMode mode) async {
    await Future.delayed(const Duration(seconds: 3)); // Simulate delay
    
    final random = Random();
    final statuses = SafetyStatus.values;
    final randomStatus = statuses[random.nextInt(statuses.length)];
    
    return ScanResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      mode: mode,
      status: randomStatus,
      confidence: 0.85 + (random.nextDouble() * 0.14),
      spectralData: _generateMockSpectralData(),
    );
  }
}
