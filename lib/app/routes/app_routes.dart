import 'package:flutter/material.dart';
import 'package:promap_sus/app/config/visualizador_hexagonal_page.dart';
import 'package:promap_sus/app/routes/perfil_selecao_page.dart';
import 'package:promap_sus/app/routes/sessao_perfil.dart';
import 'package:promap_sus/features/cartografia_territorial/adapters/input/ui/pages/acs_home_page.dart';
import 'package:promap_sus/features/prontuario_cidadao/adapters/input/cidadao_home_page.dart';

/// Roteamento com suporte aos perfis do app e ao visualizador de testes/arquitetura.
class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const acs = '/acs';
  static const cidadao = '/cidadao';
  static const visualizador = '/visualizador';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case acs:
        if (SessaoPerfil.atual != PerfilUsuario.acs) return _rota(const PerfilSelecaoPage());
        return _rota(const AcsHomePage());
      case cidadao:
        if (SessaoPerfil.atual != PerfilUsuario.cidadao) return _rota(const PerfilSelecaoPage());
        return _rota(const CidadaoHomePage());
      case visualizador:
        return _rota(const VisualizadorHexagonalPage());
      case home:
      default:
        return _rota(const PerfilSelecaoPage());
    }
  }

  static MaterialPageRoute<void> _rota(Widget page) =>
      MaterialPageRoute<void>(builder: (_) => page);
}
