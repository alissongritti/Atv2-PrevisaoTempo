import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:previsao_tempo_cptec/utils/weather_condition_helper.dart';

void main() {
  group('WeatherConditionHelper Tests', () {
    test('Deve mapear siglas oficiais corretamente para suas descrições', () {
      expect(WeatherConditionHelper.getDescricao('ec'), 'Encoberto com Chuvas Isoladas');
      expect(WeatherConditionHelper.getDescricao('ci'), 'Chuvas Isoladas');
      expect(WeatherConditionHelper.getDescricao('c'), 'Chuva');
      expect(WeatherConditionHelper.getDescricao('pc'), 'Pancadas de Chuva');
      expect(WeatherConditionHelper.getDescricao('pn'), 'Parcialmente Nublado');
      expect(WeatherConditionHelper.getDescricao('cv'), 'Chuvisco');
      expect(WeatherConditionHelper.getDescricao('ch'), 'Chuvoso');
      expect(WeatherConditionHelper.getDescricao('t'), 'Tempestade');
      expect(WeatherConditionHelper.getDescricao('ps'), 'Predomínio de Sol');
      expect(WeatherConditionHelper.getDescricao('cl'), 'Céu Claro');
      expect(WeatherConditionHelper.getDescricao('n'), 'Nublado');
      expect(WeatherConditionHelper.getDescricao('nv'), 'Nevoeiro');
      expect(WeatherConditionHelper.getDescricao('g'), 'Geada');
      expect(WeatherConditionHelper.getDescricao('ne'), 'Neve');
    });

    test('Deve ser tolerante a espaços e maiúsculas/minúsculas', () {
      expect(WeatherConditionHelper.getDescricao(' PC '), 'Pancadas de Chuva');
      expect(WeatherConditionHelper.getDescricao('Pn'), 'Parcialmente Nublado');
      expect(WeatherConditionHelper.getDescricao('CI'), 'Chuvas Isoladas');
    });

    test('Deve retornar fallback amigável quando a sigla for nula ou desconhecida', () {
      expect(WeatherConditionHelper.getDescricao(null), 'Condição não informada');
      expect(WeatherConditionHelper.getDescricao(''), 'Condição não informada');
      expect(WeatherConditionHelper.getDescricao('xyz'), 'Condição: xyz');
    });

    test('Deve retornar ícones adequados para cada condição', () {
      expect(WeatherConditionHelper.getIcon('cl'), Icons.wb_sunny_rounded);
      expect(WeatherConditionHelper.getIcon('pn'), Icons.wb_cloudy_rounded);
      expect(WeatherConditionHelper.getIcon('c'), Icons.water_drop_rounded);
      expect(WeatherConditionHelper.getIcon('pc'), Icons.thunderstorm_rounded);
      expect(WeatherConditionHelper.getIcon('t'), Icons.flash_on_rounded);
      expect(WeatherConditionHelper.getIcon(null), Icons.wb_cloudy_rounded);
    });
  });
}
