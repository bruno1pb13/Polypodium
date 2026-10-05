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

Com o app aberto, o `AutoSyncController` sincroniza periodicamente (a cada 5 min; 30 min quando o Android reporta economia de bateria), além do sync ao abrir o app, no pull-to-refresh e pelo botão manual. No Android, a tarefa periódica do WorkManager (a cada 12 h, a mesma que reagenda os lembretes) também faz uma passada de sync (pull + push, incluindo fotos) antes de reagendar, se o workspace ativo for remoto com login e a sincronização automática estiver ligada; é pulada se houve sync nos últimos 35 min. A passada tem timeout de 60 s e qualquer falha (offline, sessão expirada) só é registrada no log — o reagendamento dos lembretes sempre roda. Os cursores de sync só avançam (`SyncCursorsDao.setCursor`), então uma passada em segundo plano concorrente com a do app não os regride; pull e push são idempotentes (last-write-wins). No iOS não há sync em segundo plano.

A resolução de conflitos é last-write-wins, com a mesma regra no app e no servidor: o `updatedAt` mais novo vence e, em empate exato, vence o maior `deviceId`; reenviar a mesma mudança não altera nada. Para isso cada linha sincronizada guarda o `deviceId` de quem escreveu a versão atual: as escritas locais (inclusive as dos isolates de notificação e do WorkManager) gravam o `deviceId` do workspace ativo, informado ao `AppDatabase` ao abri-lo, e uma linha recebida no pull guarda o do remetente. No workspace local, e nas linhas anteriores ao schema v15, o `deviceId` é nulo e conta como string vazia, perdendo qualquer empate contra um dispositivo conhecido. O backup exporta o `deviceId` e o usa no desempate ao importar; a linha importada é uma escrita local e recebe o `deviceId` deste aparelho. O comparador (`incomingWins`) e o modelo de mudança do sync (`SyncChange`) vêm do pacote compartilhado [`polypodium_core`](https://github.com/bruno1pb13/polypodium_core), usado também pelo servidor, que roda os mesmos vetores de teste contra o seu `ON CONFLICT`. Mudar a regra é mudar o pacote, gerar uma nova tag e atualizar o `ref` aqui e no servidor.
