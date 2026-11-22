import 'package:flutter_test/flutter_test.dart';
import 'package:promap_sus/core/crypto/i_protecao_dados_pessoais.dart';
import 'package:promap_sus/core/errors/failures.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/nivel_acessibilidade.dart';
import 'package:promap_sus/features/prontuario_cidadao/domain/entities/ficha_territorial_consulta.dart';
import 'package:promap_sus/features/prontuario_cidadao/domain/usecases/consulta_ficha_cidadao_use_case.dart';
import 'package:promap_sus/features/prontuario_cidadao/ports/outbound/i_consulta_ficha_local_repository.dart';

class _ConsultaRepoMock implements IConsultaFichaLocalRepository {
  String? ultimoHashBuscado;
  FichaTerritorialConsulta? retorno;

  @override
  Future<FichaTerritorialConsulta?> ultimaFichaPorCpfHash(String cpfHash) async {
    ultimoHashBuscado = cpfHash;
    return retorno;
  }
}

class _ProtecaoSimples implements IProtecaoDadosPessoais {
  @override
  Future<String> hashCpf(String cpf) async => 'hash_de_$cpf';
  @override
  Future<String> cifrarNome(String nome) async => nome;
  @override
  Future<String> decifrarNome(String n) async => n;
}

void main() {
  test('ConsultaFichaCidadaoUseCase valida CPF, aplica hash e busca no repositório', () async {
    final repo = _ConsultaRepoMock();
    final fichaEsperada = FichaTerritorialConsulta(
      valorIal: 25.0,
      nivel: NivelAcessibilidade.verde,
      dataColeta: DateTime.utc(2026, 1, 1),
      latitude: -23.55,
      longitude: -46.63,
    );
    repo.retorno = fichaEsperada;

    final useCase = ConsultaFichaCidadaoUseCase(
      repositorio: repo,
      protecao: _ProtecaoSimples(),
    );

    final resultado = await useCase.executar('529.982.247-25');

    expect(resultado, isNotNull);
    expect(resultado!.valorIal, 25.0);
    expect(resultado.nivel, NivelAcessibilidade.verde);
    expect(repo.ultimoHashBuscado, 'hash_de_52998224725');
  });

  test('ConsultaFichaCidadaoUseCase rejeita CPF inválido com ValidacaoException', () async {
    final repo = _ConsultaRepoMock();
    final useCase = ConsultaFichaCidadaoUseCase(
      repositorio: repo,
      protecao: _ProtecaoSimples(),
    );

    expect(
      () => useCase.executar('111.111.111-11'),
      throwsA(isA<ValidacaoException>()),
    );
    expect(repo.ultimoHashBuscado, isNull);
  });
}
