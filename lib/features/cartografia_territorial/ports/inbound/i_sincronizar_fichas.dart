/// Porta de entrada (inbound) para acionar manualmente ou monitorar a sincronização
/// das fichas pendentes da fila outbox com o servidor central.
abstract class ISincronizarFichas {
  /// Executa a sincronização dos registros pendentes e retorna a quantidade enviada.
  Future<int> executar();
}
