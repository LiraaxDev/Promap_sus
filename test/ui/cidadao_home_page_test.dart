import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promap_sus/app/di/service_locator.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/nivel_acessibilidade.dart';
import 'package:promap_sus/features/prontuario_cidadao/adapters/input/cidadao_home_page.dart';
import 'package:promap_sus/features/prontuario_cidadao/domain/entities/ficha_territorial_consulta.dart';
import 'package:promap_sus/features/prontuario_cidadao/ports/inbound/i_consulta_ficha_cidadao.dart';

class _FakeConsultaCidadao implements IConsultaFichaCidadao {
  @override
  Future<FichaTerritorialConsulta?> executar(String cpfDigitado) async {
    if (cpfDigitado.contains('999')) return null;
    return FichaTerritorialConsulta(
      valorIal: 15.0,
      nivel: NivelAcessibilidade.verde,
      dataColeta: DateTime.utc(2026, 1, 1),
      latitude: -23.55,
      longitude: -46.63,
    );
  }
}

void main() {
  setUp(() async {
    await setupDependencies(useInMemory: true);
    getIt.unregister<IConsultaFichaCidadao>();
    getIt.registerSingleton<IConsultaFichaCidadao>(_FakeConsultaCidadao());
  });

  testWidgets('CidadaoHomePage permite consultar CPF e exibe a sinaleira', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CidadaoHomePage()));
    await tester.pumpAndSettle();

    expect(find.text('Minha ficha territorial'), findsOneWidget);
    expect(find.text('Informe seu CPF'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '529.982.247-25');
    await tester.tap(find.text('Consultar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Verde'), findsOneWidget);
  });
}
