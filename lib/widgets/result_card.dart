import 'package:flutter/material.dart';
import '../models/scan_models.dart';

class ResultCard extends StatelessWidget {
  final ScanResult result;

  const ResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Column(
          children: [
            // Traffic Light Indicator Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              color: result.status.color.withOpacity(0.15),
              child: Row(
                children: [
                  _buildTrafficLight(context, result.status),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SAFETY ASSESSMENT',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            color: result.status.color.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          result.status.name.toUpperCase(),
                          style: TextStyle(
                            color: result.status.color,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(result.status.icon, color: result.status.color, size: 28),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetric('Confidence', '${(result.confidence * 100).toStringAsFixed(1)}%'),
                      _buildMetric('Mode', result.mode.name),
                      _buildMetric('Timestamp', _formatTime(result.timestamp)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'SPECTRAL SIGNATURE',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 100,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CustomPaint(
                      painter: _SpectralPainter(
                        data: result.spectralData,
                        color: result.status.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: result.status.color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('VIEW DETAILED ANALYSIS'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrafficLight(BuildContext context, SafetyStatus status) {
    return Column(
      children: [
        _lightCircle(Colors.red, status == SafetyStatus.unsafe),
        const SizedBox(height: 4),
        _lightCircle(Colors.amber, status == SafetyStatus.caution),
        const SizedBox(height: 4),
        _lightCircle(Colors.green, status == SafetyStatus.safe),
      ],
    );
  }

  Widget _lightCircle(Color color, bool isActive) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? color : color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _SpectralPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _SpectralPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final step = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * step;
      final y = size.height - (data[i] * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Area under the curve
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final areaPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(areaPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
