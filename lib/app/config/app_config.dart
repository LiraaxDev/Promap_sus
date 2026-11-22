/// Configuração global. Valores via --dart-define:
///   --dart-define=PROMAP_LOCAL_DEV=true|false   (padrão: true => simulador Mock)
///   --dart-define=PROMAP_API_URL=https://...    (obrigatório se LOCAL_DEV=false)
class AppConfig {
  const AppConfig._();

  static const bool isLocalDev =
      bool.fromEnvironment('PROMAP_LOCAL_DEV', defaultValue: true);
  static const String apiUrl = String.fromEnvironment('PROMAP_API_URL');
  static const String nomeBanco = 'sqlite_promap.db';
}
