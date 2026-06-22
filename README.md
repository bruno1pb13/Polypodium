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

## Build Linux (AppImage)

### Pré-requisitos

Instale as dependências de sistema:

```bash
sudo pacman -S gtk3 ninja cmake pkg-config libnotify
# ou no Ubuntu/Debian:
# sudo apt install libgtk-3-dev libnotify-dev ninja-build cmake pkg-config
```

Baixe o `appimagetool` e torne-o executável:

```bash
mkdir -p ~/.local/bin
wget -O ~/.local/bin/appimagetool-x86_64.AppImage \
  https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x ~/.local/bin/appimagetool-x86_64.AppImage
```
### Gerar o AppImage

```bash
./linux/packaging/build_appimage.sh
# saída: build/Polypodium-x86_64.AppImage
```

O AppImage é auto-contido — basta torná-lo executável e rodar:

```bash
chmod +x build/Polypodium-x86_64.AppImage
./build/Polypodium-x86_64.AppImage
```

### Limitações no Linux

| Funcionalidade | Comportamento |
|---|---|
| Notificações de irrigação | Desabilitadas — não há daemon de background no desktop |
| Geolocalização | Indisponível — `geolocator` não suporta Linux |
| Sync com servidor | Funciona normalmente via HTTP |

## Build Windows

### Gerar MSIX e ZIP

O script de build automatiza a geração do instalador (`.msix`) e da versão portátil (`.zip`):

```powershell
.\windows\packaging\build_windows.ps1
```

Os artefatos de saída serão:
- **Instalador:** `build\windows\x64\runner\Release\Polypodium.msix`
- **Portátil:** `build\Polypodium-Windows-Portable.zip`

### Limitações no Windows

| Funcionalidade | Comportamento |
|---|---|
| Notificações de irrigação | Desabilitadas — `workmanager` não suporta Windows |
| Geolocalização | Funciona normalmente via Windows Location Services |
| Sync com servidor | Funciona normalmente via HTTP |

## Sincronização (opcional)

Em **Configurações → Servidor** informe a URL e faça login. A partir daí o botão de sync aparece na mesma tela.

O sync é manual — não há sincronização automática em segundo plano. O WorkManager só executa a verificação de notificações de irrigação.
