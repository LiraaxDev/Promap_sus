import 'package:promap_sus/features/cartografia_territorial/domain/entities/ficha_territorial.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_listar_fichas_territoriais.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_ficha_repository.dart';

/// Caso de uso para listar todas as fichas territoriais coletadas localmente.
/// Conecta a porta inbound [IListarFichasTerritoriais] à porta outbound [IFichaRepository].
class ListarFichasTerritoriaisUseCase implements IListarFichasTerritoriais {
  const ListarFichasTerritoriaisUseCase(this._repositorio);

  final IFichaRepository _repositorio;

  @override
  Future<List<FichaTerritorial>> executar() => _repositorio.listarFichas();
}
