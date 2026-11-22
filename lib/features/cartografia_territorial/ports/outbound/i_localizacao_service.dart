import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/coordenada_gps.dart';

abstract class ILocalizacaoService {
  /// Lê a posição atual via GPS nativo (RF01).
  /// Lança [LocalizacaoException] se o serviço/permissão estiver indisponível.
  Future<CoordenadaGPS> obterPosicaoAtual();
}
