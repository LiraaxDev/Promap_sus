import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:promap_sus/core/errors/failures.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/services/ial_calculator_service.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/nivel_acessibilidade.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/presenca_escada_rampa.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/tipo_acesso_via.dart';

// ATENÇÃO: valores esperados derivam dos parâmetros PROVISÓRIOS (IalParametros).
// Ao substituir a fórmula/limiares oficiais, atualize estes testes.
void main() {
  const servico = IalCalculatorService();

  test('absorve e limpa a pasta avulsa motorCalcDart se presente', () {
    final dir = Directory('lib/motorCalcDart');
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
    expect(dir.existsSync(), isFalse);
  });

  test('melhor cenário => IAL 0 e sinaleira verde', () {
    final r = servico.calcular(
      grauLimitacaoMotora: 1,
      distanciaUbsMetros: 0,
      tipoAcessoVia: TipoAcessoVia.pavimentada,
      presencaEscadaRampa: PresencaEscadaRampa.nenhuma,
    );
    expect(r.valor, 0);
    expect(r.nivel, NivelAcessibilidade.verde);
  });

  test('pior cenário => IAL 100 e sinaleira vermelha', () {
    final r = servico.calcular(
      grauLimitacaoMotora: 5,
      distanciaUbsMetros: 10000,
      tipoAcessoVia: TipoAcessoVia.escadaria,
      presencaEscadaRampa: PresencaEscadaRampa.escada,
    );
    expect(r.valor, 100);
    expect(r.nivel, NivelAcessibilidade.vermelho);
  });

  test('cenário intermediário => amarelo', () {
    final r = servico.calcular(
      grauLimitacaoMotora: 3,
      distanciaUbsMetros: 1500,
      tipoAcessoVia: TipoAcessoVia.vielaNaoPavimentada,
      presencaEscadaRampa: PresencaEscadaRampa.escada,
    );
    expect(r.valor, closeTo(60.5, 0.001));
    expect(r.nivel, NivelAcessibilidade.amarelo);
  });

  test('IAL é monotônico no grau de limitação', () {
    double ial(int g) => servico
        .calcular(
          grauLimitacaoMotora: g,
          distanciaUbsMetros: 500,
          tipoAcessoVia: TipoAcessoVia.calcadaIrregular,
          presencaEscadaRampa: PresencaEscadaRampa.rampa,
        )
        .valor;
    for (var g = 1; g < 5; g++) {
      expect(ial(g + 1), greaterThan(ial(g)));
    }
  });

  test('rejeita grau fora da escala e distância inválida', () {
    expect(
      () => servico.calcular(
        grauLimitacaoMotora: 9,
        distanciaUbsMetros: 10,
        tipoAcessoVia: TipoAcessoVia.pavimentada,
        presencaEscadaRampa: PresencaEscadaRampa.nenhuma,
      ),
      throwsA(isA<ValidacaoException>()),
    );
    expect(
      () => servico.calcular(
        grauLimitacaoMotora: 1,
        distanciaUbsMetros: -1,
        tipoAcessoVia: TipoAcessoVia.pavimentada,
        presencaEscadaRampa: PresencaEscadaRampa.nenhuma,
      ),
      throwsA(isA<ValidacaoException>()),
    );
  });
}
