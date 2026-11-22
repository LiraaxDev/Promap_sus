import 'package:promap_sus/features/cartografia_territorial/domain/value_objects/coordenada_gps.dart';

/// Porta de entrada (inbound) para captura de coordenadas GPS atuais.
/// Isola a UI de conhecer adaptadores de infraestrutura ou portas de saída diretamente.
abstract class ICapturarLocalizacao {
  Future<CoordenadaGPS> executar();
}
