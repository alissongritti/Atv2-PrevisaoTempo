import 'package:flutter/material.dart';

/// Utilitário responsável pelo mapeamento das siglas de condições meteorológicas
/// fornecidas pela API XML do CPTEC/INPE para descrições legíveis e ícones adequados.
class WeatherConditionHelper {
  static final Map<String, String> _descricoes = {
    'ec': 'Encoberto com Chuvas Isoladas',
    'ci': 'Chuvas Isoladas',
    'c': 'Chuva',
    'in': 'Instável',
    'pp': 'Possibilidade de Pancadas de Chuva',
    'cm': 'Chuva pela Manhã',
    'cn': 'Chuva a Noite',
    'pt': 'Pancadas de Chuva a Tarde',
    'pm': 'Pancadas de Chuva pela Manhã',
    'np': 'Nublado e Pancadas de Chuva',
    'pc': 'Pancadas de Chuva',
    'pn': 'Parcialmente Nublado',
    'cv': 'Chuvisco',
    'ch': 'Chuvoso',
    't': 'Tempestade',
    'ps': 'Predomínio de Sol',
    'e': 'Encoberto',
    'n': 'Nublado',
    'cl': 'Céu Claro',
    'nv': 'Nevoeiro',
    'g': 'Geada',
    'ne': 'Neve',
    'nd': 'Não Definido',
    'pnt': 'Pancadas de Chuva a Noite',
    'psc': 'Possibilidade de Chuva',
    'pcm': 'Possibilidade de Chuva pela Manhã',
    'pct': 'Possibilidade de Chuva a Tarde',
    'pcn': 'Possibilidade de Chuva a Noite',
    'npp': 'Nublado com Possibilidade de Chuva',
    'vn': 'Variação de Nebulosidade',
    'ncm': 'Nublado com Possibilidade de Chuva pela Manhã',
    'npm': 'Nublado com Pancadas pela Manhã',
    'ppt': 'Possibilidade de Pancadas de Chuva a Tarde',
    'ppn': 'Possibilidade de Pancadas de Chuva a Noite',
    'ppm': 'Possibilidade de Pancadas de Chuva pela Manhã',
  };

  /// Retorna a descrição legível para a sigla fornecida.
  static String getDescricao(String? sigla) {
    if (sigla == null || sigla.trim().isEmpty) {
      return 'Condição não informada';
    }
    final cleanSigla = sigla.trim().toLowerCase();
    return _descricoes[cleanSigla] ?? 'Condição: $sigla';
  }

  /// Retorna o ícone do Material correspondente à condição meteorológica.
  static IconData getIcon(String? sigla) {
    if (sigla == null) return Icons.wb_cloudy_rounded;

    final s = sigla.trim().toLowerCase();

    if (s == 'cl' || s == 'ps') {
      return Icons.wb_sunny_rounded;
    } else if (s == 'pn' || s == 'vn') {
      return Icons.wb_cloudy_rounded;
    } else if (s == 'n' || s == 'e') {
      return Icons.cloud_rounded;
    } else if (s == 'cv') {
      return Icons.grain_rounded;
    } else if (s == 'c' || s == 'ch' || s == 'ci' || s == 'cm' || s == 'cn') {
      return Icons.water_drop_rounded;
    } else if (s == 'pc' || s == 'pt' || s == 'pm' || s == 'np' || s == 'pnt' || s == 'npm') {
      return Icons.thunderstorm_rounded;
    } else if (s == 't') {
      return Icons.flash_on_rounded;
    } else if (s == 'nv') {
      return Icons.foggy;
    } else if (s == 'g' || s == 'ne') {
      return Icons.ac_unit_rounded;
    } else if (s.startsWith('p') || s.contains('p')) {
      return Icons.umbrella_rounded;
    } else {
      return Icons.cloud_queue_rounded;
    }
  }

  /// Retorna a cor predominante para o ícone ou cartão
  static Color getColor(String? sigla) {
    if (sigla == null) return Colors.blueGrey;

    final s = sigla.trim().toLowerCase();

    if (s == 'cl' || s == 'ps') {
      return Colors.amber.shade700;
    } else if (s == 'pn' || s == 'vn') {
      return Colors.orange.shade400;
    } else if (s == 'n' || s == 'e') {
      return Colors.blueGrey;
    } else if (s == 'cv' || s == 'ci') {
      return Colors.lightBlue.shade600;
    } else if (s == 'c' || s == 'ch' || s == 'cm' || s == 'cn') {
      return Colors.blue.shade700;
    } else if (s == 'pc' || s == 'pt' || s == 'pm' || s == 'np' || s == 'pnt' || s == 't') {
      return Colors.deepPurple.shade600;
    } else if (s == 'nv') {
      return Colors.grey.shade600;
    } else if (s == 'g' || s == 'ne') {
      return Colors.cyan.shade600;
    } else {
      return Colors.blueGrey;
    }
  }
}
