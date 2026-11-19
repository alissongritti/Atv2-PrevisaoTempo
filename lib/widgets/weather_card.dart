import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/previsao_dia.dart';
import '../utils/weather_condition_helper.dart';
import 'uv_badge.dart';

/// Cartão de exibição da previsão para um dia individual.
class WeatherCard extends StatelessWidget {
  final PrevisaoDia previsao;
  final bool isToday;

  const WeatherCard({
    super.key,
    required this.previsao,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("EEEE, dd/MM/yyyy", 'pt_BR');
    String dataFormatada;
    try {
      dataFormatada = dateFormat.format(previsao.dia);
      // Capitaliza a primeira letra do dia da semana
      dataFormatada = dataFormatada[0].toUpperCase() + dataFormatada.substring(1);
    } catch (_) {
      dataFormatada = DateFormat('dd/MM/yyyy').format(previsao.dia);
    }

    final corCondicao = WeatherConditionHelper.getColor(previsao.tempoSigla);
    final iconeCondicao = WeatherConditionHelper.getIcon(previsao.tempoSigla);

    return Card(
      elevation: isToday ? 3 : 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isToday
            ? BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da data e badge "Hoje"
            Row(
              children: [
                Expanded(
                  child: Text(
                    dataFormatada,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade800,
                    ),
                  ),
                ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Hoje',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 16),
            // Linha principal com ícone, condição do tempo e temperaturas
            Row(
              children: [
                // Ícone da condição com fundo circular suave
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: corCondicao.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconeCondicao,
                    color: corCondicao,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                // Descrição da condição meteorológica
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        previsao.descricaoTempo,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sigla: ${previsao.tempoSigla.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bloco de Temperaturas (Mínima e Máxima)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_upward_rounded, size: 16, color: Colors.deepOrangeAccent),
                        Text(
                          '${previsao.maxima}°C',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrangeAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_downward_rounded, size: 16, color: Colors.blueAccent),
                        Text(
                          '${previsao.minima}°C',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueAccent.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            // Rodapé com o Índice UV (quando disponível)
            if (previsao.iuv != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Índice Ultravioleta:',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  UvBadge(iuv: previsao.iuv),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
