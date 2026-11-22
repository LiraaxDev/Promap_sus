import 'package:flutter/material.dart';
import 'package:promap_sus/app/config/sinaleira_visual.dart';
import 'package:promap_sus/app/di/service_locator.dart';
import 'package:promap_sus/features/cartografia_territorial/adapters/input/ui/controllers/ficha_controller.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_capturar_localizacao.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_listar_fichas_territoriais.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_registra_ficha_territorial.dart';

class FichasListaPage extends StatefulWidget {
  const FichasListaPage({super.key});

  @override
  State<FichasListaPage> createState() => _FichasListaPageState();
}

class _FichasListaPageState extends State<FichasListaPage> {
  late final FichaController _c = FichaController(
    registra: getIt<IRegistraFichaTerritorial>(),
    capturarLocalizacao: getIt<ICapturarLocalizacao>(),
    listarFichas: getIt<IListarFichasTerritoriais>(),
  )..carregarFichas();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fichas coletadas')),
      body: ListenableBuilder(
        listenable: _c,
        builder: (context, _) {
          if (_c.carregando) return const Center(child: CircularProgressIndicator());
          if (_c.erro != null) return Center(child: Text(_c.erro!));
          if (_c.fichasColetadas.isEmpty) {
            return const Center(child: Text('Nenhuma ficha coletada ainda.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _c.fichasColetadas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final f = _c.fichasColetadas[i];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ficha ${f.idFicha} - ${f.dataColeta.toLocal()}'),
                  const SizedBox(height: 4),
                  SinaleiraBadge(nivel: f.nivel, valorIal: f.valorIal),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
