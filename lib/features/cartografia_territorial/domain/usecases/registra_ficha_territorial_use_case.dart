import 'package:promap_sus/core/crypto/i_protecao_dados_pessoais.dart';
import 'package:promap_sus/core/errors/failures.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/entities/ficha_territorial.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/entities/paciente_pcd.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/services/ial_calculator_service.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/cpf.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_registra_ficha_territorial.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_ficha_repository.dart';

/// Fluxo da seção 4.2 (diagrama de sequência), passos 2 a 4:
/// valida -> calcula IAL (IalCalculatorService.calcular) -> persiste via
/// IFichaRepository.salvarLocamente (que também enfileira no Outbox).
///
/// Na árvore da seção 5.1 o nome é RegistraFichaTerritorialUseCase; no
/// diagrama de sequência, RegistraFichaUseCase (ver lacuna L-10).
class RegistraFichaTerritorialUseCase implements IRegistraFichaTerritorial {
  RegistraFichaTerritorialUseCase({
    required IalCalculatorService calculadoraIal,
    required IFichaRepository repositorio,
    required IProtecaoDadosPessoais protecao,
    DateTime Function()? agora,
  })  : _ial = calculadoraIal,
        _repositorio = repositorio,
        _protecao = protecao,
        _agora = agora ?? DateTime.now;

  final IalCalculatorService _ial;
  final IFichaRepository _repositorio;
  final IProtecaoDadosPessoais _protecao;
  final DateTime Function() _agora;

  @override
  Future<ResultadoRegistro> executar(RegistraFichaCommand c) async {
    final cpf = Cpf(c.cpf);
    final nome = c.nome.trim();
    if (nome.isEmpty) throw const ValidacaoException('Nome é obrigatório.');

    final resultadoIal = _ial.calcular(
      grauLimitacaoMotora: c.grauLimitacaoMotora,
      distanciaUbsMetros: c.residencia.distanciaEmMetros(c.ubsReferencia),
      tipoAcessoVia: c.tipoAcessoVia,
      presencaEscadaRampa: c.presencaEscadaRampa,
    );

    final paciente = PacientePCD(
      cpfHash: await _protecao.hashCpf(cpf.digitos),
      nomeCriptografado: await _protecao.cifrarNome(nome),
      grauLimitacaoMotora: c.grauLimitacaoMotora,
      dataNascimento: c.dataNascimento,
    );

    final ficha = FichaTerritorial(
      coordenada: c.residencia,
      tipoAcessoVia: c.tipoAcessoVia,
      presencaEscadaRampa: c.presencaEscadaRampa,
      valorIal: resultadoIal.valor,
      nivel: resultadoIal.nivel,
      dataColeta: _agora(),
    );

    final idFicha = await _repositorio.salvarLocamente(paciente, ficha);
    return ResultadoRegistro(idFicha: idFicha, ial: resultadoIal);
  }
}
