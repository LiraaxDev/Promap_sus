import 'package:promap_sus/features/cartografia_territorial/domain/entities/ficha_territorial.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/entities/paciente_pcd.dart';

abstract class IFichaRepository {
  /// Grava paciente + ficha + item do Outbox na MESMA transação local
  /// (Transactional Outbox, seção 5.3). Retorna o `id_ficha` gerado.
  Future<int> salvarLocamente(PacientePCD paciente, FichaTerritorial ficha);

  Future<List<FichaTerritorial>> listarFichas();
}
