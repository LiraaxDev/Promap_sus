import 'package:promap_sus/features/cartografia_territorial/domain/entities/ficha_territorial.dart';

/// Porta de entrada (inbound) para listagem de fichas territoriais coletadas.
/// Isola os adaptadores de entrada (UI) do repositório de saída.
abstract class IListarFichasTerritoriais {
  Future<List<FichaTerritorial>> executar();
}
