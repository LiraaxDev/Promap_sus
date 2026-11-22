import 'package:promap_sus/features/cartografia_territorial/domain/services/ial_calculator_service.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/coordenada_gps.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/presenca_escada_rampa.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/tipo_acesso_via.dart';

/// Dados de entrada (em texto/valores brutos) vindos da UI da ACS.
class RegistraFichaCommand {
  const RegistraFichaCommand({
    required this.nome,
    required this.cpf,
    required this.grauLimitacaoMotora,
    this.dataNascimento,
    required this.residencia,
    required this.ubsReferencia,
    required this.tipoAcessoVia,
    required this.presencaEscadaRampa,
  });

  final String nome;
  final String cpf;
  final int grauLimitacaoMotora;
  final String? dataNascimento;
  final CoordenadaGPS residencia;
  final CoordenadaGPS ubsReferencia;
  final TipoAcessoVia tipoAcessoVia;
  final PresencaEscadaRampa presencaEscadaRampa;
}

class ResultadoRegistro {
  const ResultadoRegistro({required this.idFicha, required this.ial});

  final int idFicha;
  final ResultadoIAL ial;
}

/// Porta de entrada chamada pela UI (FichaController).
abstract class IRegistraFichaTerritorial {
  Future<ResultadoRegistro> executar(RegistraFichaCommand comando);
}
