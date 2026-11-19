import 'package:xml/xml.dart';
import '../utils/weather_condition_helper.dart';

/// Representa a previsão de um único dia retornada pelo serviço CPTEC/INPE.
class PrevisaoDia {
  final DateTime dia;
  final String tempoSigla;
  final int minima;
  final int maxima;
  final double? iuv;

  const PrevisaoDia({
    required this.dia,
    required this.tempoSigla,
    required this.minima,
    required this.maxima,
    this.iuv,
  });

  /// Descrição textual legível da condição do tempo (ex: "Pancadas de Chuva")
  String get descricaoTempo => WeatherConditionHelper.getDescricao(tempoSigla);

  /// Ícone correspondente à condição meteorológica
  dynamic get icone => WeatherConditionHelper.getIcon(tempoSigla);

  /// Cria uma instância a partir de um elemento XML <previsao>
  factory PrevisaoDia.fromXml(XmlElement element) {
    final diaText = element.findElements('dia').firstOrNull?.innerText.trim() ?? '';
    final dia = DateTime.tryParse(diaText) ?? DateTime.now();

    final tempo = element.findElements('tempo').firstOrNull?.innerText.trim() ?? 'nd';
    final maxText = element.findElements('maxima').firstOrNull?.innerText.trim() ?? '0';
    final minText = element.findElements('minima').firstOrNull?.innerText.trim() ?? '0';
    final iuvText = element.findElements('iuv').firstOrNull?.innerText.trim();

    double? iuvValue;
    if (iuvText != null && iuvText.isNotEmpty && iuvText.toLowerCase() != 'null') {
      iuvValue = double.tryParse(iuvText);
    }

    return PrevisaoDia(
      dia: dia,
      tempoSigla: tempo,
      maxima: int.tryParse(maxText) ?? 0,
      minima: int.tryParse(minText) ?? 0,
      iuv: iuvValue,
    );
  }

  /// Converte para Map/JSON para persistência local
  Map<String, dynamic> toJson() {
    return {
      'dia': dia.toIso8601String(),
      'tempoSigla': tempoSigla,
      'minima': minima,
      'maxima': maxima,
      'iuv': iuv,
    };
  }

  /// Cria a partir de Map/JSON recuperado do cache local
  factory PrevisaoDia.fromJson(Map<String, dynamic> json) {
    return PrevisaoDia(
      dia: DateTime.tryParse(json['dia'] as String? ?? '') ?? DateTime.now(),
      tempoSigla: json['tempoSigla'] as String? ?? 'nd',
      minima: json['minima'] as int? ?? 0,
      maxima: json['maxima'] as int? ?? 0,
      iuv: (json['iuv'] as num?)?.toDouble(),
    );
  }
}
