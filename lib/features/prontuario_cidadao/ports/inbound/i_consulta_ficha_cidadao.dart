import 'package:promap_sus/features/prontuario_cidadao/domain/entities/ficha_territorial_consulta.dart';

/// Porta de entrada (inbound) para o cidadão consultar sua ficha territorial.
/// Isola a UI de conhecer algoritmos de hash de CPF ou repositórios locais.
abstract class IConsultaFichaCidadao {
  /// Consulta a última ficha territorial do cidadão a partir do seu CPF bruto.
  /// Valida o CPF, calcula a proteção de dados (hash) e retorna o resultado.
  Future<FichaTerritorialConsulta?> executar(String cpfDigitado);
}
