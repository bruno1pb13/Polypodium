# Desenvolvimento

## Stack

| Pacote | Uso |
|---|---|
| Flutter ≥ 3.32 / Dart ≥ 3.5 | framework |
| `drift` + `drift_dev` | banco de dados SQLite local |
| `flutter_riverpod` + `riverpod_generator` | estado e DI |
| `workmanager` | tarefa periódica de verificação de irrigação |
| `flutter_local_notifications` | notificações locais |
| `http` | chamadas HTTP para o servidor de sync |
| `shared_preferences` | token JWT e cursor de sync |
| `image_picker` | fotos das plantas |
| `geolocator` | coordenadas para localizações |
| `uuid` | geração de UUIDs no cliente |

Arquitetura feature-first com camadas (`domain`, `data`, `presentation`) e UI em estilo glassmorphism.

## Rodar localmente

```bash
# 1. Instalar dependências
flutter pub get

# 2. Gerar código (Drift + Riverpod) — obrigatório após clonar
dart run build_runner build --delete-conflicting-outputs

# 3. Rodar no dispositivo/emulador conectado
flutter run
```

O gerador de código precisa ser reexecutado sempre que arquivos anotados com `@riverpod`, `@DriftDatabase` ou `@DriftAccessor` forem modificados.

```bash
flutter analyze   # lint
flutter test      # testes
```

## Sincronização

Em **Configurações → Servidor** informe a URL de um [Polypodium Server](https://github.com/bruno1pb13/Polypodium_server) e faça login; o botão de sync aparece na mesma tela.

Com o app aberto, o `AutoSyncController` sincroniza periodicamente (a cada 5 min; 30 min quando o Android reporta economia de bateria), além do sync ao abrir o app, no pull-to-refresh e pelo botão manual. Não há sync em segundo plano com o app fechado — o WorkManager executa apenas a verificação de notificações de irrigação.

A resolução de conflitos é last-write-wins e o comparador em `lib/core/sync/lww_merge.dart` **precisa permanecer idêntico, termo a termo**, ao do servidor (`sync_repository.dart`) — não há pacote compartilhado, apenas lógica espelhada.
