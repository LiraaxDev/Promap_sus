import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promap_sus/app/di/service_locator.dart';
import 'package:promap_sus/app/routes/app_routes.dart';
import 'package:promap_sus/app/routes/perfil_selecao_page.dart';

void main() {
  setUp(() async {
    await setupDependencies(useInMemory: true);
  });

  testWidgets('PerfilSelecaoPage renderiza opções de perfil e atalho do visualizador', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: PerfilSelecaoPage(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('PROMAP-SUS'), findsOneWidget);
    expect(find.text('Agente Comunitária de Saúde (ACS)'), findsOneWidget);
    expect(find.text('Cidadão / Pessoa com Deficiência'), findsOneWidget);
    expect(find.text('Visualizador de Testes & Arquitetura Hexagonal'), findsOneWidget);
  });
}
