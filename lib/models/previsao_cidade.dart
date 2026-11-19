import 'package:xml/xml.dart';
import 'previsao_dia.dart';

/// Exceção lançada quando a resposta do CPTEC não contém dados válidos de previsão.
class PrevisaoNaoEncontradaException implements Exception {
  final String message;
  const PrevisaoNaoEncontradaException(this.message);

  @override
  String toString() => message;
}

/// Representa o conjunto completo de previsão para 4 dias de uma cidade.
class PrevisaoCidade {
  final int cidadeId;
  final String nomeCidade;
  final String uf;
  final String dataAtualizacao;
  final List<PrevisaoDia> dias;
  final DateTime dataConsultaLocal;
  final bool isOfflineData;

  const PrevisaoCidade({
    required this.cidadeId,
    required this.nomeCidade,
    required this.uf,
    required this.dataAtualizacao,
    required this.dias,
    required this.dataConsultaLocal,
    this.isOfflineData = false,
  });

  /// Parse do XML retornado por http://servicos.cptec.inpe.br/XML/cidade/{id}/previsao.xml
  factory PrevisaoCidade.fromXml(int cidadeId, String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final cidadeNode = document.findElements('cidade').firstOrNull;

    if (cidadeNode == null) {
      throw const PrevisaoNaoEncontradaException('Formato XML inesperado do serviço CPTEC.');
    }

    final nome = cidadeNode.findElements('nome').firstOrNull?.innerText.trim() ?? '';
    final uf = cidadeNode.findElements('uf').firstOrNull?.innerText.trim() ?? '';
    final atualizacao = cidadeNode.findElements('atualizacao').firstOrNull?.innerText.trim() ?? '';

    // O serviço CPTEC retorna "null" em texto para localidades inválidas ou sem previsão
    if (nome.isEmpty || nome.toLowerCase() == 'null' || atualizacao.toLowerCase() == 'null') {
      throw const PrevisaoNaoEncontradaException('Não há previsão meteorológica disponível para esta localidade no momento.');
    }

    final diasElements = cidadeNode.findElements('previsao');
    final diasList = <PrevisaoDia>[];

    for (final elem in diasElements) {
      final diaStr = elem.findElements('dia').firstOrNull?.innerText.trim();
      // Ignora previsões com dia nulo retornado pelo CPTEC
      if (diaStr == null || diaStr.isEmpty || diaStr.toLowerCase() == 'null') {
        continue;
      }
      diasList.add(PrevisaoDia.fromXml(elem));
    }

    if (diasList.isEmpty) {
      throw const PrevisaoNaoEncontradaException('Nenhum dia de previsão retornado pelo serviço CPTEC.');
    }

    return PrevisaoCidade(
      cidadeId: cidadeId,
      nomeCidade: nome,
      uf: uf.toUpperCase(),
      dataAtualizacao: atualizacao,
      dias: diasList,
      dataConsultaLocal: DateTime.now(),
      isOfflineData: false,
    );
  }

  /// Converte para Map/JSON para persistência local
  Map<String, dynamic> toJson() {
    return {
      'cidadeId': cidadeId,
      'nomeCidade': nomeCidade,
      'uf': uf,
      'dataAtualizacao': dataAtualizacao,
      'dias': dias.map((d) => d.toJson()).toList(),
      'dataConsultaLocal': dataConsultaLocal.toIso8601String(),
    };
  }

  /// Cria a partir de Map/JSON recuperado do cache local
  factory PrevisaoCidade.fromJson(Map<String, dynamic> json, {bool isOffline = true}) {
    return PrevisaoCidade(
      cidadeId: json['cidadeId'] as int? ?? 0,
      nomeCidade: json['nomeCidade'] as String? ?? '',
      uf: json['uf'] as String? ?? '',
      dataAtualizacao: json['dataAtualizacao'] as String? ?? '',
      dias: (json['dias'] as List<dynamic>? ?? [])
          .map((item) => PrevisaoDia.fromJson(item as Map<String, dynamic>))
          .toList(),
      dataConsultaLocal: json['dataConsultaLocal'] != null
          ? DateTime.tryParse(json['dataConsultaLocal'] as String) ?? DateTime.now()
          : DateTime.now(),
      isOfflineData: isOffline,
    );
  }
}
