# Polypodium — app

App mobile de gerenciamento de coleção de plantas. Offline-first: todos os dados vivem no SQLite local; a sincronização com o servidor é opcional.

## Dependências

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

## Build e execução

```bash
# 1. Instalar dependências
flutter pub get

# 2. Gerar código (Drift + Riverpod) — obrigatório após clonar ou alterar tabelas/providers
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Rodar no dispositivo/emulador conectado
flutter run

# Outros comandos úteis
flutter analyze          # lint
flutter test             # testes
```

> O gerador de código precisa ser reexecutado sempre que arquivos `*.dart` anotados com `@riverpod`, `@DriftDatabase` ou `@DriftAccessor` forem modificados.

## Sincronização (opcional)

Em **Configurações → Servidor** informe a URL e faça login. A partir daí o botão de sync aparece na mesma tela.

O sync é manual — não há sincronização automática em segundo plano. O WorkManager só executa a verificação de notificações de irrigação.
