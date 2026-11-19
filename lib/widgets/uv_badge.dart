import 'package:flutter/material.dart';

/// Componente para exibição visual do Índice Ultravioleta (IUV) com classificação de risco OMS.
class UvBadge extends StatelessWidget {
  final double? iuv;

  const UvBadge({super.key, required this.iuv});

  @override
  Widget build(BuildContext context) {
    if (iuv == null) {
      return const SizedBox.shrink();
    }

    final (color, label) = _getClassificacao(iuv!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wb_sunny_outlined, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            'IUV ${iuv!.toStringAsFixed(1)} ($label)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  (Color, String) _getClassificacao(double valor) {
    if (valor <= 2.0) {
      return (Colors.green.shade700, 'Baixo');
    } else if (valor <= 5.0) {
      return (Colors.amber.shade800, 'Moderado');
    } else if (valor <= 7.0) {
      return (Colors.orange.shade800, 'Alto');
    } else if (valor <= 10.0) {
      return (Colors.red.shade700, 'Muito Alto');
    } else {
      return (Colors.purple.shade700, 'Extremo');
    }
  }
}
