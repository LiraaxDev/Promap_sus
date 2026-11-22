import 'package:flutter_test/flutter_test.dart';
import 'package:promap_sus/core/crypto/i_protecao_dados_pessoais.dart';
import 'package:promap_sus/core/errors/failures.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/entities/ficha_territorial.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/entities/paciente_pcd.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/services/ial_calculator_service.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/usecases/registra_ficha_territorial_use_case.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/coordenada_gps.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/nivel_acessibilidade.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/presenca_escada_rampa.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/tipo_acesso_via.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_registra_ficha_territorial.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_ficha_repository.dart';

class _RepoEmMemoria implements IFichaRepository {
  PacientePCD? paciente;
  FichaTerritorial? ficha;
  int chamadas = 0;

  @override
  Future<int> salvarLocamente(PacientePCD p, FichaTerritorial f) async {
    chamadas++;
    paciente = p;
    ficha = f;
    return 42;
  }

  @override
  Future<List<FichaTerritorial>> listarFichas() async => [if (ficha != null) ficha!];
}

class _ProtecaoFalsa implements IProtecaoDadosPessoais {
  @override
  Future<String> hashCpf(String cpf) async => 'hash:$cpf';
  @override
  Future<String> cifrarNome(String nome) async => 'enc:$nome';
  @override
  Future<String> decifrarNome(String n) async => n.replaceFirst('enc:', '');
}

RegistraFichaCommand _comando({String cpf = '529.982.247-25', String nome = 'Maria'}) =>
    RegistraFichaCommand(
      nome: nome,
      cpf: cpf,
      grauLimitacaoMotora: 5,
      residencia: CoordenadaGPS(-23.0, -47.0),
      ubsReferencia: CoordenadaGPS(-23.0, -47.0),
      tipoAcessoVia: TipoAcessoVia.escadaria,
      presencaEscadaRampa: PresencaEscadaRampa.escada,
    );

void main() {
  late _RepoEmMemoria repo;
  late RegistraFichaTerritorialUseCase useCase;
  final agora = DateTime.utc(2026, 1, 2, 3, 4, 5);

  setUp(() {
    repo = _RepoEmMemoria();
    useCase = RegistraFichaTerritorialUseCase(
      calculadoraIal: const IalCalculatorService(),
      repositorio: repo,
      protecao: _ProtecaoFalsa(),
      agora: () => agora,
    );
  });

  test('calcula IAL, protege dados pessoais e persiste', () async {
    final r = await useCase.executar(_comando());
    expect(r.idFicha, 42);
    expect(repo.paciente!.cpfHash, 'hash:52998224725');
    expect(repo.paciente!.nomeCriptografado, 'enc:Maria');
    expect(repo.ficha!.dataColeta, agora);
    expect(repo.ficha!.nivel, r.ial.nivel);
    expect(repo.ficha!.valorIal, r.ial.valor);
    // grau máx + via escadaria + escada, distância 0: 40 + 0 + 30 = 70 => vermelho
    expect(r.ial.valor, closeTo(70, 0.001));
    expect(r.ial.nivel, NivelAcessibilidade.vermelho);
  });

  test('CPF inválido ou nome vazio não chegam ao repositório', () async {
    await expectLater(useCase.executar(_comando(cpf: '123')), throwsA(isA<ValidacaoException>()));
    await expectLater(useCase.executar(_comando(nome: '  ')), throwsA(isA<ValidacaoException>()));
    expect(repo.chamadas, 0);
  });
}
