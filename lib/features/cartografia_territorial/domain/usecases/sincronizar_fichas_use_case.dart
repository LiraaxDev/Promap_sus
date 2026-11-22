import 'package:promap_sus/features/cartografia_territorial/domain/services/sync_daemon_service.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_sincronizar_fichas.dart';

/// Caso de uso que permite à camada de apresentação disparar a sincronização
/// sob demanda através da porta inbound [ISincronizarFichas].
class SincronizarFichasUseCase implements ISincronizarFichas {
  const SincronizarFichasUseCase(this._syncDaemonService);

  final SyncDaemonService _syncDaemonService;

  @override
  Future<int> executar() => _syncDaemonService.sincronizarPendentes();
}
