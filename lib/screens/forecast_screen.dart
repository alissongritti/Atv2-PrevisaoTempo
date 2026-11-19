import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cidade.dart';
import '../models/previsao_cidade.dart';
import '../services/cptec_service.dart';
import '../services/storage_service.dart';
import '../widgets/weather_card.dart';
import '../widgets/temperature_chart.dart';
import '../widgets/error_view.dart';

/// Tela de exibição da previsão do tempo de 4 dias, gráficos e detalhes.
class ForecastScreen extends StatefulWidget {
  final Cidade cidade;
  final CptecService cptecService;
  final StorageService storageService;

  const ForecastScreen({
    super.key,
    required this.cidade,
    required this.cptecService,
    required this.storageService,
  });

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  PrevisaoCidade? _previsao;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.storageService.isFavorito(widget.cidade.id);
    _carregarPrevisao();
  }

  /// Carrega a previsão do tempo via API, com fallback automático para cache local.
  Future<void> _carregarPrevisao() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final previsao =
          await widget.cptecService.getPrevisao4Dias(widget.cidade.id);

      // Salva no cache local para persistência offline
      await widget.storageService.salvarCachePrevisao(previsao);

      if (mounted) {
        setState(() {
          _previsao = previsao;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Se houver falha de rede/serviço, tenta recuperar do cache local salvo
      final cache = widget.storageService.getCachePrevisao(widget.cidade.id);

      if (mounted) {
        if (cache != null) {
          setState(() {
            _previsao = cache;
            _isLoading = false;
            _errorMessage = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Sem conexão. Exibindo previsão salva em ${DateFormat("dd/MM 'às' HH:mm").format(cache.dataConsultaLocal)}.'),
              backgroundColor: Colors.orange.shade800,
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          setState(() {
            _errorMessage = e.toString();
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _toggleFavorito() async {
    final novoEstado =
        await widget.storageService.toggleFavorito(widget.cidade);
    setState(() {
      _isFavorite = novoEstado;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          novoEstado
              ? '${widget.cidade.nome} adicionada aos favoritos!'
              : '${widget.cidade.nome} removida dos favoritos.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.cidade.nomeFormatado,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.indigo.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Botão de Favoritar
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _isFavorite ? Colors.amber.shade300 : Colors.white,
            ),
            tooltip:
                _isFavorite ? 'Remover dos favoritos' : 'Favoritar localidade',
            onPressed: _toggleFavorito,
          ),
          // Botão de Atualizar (Requisito 3)
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Atualizar Previsão',
            onPressed: _isLoading ? null : _carregarPrevisao,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Consultando previsão de 4 dias para ${widget.cidade.nome}...',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return ErrorView(
        message: _errorMessage!,
        onRetry: _carregarPrevisao,
      );
    }

    if (_previsao == null || _previsao!.dias.isEmpty) {
      return ErrorView(
        message:
            'Nenhuma previsão disponível para ${widget.cidade.nomeFormatado}.',
        onRetry: _carregarPrevisao,
        icon: Icons.cloud_off_rounded,
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarPrevisao,
      child: ListView(
        padding: EdgeInsets.only(
          bottom: 24 + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          // Banner de Modo Offline se dados vieram do cache
          if (_previsao!.isOfflineData) _buildOfflineBanner(),

          // Card de Cabeçalho com Informações de Atualização
          _buildHeaderCard(),

          // Gráfico de Variação de Temperatura dos 4 Dias (Requisito)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TemperatureChart(dias: _previsao!.dias),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Previsão para os Próximos 4 Dias',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Lista de Cartões com os 4 Dias Retornados
          ..._previsao!.dias.asMap().entries.map((entry) {
            final index = entry.key;
            final dia = entry.value;
            return WeatherCard(
              previsao: dia,
              isToday: index == 0,
            );
          }),

          const SizedBox(height: 16),

          // Identificação do CPTEC/INPE como fonte dos dados (Requisito 3)
          _buildDataSourceCard(),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      color: Colors.amber.shade100,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 18, color: Colors.amber.shade900),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Modo Offline: exibindo dados salvos localmente.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.amber.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    String dataAtualizacaoFormatada;
    try {
      final parsed = DateTime.tryParse(_previsao!.dataAtualizacao);
      if (parsed != null) {
        dataAtualizacaoFormatada = DateFormat('dd/MM/yyyy').format(parsed);
      } else {
        dataAtualizacaoFormatada = _previsao!.dataAtualizacao;
      }
    } catch (_) {
      dataAtualizacaoFormatada = _previsao!.dataAtualizacao;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade600, Colors.indigo.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _previsao!.nomeCidade,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _previsao!.uf,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Código CPTEC: ${_previsao!.cidadeId}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const Divider(color: Colors.white24, height: 20),
          Row(
            children: [
              const Icon(Icons.update_rounded, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Atualização do serviço CPTEC: $dataAtualizacaoFormatada',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                'Consulta local: ${DateFormat("dd/MM/yyyy 'às' HH:mm").format(_previsao!.dataConsultaLocal)}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataSourceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: Colors.grey.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: Colors.blueGrey),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Fonte dos dados: Centro de Previsão de Tempo e Estudos Climáticos (CPTEC / INPE).\n'
                  'Previsão oficial para 4 dias em formato XML.',
                  style: TextStyle(
                      fontSize: 11, color: Colors.blueGrey, height: 1.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
