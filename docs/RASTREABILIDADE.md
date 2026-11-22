# Rastreabilidade: requisitos × implementação

Legenda: ✅ implementado · 🟡 parcial / provisório · ⛔ não implementado (fora do escopo ou sem especificação suficiente).
Nenhum item foi executado em dispositivo/emulador (ver README).

| Requisito | Situação | Onde |
|---|---|---|
| **RF01** Cadastro e mapeamento em campo (GPS + entorno) | 🟡 GPS, tipo de via e escada/rampa; largura de viela e iluminação sem coluna no DER (L-04) | `adapters/input/ui/pages/ficha_form_page.dart`, `gps/location_service_adapter.dart`, `registra_ficha_territorial_use_case.dart` |
| **RF02** Sinaleira verde/amarelo/vermelho | 🟡 funciona; limiares provisórios (L-03) | `nivel_acessibilidade.dart`, `ial_calculator_service.dart`, `app/config/sinaleira_visual.dart` |
| **RF03** IAL embarcado offline | 🟡 funciona offline; fórmula provisória (L-01) | `ial_calculator_service.dart`, `ial_parametros.dart`, `calcula_ial_use_case.dart` |
| **RF04** Referência/contrarreferência | ⛔ sem esquema (L-07) | — |
| **RF05** Painel analítico web | ⛔ servidor/web (L-13) | — |
| **RNF01** Offline-first | ✅ cadastro, consulta e cálculo 100% locais; sincronização assíncrona | `sqlite_ficha_repository.dart`, `sync_daemon_service.dart` |
| **RNF02** AES-256 (SQLCipher), TLS 1.3, RBAC | 🟡 SQLCipher + chaves no armazenamento seguro ✅; TLS 1.3 não forçável em Dart (L-12); RBAC só esboçado (L-08) | `app_database.dart`, `core/crypto/*`, `app/routes/*` |
| **RNF03** Portas e adaptadores / Mocks | ✅ | `ports/`, `local_mock_sync_api_adapter.dart`, `app/di/service_locator.dart`; testes com fakes em `test/` |
| **RNF04** WCAG 2.1 / e-MAG | 🟡 áreas de toque ≥ 56 dp, alto contraste via SO, escala de fonte do SO, `Semantics`, sinaleira com texto além de cor. Não houve auditoria com TalkBack/VoiceOver. | `app/config/app_theme.dart`, `sinaleira_visual.dart`, páginas |
| Outbox transacional (5.3.1) | ✅ | `SqliteFichaRepository.salvarLocamente` |
| Serviço de sync + SHA-256 (5.3.2) | ✅ | `SyncDaemonService`, `core/crypto/integridade.dart` |
| Idempotência no servidor (5.3.3) | ⛔ lado servidor; contrato indefinido (L-11) | — |
| Perfil Cidadão: ficha + sinaleira | 🟡 consulta local por CPF; sem pontos de apoio nem encaminhamentos (L-06, L-07) | `features/prontuario_cidadao/*` |
| DI com alternância Mock/produção (5.2) | ✅ | `app/di/service_locator.dart` |

## Testes incluídos (`test/`)

- IAL: limites, monotonicidade, validações, cores.
- CPF, coordenada (Haversine) e SHA-256 (vetor conhecido).
- Caso de uso de registro (repositório e criptografia falsos).
- `SyncDaemonService`: sucesso, falha preservando ordem, disparo ao voltar a rede.
- **Sem teste** da camada SQLCipher/GPS/UI (exigem dispositivo ou emulador).
