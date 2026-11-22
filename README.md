# PROMAP-SUS — Aplicativo móvel (Flutter)

Implementação do cliente móvel do **Sistema de Prontuário Cartográfico para Pessoas com Deficiência no SUS**, conforme `PROMAP-SUS_Especificacao_prompt_ready.md` (seção 5: Flutter/Dart, Arquitetura Hexagonal, offline-first, Transactional Outbox).

> **Leia antes:** `docs/LACUNAS_E_DECISOES_PENDENTES.md`. A especificação não define a equação do IAL, os limiares da sinaleira, os valores dos campos categóricos nem o contrato da API. Onde foi preciso decidir para o código funcionar, o valor está marcado **PROVISÓRIO** no código e listado nesse documento. Nada disso deve ser tratado como regra clínica validada.

## Estado da entrega

| Item | Situação |
|---|---|
| Código-fonte (`lib/`) e testes (`test/`) | Escritos conforme a árvore da seção 5.1 |
| Compilação / `flutter analyze` / `flutter test` | **Não executados** — o ambiente de geração não tinha Flutter/Dart. Rode os passos abaixo; podem surgir ajustes menores de sintaxe ou de versão de pacote. |
| Pastas de plataforma (`android/`, `ios/`) | Não geradas; criadas por `flutter create .` (abaixo) |
| Servidor corporativo (microsserviços), painel web (RF05), fluxo completo de referência/contrarreferência (RF04) | **Fora do escopo desta entrega** (a seção 5 trata do app móvel) — ver `docs/RASTREABILIDADE.md` |

## Como executar

Pré-requisitos: Flutter SDK >= 3.19 (Dart >= 3.3).

```bash
# 1) Gerar as pastas de plataforma sem sobrescrever o código existente
flutter create . --org br.gov.saude --project-name promap_sus

# 2) Dependências, análise estática e testes
flutter pub get
flutter analyze
flutter test

# 3) Rodar em desenvolvimento local (padrão): simulador Mock, sem rede
flutter run

# 4) Produção: adaptador HTTP real (a URL é obrigatória e não está na especificação)
flutter run --dart-define=PROMAP_LOCAL_DEV=false \
            --dart-define=PROMAP_API_URL=https://<servidor-central>/<endpoint>
```

### Ajustes de plataforma após `flutter create`

- **Android** (`android/app/build.gradle`): `minSdkVersion 23` (exigido por `flutter_secure_storage`). Em `AndroidManifest.xml`, adicione `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `ACCESS_NETWORK_STATE` e `INTERNET`.
- **iOS** (`Info.plist`): `NSLocationWhenInUseUsageDescription` com a justificativa de uso do GPS na visita domiciliar.

## Estrutura (seção 5.1)

```
lib/
├── app/            config (tema WCAG, AppConfig), di (get_it), routes (guarda ACS/Cidadão)
├── core/           crypto (SQLCipher/AES, HMAC, SHA-256), errors, network
└── features/
    ├── cartografia_territorial/   (ACS)
    │   ├── domain/    entities, value_objects, usecases, services (IAL, SyncDaemon)
    │   ├── ports/     inbound (UI -> domínio) e outbound (domínio -> infraestrutura)
    │   └── adapters/  input/ui | output/infrastructure (local_database, local_mock_api, http_api, gps)
    └── prontuario_cidadao/        (Perfil Micro)
```

O domínio **não importa** Flutter, SQLite, `http` nem `geolocator`. A troca Mock ⇄ produção é feita em `app/di/service_locator.dart` (`isLocalDev`).

## Fluxo offline-first

1. A ACS preenche a ficha; o GPS é capturado nativamente.
2. `RegistraFichaTerritorialUseCase` valida, calcula IAL/sinaleira (offline) e chama `IFichaRepository.salvarLocamente`.
3. `SqliteFichaRepository` grava paciente + ficha + item em `TB_FILA_SINCRONIZACAO` **na mesma transação** (SQLCipher).
4. `SyncDaemonService`, ao detectar rede, lê as pendências, calcula SHA-256 do payload e envia via `ISyncApiAdapter`; só marca `SINCRONIZADO` após sucesso. Em falha, os itens permanecem `PENDENTE`.

## Documentação

- `docs/LACUNAS_E_DECISOES_PENDENTES.md` — lacunas, ambiguidades e premissas adotadas
- `docs/ARQUITETURA.md` — diagramas (processos, sequência, atividades, DER)
- `docs/RASTREABILIDADE.md` — requisitos × arquivos × situação
