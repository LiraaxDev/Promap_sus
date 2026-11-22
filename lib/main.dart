import 'package:flutter/material.dart';
import 'package:promap_sus/app/config/app_config.dart';
import 'package:promap_sus/app/config/app_theme.dart';
import 'package:promap_sus/app/di/service_locator.dart';
import 'package:promap_sus/app/routes/app_routes.dart';
import 'package:promap_sus/features/cartografia_territorial/domain/services/sync_daemon_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies(isLocalDev: AppConfig.isLocalDev);
  getIt<SyncDaemonService>().iniciar();
  runApp(const PromapApp());
}

class PromapApp extends StatelessWidget {
  const PromapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PROMAP-SUS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro(),
      highContrastTheme: AppTheme.altoContraste(),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
