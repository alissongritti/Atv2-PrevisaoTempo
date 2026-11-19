import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cidade.dart';
import '../models/previsao_cidade.dart';

/// Serviço responsável pela persistência local dos dados utilizando SharedPreferences.
///
/// Estratégia de Persistência:
/// 1. Cidades Favoritas: lista de localidades marcadas com estrela para acesso rápido na tela inicial.
/// 2. Histórico de Buscas: últimas cidades consultadas para agilidade na navegação.
/// 3. Cache de Previsões: armazena a última previsão obtida por ID de localidade, permitindo
///    visualização offline em caso de falha de conexão ou indisponibilidade da API do CPTEC.
class StorageService {
  static const String _keyFavoritos = 'cptec_cidades_favoritas';
  static const String _keyHistorico = 'cptec_historico_consultas';
  static const String _prefixCachePrevisao = 'cptec_cache_previsao_';
  static const int _maxHistorico = 10;

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  /// Cria uma instância inicializando o SharedPreferences assincronamente.
  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // ==========================================
  // Cidades Favoritas
  // ==========================================

  /// Retorna a lista de cidades favoritas salvas localmente.
  List<Cidade> getFavoritos() {
    final rawList = _prefs.getStringList(_keyFavoritos) ?? [];
    return rawList.map((item) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        return Cidade.fromJson(map).copyWith(isFavorite: true);
      } catch (_) {
        return null;
      }
    }).whereType<Cidade>().toList();
  }

  /// Verifica se uma cidade está favoritada.
  bool isFavorito(int cidadeId) {
    final favoritos = getFavoritos();
    return favoritos.any((c) => c.id == cidadeId);
  }

  /// Adiciona ou remove uma cidade dos favoritos (toggle).
  Future<bool> toggleFavorito(Cidade cidade) async {
    final favoritos = getFavoritos();
    final index = favoritos.indexWhere((c) => c.id == cidade.id);

    if (index >= 0) {
      favoritos.removeAt(index);
      await _salvarListaFavoritos(favoritos);
      return false; // agora não é favorito
    } else {
      favoritos.add(cidade.copyWith(isFavorite: true));
      await _salvarListaFavoritos(favoritos);
      return true; // agora é favorito
    }
  }

  Future<void> _salvarListaFavoritos(List<Cidade> favoritos) async {
    final encoded = favoritos.map((c) => jsonEncode(c.toJson())).toList();
    await _prefs.setStringList(_keyFavoritos, encoded);
  }

  // ==========================================
  // Histórico de Consultas Recentes
  // ==========================================

  /// Retorna as cidades recentemente consultadas (mais recente primeiro).
  List<Cidade> getHistorico() {
    final rawList = _prefs.getStringList(_keyHistorico) ?? [];
    return rawList.map((item) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        return Cidade.fromJson(map);
      } catch (_) {
        return null;
      }
    }).whereType<Cidade>().toList();
  }

  /// Registra uma cidade no histórico recente (com limite e sem duplicatas).
  Future<void> salvarHistorico(Cidade cidade) async {
    final historico = getHistorico();
    historico.removeWhere((c) => c.id == cidade.id);
    historico.insert(0, cidade.copyWith(lastConsulted: DateTime.now()));

    if (historico.length > _maxHistorico) {
      historico.removeRange(_maxHistorico, historico.length);
    }

    final encoded = historico.map((c) => jsonEncode(c.toJson())).toList();
    await _prefs.setStringList(_keyHistorico, encoded);
  }

  /// Limpa o histórico de consultas.
  Future<void> limparHistorico() async {
    await _prefs.remove(_keyHistorico);
  }

  // ==========================================
  // Cache Offline de Previsão do Tempo
  // ==========================================

  /// Salva a previsão de 4 dias no cache local para a cidade.
  Future<void> salvarCachePrevisao(PrevisaoCidade previsao) async {
    final key = '$_prefixCachePrevisao${previsao.cidadeId}';
    final jsonStr = jsonEncode(previsao.toJson());
    await _prefs.setString(key, jsonStr);
  }

  /// Recupera a previsão do tempo do cache local (se disponível).
  PrevisaoCidade? getCachePrevisao(int cidadeId) {
    final key = '$_prefixCachePrevisao$cidadeId';
    final jsonStr = _prefs.getString(key);
    if (jsonStr == null || jsonStr.isEmpty) return null;

    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return PrevisaoCidade.fromJson(map, isOffline: true);
    } catch (_) {
      return null;
    }
  }

  /// Remove o cache de uma cidade específica.
  Future<void> limparCacheCidade(int cidadeId) async {
    final key = '$_prefixCachePrevisao$cidadeId';
    await _prefs.remove(key);
  }
}
