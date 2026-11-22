import 'package:promap_sus/core/crypto/i_protecao_dados_pessoais.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/cpf.dart';
import 'package:promap_sus/features/prontuario_cidadao/domain/entities/ficha_territorial_consulta.dart';
import 'package:promap_sus/features/prontuario_cidadao/ports/inbound/i_consulta_ficha_cidadao.dart';
import 'package:promap_sus/features/prontuario_cidadao/ports/outbound/i_consulta_ficha_local_repository.dart';

/// Caso de uso da consulta da ficha territorial pelo próprio cidadão.
/// Implementa a porta inbound [IConsultaFichaCidadao] e coordena a validação
/// do CPF, o hash criptográfico com sal/chave local e a busca no repositório outbound.
class ConsultaFichaCidadaoUseCase implements IConsultaFichaCidadao {
  const ConsultaFichaCidadaoUseCase({
    required IConsultaFichaLocalRepository repositorio,
    required IProtecaoDadosPessoais protecao,
  })  : _repositorio = repositorio,
        _protecao = protecao;

  final IConsultaFichaLocalRepository _repositorio;
  final IProtecaoDadosPessoais _protecao;

  @override
  Future<FichaTerritorialConsulta?> executar(String cpfDigitado) async {
    final cpf = Cpf(cpfDigitado);
    final cpfHash = await _protecao.hashCpf(cpf.digitos);
    return _repositorio.ultimaFichaPorCpfHash(cpfHash);
  }
}
