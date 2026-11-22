import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/coordenada_gps.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_localizacao_service.dart';

/// Adaptador simulado de GPS para testes automatizados, visualização web e desktop.
/// Não depende de hardware nem de permissões de plataforma do dispositivo.
class MockLocalizacaoService implements ILocalizacaoService {
  MockLocalizacaoService({
    CoordenadaGPS? coordenadaInicial,
  }) : _coordenada = coordenadaInicial ?? CoordenadaGPS(-23.550520, -46.633308);

  CoordenadaGPS _coordenada;

  void definirCoordenada(CoordenadaGPS novaCoordenada) {
    _coordenada = novaCoordenada;
  }

  @override
  Future<CoordenadaGPS> obterPosicaoAtual() async {
    // Simula uma pequena latência realista de leitura de satélite
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _coordenada;
  }
}
