import 'package:flutter/material.dart';

/// Tela institucional com detalhes sobre o projeto, disciplina, professor e fontes de dados.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o Aplicativo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_sync_rounded,
                size: 64,
                color: Colors.indigo.shade700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Previsão do Tempo CPTEC/INPE',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const Center(
            child: Text(
              'Versão 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            title: 'Atividade Acadêmica',
            items: [
              const _InfoItem(label: 'Atividade', value: 'Atividade 2 – Previsão do tempo'),
              const _InfoItem(label: 'Disciplina', value: 'Programação para Dispositivos Móveis II'),
              const _InfoItem(label: 'Docente', value: 'Prof. Arley'),
              const _InfoItem(label: 'Instituição', value: 'Faculdade de Tecnologia (Fatec)'),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Tecnologias & Arquitetura',
            items: [
              const _InfoItem(label: 'Framework', value: 'Flutter & Dart (Material 3)'),
              const _InfoItem(label: 'Consumo de Dados', value: 'HTTP Client com suporte a ISO-8859-1'),
              const _InfoItem(label: 'Parser', value: 'XmlDocument (Dart xml package)'),
              const _InfoItem(label: 'Persistência Local', value: 'SharedPreferences (Favoritos, Histórico e Cache Offline)'),
              const _InfoItem(label: 'Visualização Gráfica', value: 'fl_chart (LineChart com curvas de mínimas e máximas)'),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Fonte dos Dados',
            items: [
              const _InfoItem(label: 'Provedor', value: 'CPTEC / INPE'),
              const _InfoItem(label: 'Serviço', value: 'Serviços Web em XML'),
              const _InfoItem(label: 'Localidades', value: 'listaCidades?city={nome}'),
              const _InfoItem(label: 'Previsão 4 Dias', value: 'cidade/{id}/previsao.xml'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<_InfoItem> items}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const Divider(height: 20),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.value,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});
}
