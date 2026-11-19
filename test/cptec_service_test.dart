import 'package:flutter_test/flutter_test.dart';
import 'package:previsao_tempo_cptec/models/cidade.dart';
import 'package:previsao_tempo_cptec/models/previsao_cidade.dart';
import 'package:xml/xml.dart';

void main() {
  group('CPTEC XML Models Tests', () {
    test('Deve realizar o parse correto do XML de busca de cidades', () {
      const xmlString = '''<?xml version='1.0' encoding='ISO-8859-1'?>
<cidades>
  <cidade>
    <nome>São Paulo</nome>
    <uf>SP</uf>
    <id>244</id>
  </cidade>
  <cidade>
    <nome>Campinas</nome>
    <uf>SP</uf>
    <id>1182</id>
  </cidade>
</cidades>''';

      final document = XmlDocument.parse(xmlString);
      final cidades = document.findAllElements('cidade').map((node) => Cidade.fromXml(node)).toList();

      expect(cidades.length, 2);
      expect(cidades[0].id, 244);
      expect(cidades[0].nome, 'São Paulo');
      expect(cidades[0].uf, 'SP');
      expect(cidades[0].nomeFormatado, 'São Paulo - SP');

      expect(cidades[1].id, 1182);
      expect(cidades[1].nome, 'Campinas');
      expect(cidades[1].uf, 'SP');
    });

    test('Deve realizar o parse correto do XML de previsão de 4 dias', () {
      const xmlString = '''<?xml version='1.0' encoding='ISO-8859-1'?>
<cidade>
  <nome>São Paulo</nome>
  <uf>SP</uf>
  <atualizacao>2026-11-18</atualizacao>
  <previsao>
    <dia>2026-11-19</dia>
    <tempo>ci</tempo>
    <maxima>31</maxima>
    <minima>21</minima>
    <iuv>7.5</iuv>
  </previsao>
  <previsao>
    <dia>2026-11-20</dia>
    <tempo>c</tempo>
    <maxima>30</maxima>
    <minima>22</minima>
    <iuv>0.0</iuv>
  </previsao>
  <previsao>
    <dia>2026-11-21</dia>
    <tempo>pc</tempo>
    <maxima>28</maxima>
    <minima>19</minima>
    <iuv>5.0</iuv>
  </previsao>
  <previsao>
    <dia>2026-11-22</dia>
    <tempo>pn</tempo>
    <maxima>26</maxima>
    <minima>18</minima>
    <iuv>8.0</iuv>
  </previsao>
</cidade>''';

      final previsao = PrevisaoCidade.fromXml(244, xmlString);

      expect(previsao.cidadeId, 244);
      expect(previsao.nomeCidade, 'São Paulo');
      expect(previsao.uf, 'SP');
      expect(previsao.dataAtualizacao, '2026-11-18');
      expect(previsao.dias.length, 4);

      // Dia 1
      expect(previsao.dias[0].dia.day, 19);
      expect(previsao.dias[0].tempoSigla, 'ci');
      expect(previsao.dias[0].descricaoTempo, 'Chuvas Isoladas');
      expect(previsao.dias[0].maxima, 31);
      expect(previsao.dias[0].minima, 21);
      expect(previsao.dias[0].iuv, 7.5);

      // Dia 2
      expect(previsao.dias[1].tempoSigla, 'c');
      expect(previsao.dias[1].descricaoTempo, 'Chuva');

      // Dia 3
      expect(previsao.dias[2].tempoSigla, 'pc');
      expect(previsao.dias[2].descricaoTempo, 'Pancadas de Chuva');

      // Dia 4
      expect(previsao.dias[3].tempoSigla, 'pn');
      expect(previsao.dias[3].descricaoTempo, 'Parcialmente Nublado');
    });

    test('Deve lançar PrevisaoNaoEncontradaException quando CPTEC retorna null', () {
      const xmlNull = '''<?xml version='1.0' encoding='ISO-8859-1'?>
<cidade>
  <nome>null</nome>
  <uf>null</uf>
  <atualizacao>null</atualizacao>
  <previsao>
    <dia>null</dia>
    <tempo>null</tempo>
    <maxima>null</maxima>
    <minima>null</minima>
    <iuv>0.0</iuv>
  </previsao>
</cidade>''';

      expect(
        () => PrevisaoCidade.fromXml(99999, xmlNull),
        throwsA(isA<PrevisaoNaoEncontradaException>()),
      );
    });

    test('Deve serializar e deserializar PrevisaoCidade para cache local JSON', () {
      const xmlString = '''<?xml version='1.0' encoding='ISO-8859-1'?>
<cidade>
  <nome>Campinas</nome>
  <uf>SP</uf>
  <atualizacao>2026-11-18</atualizacao>
  <previsao>
    <dia>2026-11-19</dia>
    <tempo>pn</tempo>
    <maxima>29</maxima>
    <minima>18</minima>
    <iuv>6.0</iuv>
  </previsao>
</cidade>''';

      final original = PrevisaoCidade.fromXml(1182, xmlString);
      final jsonMap = original.toJson();
      final restaurada = PrevisaoCidade.fromJson(jsonMap, isOffline: true);

      expect(restaurada.cidadeId, 1182);
      expect(restaurada.nomeCidade, 'Campinas');
      expect(restaurada.uf, 'SP');
      expect(restaurada.isOfflineData, isTrue);
      expect(restaurada.dias.length, 1);
      expect(restaurada.dias.first.maxima, 29);
      expect(restaurada.dias.first.minima, 18);
    });
  });
}
