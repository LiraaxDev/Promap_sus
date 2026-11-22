import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promap_sus/app/di/service_locator.dart';
import 'package:promap_sus/features/cartografia_territorial/adapters/input/ui/pages/acs_home_page.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_sincronizar_fichas.dart';

class _FakeSincronizarFichas implements ISincronizarFichas {
  @override
  Future<int> executar() async => 3;
}

void main() {
  setUp(() async {
    await setupDependencies(useInMemory: true);
    getIt.unregister<ISincronizarFichas>();
    getIt.registerSingleton<ISincronizarFichas>(_FakeSincronizarFichas());
  });

  testWidgets('AcsHomePage exibe opções de nova ficha, lista e sincronizar', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AcsHomePage()));
    await tester.pumpAndSettle();

    expect(find.text('ACS - Cartografia territorial'), findsOneWidget);
    expect(find.text('Nova ficha territorial'), findsOneWidget);
    expect(find.text('Fichas coletadas'), findsOneWidget);
    expect(find.text('Sincronizar agora'), findsOneWidget);

    await tester.tap(find.text('Sincronizar agora'));
    await tester.pumpAndSettle();

    expect(find.text('3 ficha(s) sincronizada(s).'), findsOneWidget);
  });
}
