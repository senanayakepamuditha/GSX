import 'package:flutter/material.dart';

enum ScanMode {
  uv(name: 'UV', description: 'Ultraviolet Spectrum'),
  vis(name: 'VIS', description: 'Visible Spectrum'),
  nir(name: 'NIR', description: 'Near-Infrared Spectrum');

  final String name;
  final String description;
  const ScanMode({required this.name, required this.description});
}

enum SafetyStatus {
  safe(name: 'Safe', color: Colors.green, icon: Icons.check_circle_outline_rounded),
  caution(name: 'Caution', color: Colors.amber, icon: Icons.warning_amber_rounded),
  unsafe(name: 'Unsafe', color: Colors.red, icon: Icons.error_outline_rounded);

  final String name;
  final Color color;
  final IconData icon;
  const SafetyStatus({required this.name, required this.color, required this.icon});
}

class ScanResult {
  final String id;
  final DateTime timestamp;
  final ScanMode mode;
  final SafetyStatus status;
  final double confidence;
  final String? imageUrl;
  final List<double> spectralData; // Mock data for graph

  ScanResult({
    required this.id,
    required this.timestamp,
    required this.mode,
    required this.status,
    required this.confidence,
    this.imageUrl,
    required this.spectralData,
  });
}
