import 'package:promap_sus/features/cartografia_territorial/domain/services/ial_calculator_service.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/coordenada_gps.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/presenca_escada_rampa.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/tipo_acesso_via.dart';

/// Caso de uso "Calcular IAL Local" (UML) - executa offline (RF03).
class CalculaIALUseCase {
  const CalculaIALUseCase(this._servico);

  final IalCalculatorService _servico;

  ResultadoIAL executar({
    required int grauLimitacaoMotora,
    required CoordenadaGPS residencia,
    required CoordenadaGPS ubsReferencia,
    required TipoAcessoVia tipoAcessoVia,
    required PresencaEscadaRampa presencaEscadaRampa,
  }) =>
      _servico.calcular(
        grauLimitacaoMotora: grauLimitacaoMotora,
        distanciaUbsMetros: residencia.distanciaEmMetros(ubsReferencia),
        tipoAcessoVia: tipoAcessoVia,
        presencaEscadaRampa: presencaEscadaRampa,
      );
}
