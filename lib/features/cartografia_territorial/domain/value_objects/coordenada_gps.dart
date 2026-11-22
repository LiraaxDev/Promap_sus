import 'dart:math' as math;

import 'package:promap_sus/core/errors/failures.dart';

class CoordenadaGPS {
  CoordenadaGPS._(this.latitude, this.longitude);

  factory CoordenadaGPS(double latitude, double longitude) {
    if (!latitude.isFinite || latitude < -90 || latitude > 90) {
      throw const ValidacaoException('Latitude inválida (use -90 a 90).');
    }
    if (!longitude.isFinite || longitude < -180 || longitude > 180) {
      throw const ValidacaoException('Longitude inválida (use -180 a 180).');
    }
    return CoordenadaGPS._(latitude, longitude);
  }

  final double latitude;
  final double longitude;

  /// Distância em linha reta (Haversine), em metros.
  ///
  /// OBS.: é distância geodésica, não distância de trajeto. A especificação
  /// (RF03) fala em "distância física até a UBS" sem definir o método.
  double distanciaEmMetros(CoordenadaGPS outra) {
    const raioTerra = 6371000.0;
    double rad(double g) => g * math.pi / 180;
    final dLat = rad(outra.latitude - latitude);
    final dLon = rad(outra.longitude - longitude);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(latitude)) *
            math.cos(rad(outra.latitude)) *
            math.pow(math.sin(dLon / 2), 2);
    return 2 * raioTerra * math.asin(math.min(1.0, math.sqrt(a)));
  }

  @override
  bool operator ==(Object other) =>
      other is CoordenadaGPS &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}
