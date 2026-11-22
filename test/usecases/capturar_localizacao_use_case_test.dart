import 'package:flutter_test/flutter_test.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/usecases/capturar_localizacao_use_case.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/coordenada_gps.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_localizacao_service.dart';

class _MockGpsService implements ILocalizacaoService {
  _MockGpsService(this.coord);
  final CoordenadaGPS coord;

  @override
  Future<CoordenadaGPS> obterPosicaoAtual() async => coord;
}

void main() {
  test('CapturarLocalizacaoUseCase obtém localização através de ILocalizacaoService', () async {
    final pontoEsperado = CoordenadaGPS(-23.550520, -46.633308);
    final useCase = CapturarLocalizacaoUseCase(_MockGpsService(pontoEsperado));

    final res = await useCase.executar();
    expect(res.latitude, pontoEsperado.latitude);
    expect(res.longitude, pontoEsperado.longitude);
  });
}
