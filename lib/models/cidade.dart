import 'package:xml/xml.dart';

/// Representa uma localidade/cidade retornada pelo serviço CPTEC/INPE.
class Cidade {
  final int id;
  final String nome;
  final String uf;
  final bool isFavorite;
  final DateTime? lastConsulted;

  const Cidade({
    required this.id,
    required this.nome,
    required this.uf,
    this.isFavorite = false,
    this.lastConsulted,
  });

  /// Nome formatado para exibição amigável: "Cidade - UF"
  String get nomeFormatado => '$nome - $uf';

  /// Cria uma instância a partir de um elemento XML <cidade>
  factory Cidade.fromXml(XmlElement element) {
    final idText = element.findElements('id').firstOrNull?.innerText.trim() ?? '0';
    final nomeText = element.findElements('nome').firstOrNull?.innerText.trim() ?? '';
    final ufText = element.findElements('uf').firstOrNull?.innerText.trim() ?? '';

    return Cidade(
      id: int.tryParse(idText) ?? 0,
      nome: nomeText,
      uf: ufText.toUpperCase(),
    );
  }

  /// Converte para Map/JSON para persistência local (SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'uf': uf,
      'isFavorite': isFavorite,
      'lastConsulted': lastConsulted?.toIso8601String(),
    };
  }

  /// Cria a partir de Map/JSON recuperado da persistência local
  factory Cidade.fromJson(Map<String, dynamic> json) {
    return Cidade(
      id: json['id'] as int? ?? 0,
      nome: json['nome'] as String? ?? '',
      uf: (json['uf'] as String? ?? '').toUpperCase(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      lastConsulted: json['lastConsulted'] != null
          ? DateTime.tryParse(json['lastConsulted'] as String)
          : null,
    );
  }

  Cidade copyWith({
    int? id,
    String? nome,
    String? uf,
    bool? isFavorite,
    DateTime? lastConsulted,
  }) {
    return Cidade(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      uf: uf ?? this.uf,
      isFavorite: isFavorite ?? this.isFavorite,
      lastConsulted: lastConsulted ?? this.lastConsulted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cidade && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Cidade(id: $id, nome: $nome, uf: $uf)';
}
