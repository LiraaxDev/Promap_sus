import 'package:flutter/material.dart';
import 'package:promap_sus/app/di/service_locator.dart';
import 'package:promap_sus/features/cartografia_territorial/adapters/input/ui/pages/ficha_form_page.dart';
import 'package:promap_sus/features/cartografia_territorial/adapters/input/ui/pages/fichas_lista_page.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_sincronizar_fichas.dart';

/// Tela inicial da ACS (Adaptador de Entrada).
/// Comunica-se com a camada de negócio exclusivamente por portas inbound.
class AcsHomePage extends StatelessWidget {
  const AcsHomePage({super.key});

  Future<void> _sincronizar(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final n = await getIt<ISincronizarFichas>().executar();
      messenger.showSnackBar(SnackBar(content: Text('$n ficha(s) sincronizada(s).')));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Sem conexão: fichas mantidas na fila.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ACS - Cartografia territorial')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const FichaFormPage()),
            ),
            child: const Text('Nova ficha territorial'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const FichasListaPage()),
            ),
            child: const Text('Fichas coletadas'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => _sincronizar(context),
            child: const Text('Sincronizar agora'),
          ),
        ],
      ),
    );
  }
}
