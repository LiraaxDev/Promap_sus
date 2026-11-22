import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/coordenada_gps.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/nivel_acessibilidade.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/presenca_escada_rampa.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/tipo_acesso_via.dart';

/// Espelha `TB_FICHA_TERRITORIAL`.
class FichaTerritorial {
  const FichaTerritorial({
    this.idFicha,
    this.idPaciente,
    required this.coordenada,
    required this.tipoAcessoVia,
    required this.presencaEscadaRampa,
    required this.valorIal,
    required this.nivel,
    required this.dataColeta,
  });

  final int? idFicha;
  final int? idPaciente;
  final CoordenadaGPS coordenada;
  final TipoAcessoVia tipoAcessoVia;
  final PresencaEscadaRampa presencaEscadaRampa;
  final double valorIal;
  final NivelAcessibilidade nivel;
  final DateTime dataColeta;
}
