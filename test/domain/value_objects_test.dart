import 'package:flutter_test/flutter_test.dart';
import 'package:promap_sus/core/errors/failures.dart';
import 'package:promap_sus/core/crypto/integridade.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/coordenada_gps.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/cpf.dart';

void main() {
  group('Cpf', () {
    test('aceita CPF válido com ou sem máscara', () {
      expect(Cpf('529.982.247-25').digitos, '52998224725');
      expect(Cpf('52998224725').digitos, '52998224725');
    });
    test('rejeita dígito verificador errado, repetidos e tamanho', () {
      expect(() => Cpf('529.982.247-24'), throwsA(isA<ValidacaoException>()));
      expect(() => Cpf('11111111111'), throwsA(isA<ValidacaoException>()));
      expect(() => Cpf('123'), throwsA(isA<ValidacaoException>()));
    });
  });

  group('CoordenadaGPS', () {
    test('valida limites', () {
      expect(() => CoordenadaGPS(91, 0), throwsA(isA<ValidacaoException>()));
      expect(() => CoordenadaGPS(0, 181), throwsA(isA<ValidacaoException>()));
    });
    test('Haversine: 0,001 grau de latitude ~ 111 m', () {
      final d = CoordenadaGPS(-23.0, -47.0).distanciaEmMetros(CoordenadaGPS(-23.001, -47.0));
      expect(d, inInclusiveRange(110, 112));
    });
    test('distância para o mesmo ponto é zero', () {
      final p = CoordenadaGPS(-23.2, -47.6);
      expect(p.distanciaEmMetros(p), 0);
    });
  });

  test('sha256Hex produz o vetor de teste conhecido', () {
    expect(
      sha256Hex('abc'),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
  });
}
