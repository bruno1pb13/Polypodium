# Desenvolvimento

## Stack

| Pacote | Uso |
|---|---|
| Flutter ≥ 3.32 / Dart ≥ 3.5 | framework |
| `drift` + `drift_dev` | banco de dados SQLite local |
| `flutter_riverpod` + `riverpod_generator` | estado e DI |
| `workmanager` | tarefa periódica de verificação de irrigação |
| `flutter_local_notifications` | notificações locais |
| `home_widget` | widget de tela inicial (Android) |
| `pdf` + `printing` + `qr` | etiquetas com QR code (PDF, impressão) |
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

## Widget de tela inicial (Android)

O widget mostra as tarefas atrasadas e de hoje da agenda (até 5 linhas) do workspace ativo. O conteúdo é um snapshot JSON já localizado, montado em Dart (`buildHomeWidgetSnapshot`) e gravado com `home_widget` na chave `agenda_snapshot`; o `AgendaWidgetProvider` (Kotlin) só o desenha. O snapshot é republicado:

- com o app aberto, a cada mudança do `agendaTasksProvider` (com debounce de 1 s) — inclusive troca de workspace e o refresh ao voltar para o app;
- na tarefa de 12 h do WorkManager, depois de reagendar os lembretes;
- depois das ações "Reguei"/"Lembrar em 3 h" das notificações e do botão "Reguei" do próprio widget (que roda em segundo plano, sem abrir o app).

O snapshot guarda o dia em que foi calculado. A atualização periódica do widget (`updatePeriodMillis`, 1 h) compara esse dia com a data do aparelho e, se virou o dia, pede uma vez um snapshot novo ao Dart em segundo plano — então os rótulos "hoje"/"atrasado" ficam no máximo ~1 h desatualizados depois da meia-noite (mais, se o sistema adiar a atualização; abrir o app sempre atualiza). Tocar no widget abre a agenda; tocar numa linha abre a planta.

## Etiquetas com QR code

"Gerar etiquetas" (no detalhe da planta e no modo de seleção da Home) monta um PDF A4 com uma etiqueta por planta — QR code, apelido, nome popular e científico e, opcionalmente, localização e data de aquisição — em dois formatos de folha: 3 × 8 (70 × 37 mm) ou 2 × 5 (99 × 57 mm). O PDF é gerado em Dart puro (`buildLabelsPdf`, pacote `pdf`) com as fontes embutidas do PDF (Helvetica, Latin-1): acentos saem normalmente, emojis e outros alfabetos são omitidos. "Imprimir" abre o diálogo de impressão do sistema (`printing`); o PDF também pode ser compartilhado (Android/iOS) ou salvo (desktop).

O QR code guarda `polypodium://plant/<id da planta>`. Todos os links `polypodium://` (do widget e das etiquetas) passam pelo mesmo parser, `AppLink.parse`.

## Sincronização

Em **Configurações → Servidor** informe a URL de um [Polypodium Server](https://github.com/bruno1pb13/Polypodium_server) e faça login; o botão de sync aparece na mesma tela.

Com o app aberto, o `AutoSyncController` sincroniza periodicamente (a cada 5 min; 30 min quando o Android reporta economia de bateria), além do sync ao abrir o app, no pull-to-refresh e pelo botão manual. No Android, a tarefa periódica do WorkManager (a cada 12 h, a mesma que reagenda os lembretes) também faz uma passada de sync (pull + push, incluindo fotos) antes de reagendar, se o workspace ativo for remoto com login e a sincronização automática estiver ligada; é pulada se houve sync nos últimos 35 min. A passada tem timeout de 60 s e qualquer falha (offline, sessão expirada) só é registrada no log — o reagendamento dos lembretes sempre roda. Os cursores de sync só avançam (`SyncCursorsDao.setCursor`), então uma passada em segundo plano concorrente com a do app não os regride; pull e push são idempotentes (last-write-wins). No iOS não há sync em segundo plano.

A resolução de conflitos é last-write-wins, com a mesma regra no app e no servidor: o `updatedAt` mais novo vence e, em empate exato, vence o maior `deviceId`; reenviar a mesma mudança não altera nada. Para isso cada linha sincronizada guarda o `deviceId` de quem escreveu a versão atual: as escritas locais (inclusive as dos isolates de notificação e do WorkManager) gravam o `deviceId` do workspace ativo, informado ao `AppDatabase` ao abri-lo, e uma linha recebida no pull guarda o do remetente. No workspace local, e nas linhas anteriores ao schema v15, o `deviceId` é nulo e conta como string vazia, perdendo qualquer empate contra um dispositivo conhecido. O backup exporta o `deviceId` e o usa no desempate ao importar; a linha importada é uma escrita local e recebe o `deviceId` deste aparelho. O comparador (`incomingWins`) e o modelo de mudança do sync (`SyncChange`) vêm do pacote compartilhado [`polypodium_core`](https://github.com/bruno1pb13/polypodium_core), usado também pelo servidor, que roda os mesmos vetores de teste contra o seu `ON CONFLICT`. Mudar a regra é mudar o pacote, gerar uma nova tag e atualizar o `ref` aqui e no servidor.

Novos valores de `EntryType` não exigem nada no sync: o pull declara no header `X-Polypodium-Entry-Types` todos os `EntryType.values` desta build, e o servidor só envia registros desses tipos. Versões até a v2.7.2 não mandam o header e travariam ao receber um tipo desconhecido, então o servidor só lhes envia os 10 tipos originais. Para não perder os registros que ficaram ocultos atrás do cursor, o app guarda na tabela `sync_entry_types` (no banco do workspace, ao lado do cursor) os tipos que já declarou ao servidor — sem registro, assume os 10 originais se já tinha cursor de pull e todos os atuais se é um aparelho novo. Quando a build passa a conhecer tipos fora desse conjunto, cada sync (inclusive o de segundo plano), depois do pull e do push normais, faz um pull à parte desde `rev` 0 só de `entry` e só dos tipos novos (`entities=entry` no servidor), com cursor próprio na `sync_cursors` (`backfill:<tipos>`), aplicando pelo mesmo caminho do pull (LWW, fotos). Ao terminar, os tipos passam a declarados e o cursor do backfill é apagado; se for interrompido, continua dele no próximo sync. Um servidor que não ecoa `entities` na resposta é anterior à restrição: o backfill é dispensado e os tipos marcados como declarados, sem baixar tudo de novo. O import de backup dessas versões antigas continua rejeitando tipos novos.

Um registro pode ter várias fotos. A primeira continua em `entries.photoPath`, como sempre, e as demais ficam na tabela `entry_photos` (schema v20), sincronizada como a entidade `entry_photo` (`entryId`, `position`, e a foto como `photoKey`, igual ao registro). Cada arquivo sobe e desce pelo mesmo canal de fotos (`PUT/GET /photos/<id><ext>`), e as linhas da `entry_photos` são gravadas depois do registro, então chegam a outro aparelho depois dele. Versões até a v2.8 ignoram entidades desconhecidas tanto no pull (`applyRemoteChange` não tem `default`) quanto no download de fotos (só olham `entityType == 'entry'`): mostram só a primeira foto. Como o cursor delas passa por cima das linhas ignoradas, o app guarda em `sync_entity_types` as entidades que já aplica e, ao passar a aplicar uma nova, faz uma vez um pull à parte dela desde `rev` 0 (`entities=entry_photo`, cursor `backfill-entities:<entidades>`), como no backfill de tipos de registro. Um servidor que ecoa `entities` sem a entidade ainda não a guarda: o backfill fica pendente e é tentado de novo nos próximos syncs. Um servidor antigo descarta as fotos extras recebidas no push; veja abaixo como elas são reenviadas depois que ele é atualizado.

O mesmo vale no push para qualquer entidade que o servidor ainda não guarda (`entry_photo`, `reminder` e `defensivo` chegaram ao servidor depois das demais): ele a descarta, e o cursor de push passa por cima dela. Para não perder essas linhas quando servidor e app são atualizados fora de ordem, o servidor informa em cada pull os tipos que guarda (`supportedEntities`) e, em cada push, os que descartou do lote (`ignoredEntityTypes`); servidores anteriores não mandam nenhum dos dois e o app segue como antes. O app guarda em `sync_confirmed_entity_types` (schema v21, por servidor, ao lado do cursor de push) os tipos que o servidor confirmou guardar. Depois do pull, cada tipo que o servidor informa guardar e ainda não está confirmado é tratado assim:

- `species`, `plant`, `entry`, `location` e `soil` (com `bed`, os tipos do primeiro servidor com tabelas `mat_*`) nunca foram descartados: são confirmados direto, sem reenvio;
- num aparelho que nunca fez push (cursor de push 0), todos são confirmados direto — o push normal já envia tudo;
- os demais são reenviados uma vez: depois do push normal, todas as linhas locais do tipo (vivas e tombstones, só as escritas aqui — as recebidas no pull vieram do servidor) vão de novo com o `updatedAt`/`deviceId` atuais, o que o LWW do servidor torna idempotente. As fotos passam pelo mesmo `_prepareOutgoingPhoto`, mas antes de subir cada arquivo o app pergunta ao servidor se ele já o tem (`HEAD /photos/<chave>`): o arquivo subiu no push original mesmo com a linha descartada, então em geral nada é reenviado. O reenvio tem cursor próprio na `sync_cursors` (`repush:<tipo>`), é retomado de onde parou se interrompido (inclusive no sync em segundo plano, que roda o mesmo fluxo dentro dos 60 s) e, ao terminar, confirma o tipo e apaga o cursor.

Um tipo que o servidor deixa de informar, ou que aparece em `ignoredEntityTypes` (servidor revertido para uma versão anterior), perde a confirmação e é reenviado quando voltar. Na prática, o primeiro sync de um aparelho existente com um servidor atualizado reenvia uma vez as linhas locais de `entry_photo`, `reminder` e `defensivo`.

A capa da planta (`plants.coverPhotoId`, schema v19) guarda o id da foto escolhida — o id do registro para a primeira foto ou o da linha da `entry_photos` — e não o caminho, que é diferente em cada aparelho. Sem escolha, ou se a foto foi apagada, a capa é a foto mais recente.
