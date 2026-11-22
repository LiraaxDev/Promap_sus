import 'package:flutter/material.dart';
import 'package:promap_sus/app/routes/app_routes.dart';
import 'package:promap_sus/app/routes/sessao_perfil.dart';

class PerfilSelecaoPage extends StatelessWidget {
  const PerfilSelecaoPage({super.key});

  void _entrar(BuildContext context, PerfilUsuario perfil, String rota) {
    SessaoPerfil.atual = perfil;
    Navigator.of(context).pushReplacementNamed(rota);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PROMAP-SUS')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Semantics(
            header: true,
            child: Text('Como deseja acessar?',
                style: Theme.of(context).textTheme.headlineSmall),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => _entrar(context, PerfilUsuario.acs, AppRoutes.acs),
            child: const Text('Agente Comunitária de Saúde (ACS)'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () =>
                _entrar(context, PerfilUsuario.cidadao, AppRoutes.cidadao),
            child: const Text('Cidadão / Pessoa com Deficiência'),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.visualizador),
            label: const Text('Visualizador de Testes & Arquitetura Hexagonal'),
          ),
        ],
      ),
    );
  }
}
