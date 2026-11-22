import 'package:flutter/material.dart';
import 'package:promap_sus/app/config/sinaleira_visual.dart';
import 'package:promap_sus/app/di/service_locator.dart';
import 'package:promap_sus/features/prontuario_cidadao/adapters/input/cidadao_controller.dart';
import 'package:promap_sus/features/prontuario_cidadao/ports/inbound/i_consulta_ficha_cidadao.dart';

/// Perfil Micro: ficha territorial e sinaleira da residência.
/// Comunica-se exclusivamente com a porta inbound [IConsultaFichaCidadao].
class CidadaoHomePage extends StatefulWidget {
  const CidadaoHomePage({super.key});

  @override
  State<CidadaoHomePage> createState() => _CidadaoHomePageState();
}

class _CidadaoHomePageState extends State<CidadaoHomePage> {
  final _cpf = TextEditingController();
  late final CidadaoController _c = CidadaoController(
    consulta: getIt<IConsultaFichaCidadao>(),
  );

  @override
  void dispose() {
    _cpf.dispose();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha ficha territorial')),
      body: ListenableBuilder(
        listenable: _c,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _cpf,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Informe seu CPF'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _c.carregando ? null : () => _c.consultar(_cpf.text),
              child: const Text('Consultar'),
            ),
            const SizedBox(height: 16),
            if (_c.erro != null)
              Semantics(
                liveRegion: true,
                child: Text(_c.erro!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            if (_c.ficha != null) ...[
              SinaleiraBadge(nivel: _c.ficha!.nivel, valorIal: _c.ficha!.valorIal),
              const SizedBox(height: 8),
              Text('Coletada em ${_c.ficha!.dataColeta.toLocal()}'),
            ] else if (_c.consultou && _c.erro == null)
              const Text('Nenhuma ficha encontrada neste dispositivo.'),
          ],
        ),
      ),
    );
  }
}
