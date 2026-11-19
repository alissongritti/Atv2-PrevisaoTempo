import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/cidade.dart';
import '../models/previsao_cidade.dart';

/// Exceção personalizada para erros de comunicação com a API do CPTEC.
class CptecException implements Exception {
  final String message;
  final dynamic originalError;

  const CptecException(this.message, [this.originalError]);

  @override
  String toString() => message;
}

/// Serviço responsável por interagir com o Web Service XML do CPTEC/INPE.
class CptecService {
  static const String _baseUrl = 'https://servicos.cptec.inpe.br/XML';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  CptecService({http.Client? client}) : _client = client ?? http.Client();

  /// Consulta as cidades correspondentes ao termo informado.
  /// Endpoint: https://servicos.cptec.inpe.br/XML/listaCidades?city={nome}
  Future<List<Cidade>> searchCidades(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return [];
    }

    final url = Uri.parse('$_baseUrl/listaCidades?city=${Uri.encodeQueryComponent(cleanQuery)}');

    try {
      final response = await _client.get(url).timeout(_timeout);

      if (response.statusCode != 200) {
        throw CptecException(
          'O servidor do CPTEC retornou erro HTTP ${response.statusCode}. Tente novamente mais tarde.',
        );
      }

      // O serviço CPTEC/INPE responde utilizando codificação ISO-8859-1 (Latin1)
      final xmlString = latin1.decode(response.bodyBytes);
      final document = XmlDocument.parse(xmlString);

      final cidades = <Cidade>[];
      for (final node in document.findAllElements('cidade')) {
        try {
          cidades.add(Cidade.fromXml(node));
        } catch (_) {
          // Trata eventuais nós corrompidos sem derrubar a lista inteira
        }
      }

      return cidades;
    } on SocketException catch (e) {
      throw CptecException(
        'Sem conexão com a internet. Verifique sua rede e tente novamente.',
        e,
      );
    } on TimeoutException catch (e) {
      throw CptecException(
        'O serviço do CPTEC demorou muito para responder. Tente novamente em instantes.',
        e,
      );
    } on XmlException catch (e) {
      throw CptecException(
        'Resposta inválida do serviço CPTEC/INPE (formato XML inesperado).',
        e,
      );
    } on CptecException {
      rethrow;
    } catch (e) {
      throw CptecException(
        'Não foi possível consultar as cidades: ${e.toString()}',
        e,
      );
    }
  }

  /// Consulta a previsão do tempo para 4 dias para a cidade especificada pelo ID.
  /// Endpoint: https://servicos.cptec.inpe.br/XML/cidade/{id}/previsao.xml
  Future<PrevisaoCidade> getPrevisao4Dias(int cidadeId) async {
    if (cidadeId <= 0) {
      throw const CptecException('Código identificador de cidade inválido.');
    }

    final url = Uri.parse('$_baseUrl/cidade/$cidadeId/previsao.xml');

    try {
      final response = await _client.get(url).timeout(_timeout);

      if (response.statusCode != 200) {
        throw CptecException(
          'Serviço CPTEC indisponível no momento (HTTP ${response.statusCode}).',
        );
      }

      // O serviço CPTEC/INPE responde utilizando codificação ISO-8859-1 (Latin1)
      final xmlString = latin1.decode(response.bodyBytes);
      return PrevisaoCidade.fromXml(cidadeId, xmlString);
    } on SocketException catch (e) {
      throw CptecException(
        'Falha na conexão. Não foi possível carregar a previsão em tempo real.',
        e,
      );
    } on TimeoutException catch (e) {
      throw CptecException(
        'Tempo limite excedido ao consultar o CPTEC. Verifique sua conexão.',
        e,
      );
    } on PrevisaoNaoEncontradaException {
      rethrow;
    } on XmlException catch (e) {
      throw CptecException(
        'Não foi possível interpretar a previsão recebida do CPTEC (XML inválido).',
        e,
      );
    } on CptecException {
      rethrow;
    } catch (e) {
      throw CptecException(
        'Erro inesperado ao consultar previsão: ${e.toString()}',
        e,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
