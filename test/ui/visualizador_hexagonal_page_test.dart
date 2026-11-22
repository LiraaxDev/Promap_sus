import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promap_sus/app/config/visualizador_hexagonal_page.dart';
import 'package:promap_sus/app/di/service_locator.dart';

void main() {
  setUp(() async {
    await setupDependencies(useInMemory: true);
  });

  testWidgets('VisualizadorHexagonalPage renderiza abas e permite testar portas inbound', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: VisualizadorHexagonalPage()));
    await tester.pumpAndSettle();

    // Verifica que as abas estão visíveis
    expect(find.text('Camadas'), findsOneWidget);
    expect(find.text('Testar Portas'), findsOneWidget);
    expect(find.text('UI / Sinaleira'), findsOneWidget);

    // Aba Camadas
    expect(find.textContaining('Isolamento de Camadas'), findsOneWidget);
    expect(find.textContaining('1. Domínio Central'), findsOneWidget);

    // Muda para a aba de Testar Portas
    await tester.tap(find.text('Testar Portas'));
    await tester.pumpAndSettle();

    expect(find.text('Registrar Ficha (Verde)'), findsOneWidget);
    expect(find.text('Listar Fichas'), findsOneWidget);
    expect(find.text('Capturar GPS'), findsOneWidget);

    // Clica no botão de registrar ficha verde
    await tester.tap(find.text('Registrar Ficha (Verde)'));
    await tester.pumpAndSettle();

    // Verifica se gerou o log no console de execução
    expect(find.textContaining('Sucesso [IRegistraFichaTerritorial]'), findsOneWidget);

    // Muda para a aba UI / Sinaleira
    await tester.tap(find.text('UI / Sinaleira'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Galeria de Componentes: Sinaleira Visual'), findsOneWidget);
    expect(find.textContaining('Nível Verde'), findsOneWidget);
    expect(find.textContaining('Nível Amarelo'), findsOneWidget);
    expect(find.textContaining('Nível Vermelho'), findsOneWidget);
  });
}
