import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/nivel_acessibilidade.dart';

/// Visão somente-leitura da ficha para o Perfil Micro (cidadão/PCD).
/// Reutiliza [NivelAcessibilidade] (núcleo compartilhado entre os módulos).
class FichaTerritorialConsulta {
  const FichaTerritorialConsulta({
    required this.valorIal,
    required this.nivel,
    required this.dataColeta,
    required this.latitude,
    required this.longitude,
  });

  final double valorIal;
  final NivelAcessibilidade nivel;
  final DateTime dataColeta;
  final double latitude;
  final double longitude;
}
