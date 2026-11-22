import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:promap_sus/app/config/app_config.dart';
import 'package:promap_sus/core/crypto/chave_local_provider.dart';
import 'package:promap_sus/core/crypto/i_protecao_dados_pessoais.dart';
import 'package:promap_sus/core/crypto/in_memory_protecao_dados_pessoais.dart';
import 'package:promap_sus/core/crypto/protecao_dados_pessoais_adapter.dart';
import 'package:promap_sus/core/errors/failures.dart';
import 'package:promap_sus/core/network/connectivity_monitor.dart';
import 'package:promap_sus/features/cartografia_territorial/adapters/output/infrastructure/gps/location_service_adapter.dart';
import 'package:promap_sus/features/cartografia_territorial/adapters/output/infrastructure/gps/mock_localizacao_service.dart';
import 'package:promap_sus/features/cartografia_territorial/adapters/output/infrastructure/http_api/http_central_server_api_adapter.dart';
import 'package:promap_sus/features/cartografia_territorial/adapters/output/infrastructure/in_memory/in_memory_database.dart';
import 'package:promap_sus/features/cartografia_territorial/adapters/output/infrastructure/local_database/app_database.dart';
import 'package:promap_sus/features/cartografia_territorial/adapters/output/infrastructure/local_database/sqlite_ficha_repository.dart';
import 'package:promap_sus/features/cartografia_territorial/adapters/output/infrastructure/local_database/sqlite_fila_sincronizacao_repository.dart';
import 'package:promap_sus/features/cartografia_territorial/adapters/output/infrastructure/local_mock_api/local_mock_sync_api_adapter.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/services/ial_calculator_service.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/services/sync_daemon_service.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/usecases/calcula_ial_use_case.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/usecases/capturar_localizacao_use_case.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/usecases/listar_fichas_territoriais_use_case.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/usecases/registra_ficha_territorial_use_case.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/usecases/sincronizar_fichas_use_case.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_capturar_localizacao.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_listar_fichas_territoriais.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_registra_ficha_territorial.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/inbound/i_sincronizar_fichas.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_ficha_repository.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_fila_sincronizacao_repository.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_localizacao_service.dart';
import 'package:promap_sus/features/cartografia_territorial/ports/outbound/i_sync_api_adapter.dart';
import 'package:promap_sus/features/prontuario_cidadao/adapters/output/sqlite_consulta_ficha_repository.dart';
import 'package:promap_sus/features/prontuario_cidadao/domain/usecases/consulta_ficha_cidadao_use_case.dart';
import 'package:promap_sus/features/prontuario_cidadao/ports/inbound/i_consulta_ficha_cidadao.dart';
import 'package:promap_sus/features/prontuario_cidadao/ports/outbound/i_consulta_ficha_local_repository.dart';

final GetIt getIt = GetIt.instance;

/// Injeção de dependências seguindo os princípios da Arquitetura Hexagonal.
/// Conecta Adaptadores de Entrada às Portas Inbound, e as Portas Outbound
/// aos Adaptadores de Saída de Infraestrutura.
///
/// [isLocalDev] = true  => simulador [LocalMockSyncApiAdapter] (sem rede externa).
/// [isLocalDev] = false => [HttpCentralServerApiAdapter] (API do SUS).
/// [useInMemory] = true => força uso do [InMemoryDatabase] para testes/visualização.
Future<void> setupDependencies({
  bool isLocalDev = true,
  bool? useInMemory,
}) async {
  // Limpa registros anteriores caso re-inicializado em testes
  await getIt.reset();

  final deveUsarMemoria = useInMemory ?? (kIsWeb || (isLocalDev && !defaultTargetPlatform.isMobile));

  if (deveUsarMemoria) {
    _configurarAdaptadoresMemoria();
  } else {
    try {
      await _configurarAdaptadoresNativos();
    } catch (_) {
      // Fallback gracioso para ambiente de visualização/desenvolvimento
      _configurarAdaptadoresMemoria();
    }
  }

  // Conectividade
  getIt.registerLazySingleton<ConnectivityMonitor>(() => ConnectivityPlusMonitor());

  // Alternância de adaptadores de rede (Outbound)
  if (isLocalDev) {
    getIt.registerLazySingleton<ISyncApiAdapter>(() => LocalMockSyncApiAdapter());
  } else {
    if (AppConfig.apiUrl.isEmpty) {
      throw const ConfiguracaoException(
        'PROMAP_API_URL não definida. Informe --dart-define=PROMAP_API_URL=<url>.',
      );
    }
    getIt.registerLazySingleton<http.Client>(() => http.Client());
    getIt.registerLazySingleton<ISyncApiAdapter>(
      () => HttpCentralServerApiAdapter(
        client: getIt<http.Client>(),
        endpoint: Uri.parse(AppConfig.apiUrl),
      ),
    );
  }

  // Serviços de Domínio
  getIt.registerLazySingleton<IalCalculatorService>(() => const IalCalculatorService());
  getIt.registerLazySingleton<SyncDaemonService>(
    () => SyncDaemonService(
      fila: getIt<IFilaSincronizacaoRepository>(),
      api: getIt<ISyncApiAdapter>(),
      conectividade: getIt<ConnectivityMonitor>(),
    ),
  );

  // Casos de Uso / Portas Inbound (Entrada)
  getIt.registerLazySingleton<CalculaIALUseCase>(
    () => CalculaIALUseCase(getIt<IalCalculatorService>()),
  );
  getIt.registerLazySingleton<IRegistraFichaTerritorial>(
    () => RegistraFichaTerritorialUseCase(
      calculadoraIal: getIt<IalCalculatorService>(),
      repositorio: getIt<IFichaRepository>(),
      protecao: getIt<IProtecaoDadosPessoais>(),
    ),
  );
  getIt.registerLazySingleton<IListarFichasTerritoriais>(
    () => ListarFichasTerritoriaisUseCase(getIt<IFichaRepository>()),
  );
  getIt.registerLazySingleton<ICapturarLocalizacao>(
    () => CapturarLocalizacaoUseCase(getIt<ILocalizacaoService>()),
  );
  getIt.registerLazySingleton<ISincronizarFichas>(
    () => SincronizarFichasUseCase(getIt<SyncDaemonService>()),
  );
  getIt.registerLazySingleton<IConsultaFichaCidadao>(
    () => ConsultaFichaCidadaoUseCase(
      repositorio: getIt<IConsultaFichaLocalRepository>(),
      protecao: getIt<IProtecaoDadosPessoais>(),
    ),
  );
}

void _configurarAdaptadoresMemoria() {
  final inMemoryDb = InMemoryDatabase(preencherDadosDemonstracao: true);
  getIt.registerSingleton<InMemoryDatabase>(inMemoryDb);
  getIt.registerSingleton<IFichaRepository>(inMemoryDb);
  getIt.registerSingleton<IFilaSincronizacaoRepository>(inMemoryDb);
  getIt.registerSingleton<IConsultaFichaLocalRepository>(inMemoryDb);
  getIt.registerSingleton<IProtecaoDadosPessoais>(InMemoryProtecaoDadosPessoais());
  getIt.registerSingleton<ILocalizacaoService>(MockLocalizacaoService());
}

Future<void> _configurarAdaptadoresNativos() async {
  getIt.registerLazySingleton<ChaveLocalProvider>(() => ChaveLocalProvider());
  getIt.registerLazySingleton<IProtecaoDadosPessoais>(
    () => ProtecaoDadosPessoaisAdapter(getIt<ChaveLocalProvider>()),
  );

  final senha = await getIt<ChaveLocalProvider>().senhaBanco();
  final db = await AppDatabase.initEncrypted(AppConfig.nomeBanco, senha: senha);
  getIt.registerSingleton<AppDatabase>(db);

  getIt.registerLazySingleton<IFichaRepository>(
    () => SqliteFichaRepository(db: getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<IFilaSincronizacaoRepository>(
    () => SqliteFilaSincronizacaoRepository(db: getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<IConsultaFichaLocalRepository>(
    () => SqliteConsultaFichaRepository(db: getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<ILocalizacaoService>(() => LocationServiceAdapter());
}

extension on TargetPlatform {
  bool get isMobile => this == TargetPlatform.android || this == TargetPlatform.iOS;
}
