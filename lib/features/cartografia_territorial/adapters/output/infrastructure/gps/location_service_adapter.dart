import 'package:geolocator/geolocator.dart';
import 'package:promap_sus/core/errors/failures.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/coordenada_gps.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_localizacao_service.dart';

/// Captura de GPS nativo (RF01). Funciona sem internet.
class LocationServiceAdapter implements ILocalizacaoService {
  @override
  Future<CoordenadaGPS> obterPosicaoAtual() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocalizacaoException('GPS desativado no dispositivo.');
    }
    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      throw const LocalizacaoException('Permissão de localização negada.');
    }
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return CoordenadaGPS(pos.latitude, pos.longitude);
  }
}
