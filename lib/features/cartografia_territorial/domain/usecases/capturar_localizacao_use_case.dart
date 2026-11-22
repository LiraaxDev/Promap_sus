import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/coordenada_gps.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_capturar_localizacao.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_localizacao_service.dart';

/// Caso de uso para obtenção da localização GPS atual da ACS em campo.
/// Implementa a porta de entrada [ICapturarLocalizacao] e consome o serviço outbound [ILocalizacaoService].
class CapturarLocalizacaoUseCase implements ICapturarLocalizacao {
  const CapturarLocalizacaoUseCase(this._localizacaoService);

  final ILocalizacaoService _localizacaoService;

  @override
  Future<CoordenadaGPS> executar() => _localizacaoService.obterPosicaoAtual();
}
