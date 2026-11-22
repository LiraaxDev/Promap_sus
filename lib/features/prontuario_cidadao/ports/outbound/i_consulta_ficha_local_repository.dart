import 'package:promap_sus/features/prontuario_cidadao/domain/entities/ficha_territorial_consulta.dart';

/// Contrato de consulta local (porta outbound) para o Perfil Cidadão.
abstract class IConsultaFichaLocalRepository {
  /// Ficha mais recente do paciente identificado pelo [cpfHash], ou `null`.
  Future<FichaTerritorialConsulta?> ultimaFichaPorCpfHash(String cpfHash);
}
