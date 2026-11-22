import 'package:flutter_test/flutter_test.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/entities/ficha_territorial.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/entities/paciente_pcd.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/usecases/listar_fichas_territoriais_use_case.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/coordenada_gps.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/nivel_acessibilidade.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/presenca_escada_rampa.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/tipo_acesso_via.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_ficha_repository.dart';

class _MockFichaRepo implements IFichaRepository {
  final List<FichaTerritorial> lista = [];

  @override
  Future<int> salvarLocamente(PacientePCD p, FichaTerritorial f) async => 1;

  @override
  Future<List<FichaTerritorial>> listarFichas() async => lista;
}

void main() {
  test('ListarFichasTerritoriaisUseCase delega para a porta outbound IFichaRepository', () async {
    final repo = _MockFichaRepo();
    final useCase = ListarFichasTerritoriaisUseCase(repo);

    repo.lista.add(FichaTerritorial(
      idFicha: 10,
      coordenada: CoordenadaGPS(-23.0, -46.0),
      tipoAcessoVia: TipoAcessoVia.pavimentada,
      presencaEscadaRampa: PresencaEscadaRampa.rampa,
      valorIal: 10.0,
      nivel: NivelAcessibilidade.verde,
      dataColeta: DateTime.utc(2026, 1, 1),
    ));

    final res = await useCase.executar();
    expect(res.length, 1);
    expect(res.first.idFicha, 10);
    expect(res.first.nivel, NivelAcessibilidade.verde);
  });
}
