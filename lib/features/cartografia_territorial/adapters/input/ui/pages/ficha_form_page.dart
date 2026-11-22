import 'package:flutter/material.dart';
import 'package:promap_sus/app/config/sinaleira_visual.dart';
import 'package:promap_sus/app/di/service_locator.dart';
import 'package:promap_sus/features/cartografia_territorial/adapters/input/ui/controllers/ficha_controller.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/presenca_escada_rampa.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/tipo_acesso_via.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_capturar_localizacao.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_listar_fichas_territoriais.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_registra_ficha_territorial.dart';

class FichaFormPage extends StatefulWidget {
  const FichaFormPage({super.key});

  @override
  State<FichaFormPage> createState() => _FichaFormPageState();
}

class _FichaFormPageState extends State<FichaFormPage> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _cpf = TextEditingController();
  final _nascimento = TextEditingController();
  final _ubsLat = TextEditingController();
  final _ubsLon = TextEditingController();

  int _grau = 1;
  TipoAcessoVia _tipoVia = TipoAcessoVia.pavimentada;
  PresencaEscadaRampa _escadaRampa = PresencaEscadaRampa.nenhuma;

  late final FichaController _c = FichaController(
    registra: getIt<IRegistraFichaTerritorial>(),
    capturarLocalizacao: getIt<ICapturarLocalizacao>(),
    listarFichas: getIt<IListarFichasTerritoriais>(),
  );

  @override
  void dispose() {
    for (final t in [_nome, _cpf, _nascimento, _ubsLat, _ubsLon]) {
      t.dispose();
    }
    _c.dispose();
    super.dispose();
  }

  double? _num(String t) => double.tryParse(t.trim().replaceAll(',', '.'));

  String? _obrigatorio(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null;

  String? _coordenada(String? v) => _num(v ?? '') == null ? 'Número inválido' : null;

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    await _c.salvarFicha(
      nome: _nome.text,
      cpf: _cpf.text,
      dataNascimento: _nascimento.text.trim().isEmpty ? null : _nascimento.text.trim(),
      grauLimitacaoMotora: _grau,
      ubsLatitude: _num(_ubsLat.text)!,
      ubsLongitude: _num(_ubsLon.text)!,
      tipoAcessoVia: _tipoVia,
      presencaEscadaRampa: _escadaRampa,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova ficha territorial')),
      body: ListenableBuilder(
        listenable: _c,
        builder: (context, _) {
          final pos = _c.posicaoAtual;
          final res = _c.ultimoResultado;
          return Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nome,
                  decoration: const InputDecoration(labelText: 'Nome completo'),
                  validator: _obrigatorio,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cpf,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'CPF'),
                  validator: _obrigatorio,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nascimento,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                      labelText: 'Data de nascimento (AAAA-MM-DD) - opcional'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _grau,
                  decoration: const InputDecoration(
                      labelText: 'Grau de limitação motora (1 a 5)'),
                  items: [for (var i = 1; i <= 5; i++) DropdownMenuItem(value: i, child: Text('$i'))],
                  onChanged: (v) => setState(() => _grau = v ?? _grau),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TipoAcessoVia>(
                  initialValue: _tipoVia,
                  decoration: const InputDecoration(labelText: 'Tipo de acesso da via'),
                  items: [
                    for (final t in TipoAcessoVia.values)
                      DropdownMenuItem(value: t, child: Text(_rotuloVia(t))),
                  ],
                  onChanged: (v) => setState(() => _tipoVia = v ?? _tipoVia),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<PresencaEscadaRampa>(
                  initialValue: _escadaRampa,
                  decoration: const InputDecoration(labelText: 'Escada / rampa'),
                  items: [
                    for (final t in PresencaEscadaRampa.values)
                      DropdownMenuItem(value: t, child: Text(_rotuloEscada(t))),
                  ],
                  onChanged: (v) => setState(() => _escadaRampa = v ?? _escadaRampa),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ubsLat,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      decoration: const InputDecoration(labelText: 'UBS - latitude'),
                      validator: _coordenada,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _ubsLon,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      decoration: const InputDecoration(labelText: 'UBS - longitude'),
                      validator: _coordenada,
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _c.carregando ? null : _c.capturarGps,
                  style: OutlinedButton.styleFrom(minimumSize: const Size(56, 56)),
                  child: Text(pos == null
                      ? 'Capturar GPS da residência'
                      : 'GPS: ${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}'),
                ),
                const SizedBox(height: 16),
                if (_c.erro != null)
                  Semantics(
                    liveRegion: true,
                    child: Text(_c.erro!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                FilledButton(
                  onPressed: _c.carregando ? null : _salvar,
                  child: Text(_c.carregando ? 'Processando...' : 'Calcular IAL e salvar'),
                ),
                if (res != null) ...[
                  const SizedBox(height: 16),
                  SinaleiraBadge(nivel: res.ial.nivel, valorIal: res.ial.valor),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _rotuloVia(TipoAcessoVia t) => switch (t) {
        TipoAcessoVia.pavimentada => 'Pavimentada',
        TipoAcessoVia.calcadaIrregular => 'Calçada irregular',
        TipoAcessoVia.vielaNaoPavimentada => 'Viela não pavimentada',
        TipoAcessoVia.escadaria => 'Escadaria',
      };

  String _rotuloEscada(PresencaEscadaRampa t) => switch (t) {
        PresencaEscadaRampa.nenhuma => 'Nenhuma',
        PresencaEscadaRampa.rampa => 'Rampa',
        PresencaEscadaRampa.escadaComRampa => 'Escada com rampa alternativa',
        PresencaEscadaRampa.escada => 'Escada',
      };
}
