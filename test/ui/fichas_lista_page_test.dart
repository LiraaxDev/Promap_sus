import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promap_sus/app/di/service_locator.dart';
import 'package:promap_sus/features/cartografia_territorial/adapters/input/ui/pages/fichas_lista_page.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/entities/ficha_territorial.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/coordenada_gps.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/nivel_acessibilidade.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/presenca_escada_rampa.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/tipo_acesso_via.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_listar_fichas_territoriais.dart';

class _FakeListarFichas implements IListarFichasTerritoriais {
  @override
  Future<List<FichaTerritorial>> executar() async {
    return [
      FichaTerritorial(
        idFicha: 101,
        coordenada: CoordenadaGPS(-23.55, -46.63),
        tipoAcessoVia: TipoAcessoVia.pavimentada,
        presencaEscadaRampa: PresencaEscadaRampa.rampa,
        valorIal: 15.0,
        nivel: NivelAcessibilidade.verde,
        dataColeta: DateTime.utc(2026, 1, 1),
      ),
    ];
  }
}

void main() {
  setUp(() async {
    await setupDependencies(useInMemory: true);
    getIt.unregister<IListarFichasTerritoriais>();
    getIt.registerSingleton<IListarFichasTerritoriais>(_FakeListarFichas());
  });

  testWidgets('FichasListaPage exibe a lista carregada através da porta inbound', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FichasListaPage()));
    await tester.pumpAndSettle();

    expect(find.text('Fichas coletadas'), findsOneWidget);
    expect(find.textContaining('Ficha 101'), findsOneWidget);
    expect(find.textContaining('Verde'), findsOneWidget);
  });
}
