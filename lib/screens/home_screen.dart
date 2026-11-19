import 'package:flutter/material.dart';
import '../models/cidade.dart';
import '../services/cptec_service.dart';
import '../services/storage_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import 'forecast_screen.dart';
import 'about_screen.dart';

/// Tela inicial de pesquisa de localidades e acesso rápido a favoritos e histórico.
class HomeScreen extends StatefulWidget {
  final CptecService cptecService;
  final StorageService storageService;

  const HomeScreen({
    super.key,
    required this.cptecService,
    required this.storageService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Cidade> _resultados = [];
  List<Cidade> _favoritos = [];
  List<Cidade> _historico = [];

  bool _isLoading = false;
  String? _errorMessage;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosLocais();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _carregarDadosLocais() {
    setState(() {
      _favoritos = widget.storageService.getFavoritos();
      _historico = widget.storageService.getHistorico();
    });
  }

  Future<void> _executarPesquisa(String query) async {
    final termo = query.trim();
    if (termo.isEmpty) {
      setState(() {
        _hasSearched = false;
        _resultados = [];
        _errorMessage = null;
      });
      return;
    }

    // Fecha o teclado
    _searchFocusNode.unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      final cidades = await widget.cptecService.searchCidades(termo);
      setState(() {
        _resultados = cidades;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _abrirPrevisao(Cidade cidade) async {
    // Salva no histórico de buscas locais
    await widget.storageService.salvarHistorico(cidade);
    _carregarDadosLocais();

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ForecastScreen(
          cidade: cidade,
          cptecService: widget.cptecService,
          storageService: widget.storageService,
        ),
      ),
    );

    // Recarrega favoritos e histórico após retorno da tela de detalhes
    if (mounted) {
      _carregarDadosLocais();
    }
  }

  void _limparPesquisa() {
    _searchController.clear();
    setState(() {
      _hasSearched = false;
      _resultados = [];
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.cloud_outlined, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Previsão CPTEC/INPE',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.indigo.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            tooltip: 'Sobre o Aplicativo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de Pesquisa Superior
          _buildSearchBox(),

          // Conteúdo Dinâmico
          Expanded(
            child: _buildBodyContent(),
          ),

          // Rodapé Identificando a Fonte dos Dados (Requisito 3)
          _buildDataSourceFooter(),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade700,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consulte o tempo em cidades brasileiras',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            textInputAction: TextInputAction.search,
            onSubmitted: _executarPesquisa,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Digite o nome da cidade (ex: São Paulo, Campinas)',
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search, color: Colors.indigo),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: _limparPesquisa,
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded, color: Colors.indigo),
                      onPressed: () => _executarPesquisa(_searchController.text),
                    ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (text) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Consultando cidades no CPTEC/INPE...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return ErrorView(
        message: _errorMessage!,
        onRetry: () => _executarPesquisa(_searchController.text),
      );
    }

    if (_hasSearched) {
      if (_resultados.isEmpty) {
        return EmptyState(
          title: 'Nenhuma cidade encontrada',
          message: 'Não encontramos localidades para "${_searchController.text}".\n'
              'Verifique a ortografia ou tente pesquisar sem acentos.',
          icon: Icons.location_off_outlined,
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _resultados.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final cidade = _resultados[index];
          final isFav = widget.storageService.isFavorito(cidade.id);

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigo.shade50,
              child: Text(
                cidade.uf,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.indigo.shade800,
                ),
              ),
            ),
            title: Text(
              cidade.nome,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Text('Estado: ${cidade.uf} • Código: ${cidade.id}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isFav ? Colors.amber.shade700 : Colors.grey,
                  ),
                  tooltip: isFav ? 'Remover dos favoritos' : 'Favoritar cidade',
                  onPressed: () async {
                    await widget.storageService.toggleFavorito(cidade);
                    setState(() {});
                  },
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
            onTap: () => _abrirPrevisao(cidade),
          );
        },
      );
    }

    // Tela Padrão (Favoritos e Histórico)
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_favoritos.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Cidades Favoritas',
            icon: Icons.star_rounded,
            iconColor: Colors.amber.shade700,
          ),
          const SizedBox(height: 8),
          ..._favoritos.map((cidade) => _buildCityCard(cidade, isFavorito: true)),
          const SizedBox(height: 20),
        ],
        if (_historico.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Consultadas Recentemente',
            icon: Icons.history_rounded,
            iconColor: Colors.indigo,
            trailing: TextButton(
              onPressed: () async {
                await widget.storageService.limparHistorico();
                _carregarDadosLocais();
              },
              child: const Text('Limpar', style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(height: 8),
          ..._historico.map((cidade) => _buildCityCard(cidade, isFavorito: widget.storageService.isFavorito(cidade.id))),
        ],
        if (_favoritos.isEmpty && _historico.isEmpty)
          const EmptyState(
            title: 'Pesquise uma cidade',
            message: 'Utilize o campo de busca acima para pesquisar qualquer município brasileiro.',
            icon: Icons.search_rounded,
          ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color iconColor,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildCityCard(Cidade cidade, {required bool isFavorito}) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade50,
          child: Text(
            cidade.uf,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.indigo.shade800,
            ),
          ),
        ),
        title: Text(
          cidade.nome,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('UF: ${cidade.uf} • Código: ${cidade.id}'),
        trailing: IconButton(
          icon: Icon(
            isFavorito ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isFavorito ? Colors.amber.shade700 : Colors.grey,
          ),
          onPressed: () async {
            await widget.storageService.toggleFavorito(cidade);
            _carregarDadosLocais();
          },
        ),
        onTap: () => _abrirPrevisao(cidade),
      ),
    );
  }

  Widget _buildDataSourceFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.grey.shade100,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_outlined, size: 14, color: Colors.blueGrey),
          SizedBox(width: 6),
          Text(
            'Fonte dos dados: CPTEC / INPE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }
}
