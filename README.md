# Polypodium

[![CI](https://github.com/bruno1pb13/Polypodium/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/bruno1pb13/Polypodium/actions/workflows/flutter_ci.yml)
[![Release](https://img.shields.io/github/v/release/bruno1pb13/Polypodium)](https://github.com/bruno1pb13/Polypodium/releases/latest)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

App **offline-first** para gerenciar sua coleção de plantas. Todos os dados ficam no seu aparelho — sem conta, sem anúncios, sem coleta de dados.

- 🌱 **Diário por planta** — regas, podas, adubações, fotos e observações em linha do tempo.
- 💧 **Lembretes de rega** — notificações locais com frequência configurável por planta.
- 📖 **Base Flora Brasil** — autocomplete de espécies com nomes científicos embutido no app.
- 📍 **Solos e localizações** — catálogo de solos com fotos e localizações com GPS.
- 🔄 **Sincronização opcional** — entre aparelhos, com um [servidor hospedado por você](https://github.com/bruno1pb13/Polypodium_server).

## Download

| Plataforma | Onde |
|---|---|
| Android | [Google Play](https://play.google.com/store/apps/details?id=com.zapperbrz.polypodium) |
| Windows | [Microsoft Store](https://apps.microsoft.com/search?query=Polypodium) |
| Linux | [AppImage nos Releases](https://github.com/bruno1pb13/Polypodium/releases/latest) |

## Desenvolvimento

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # gera código Drift/Riverpod
flutter run
```

- [Guia de desenvolvimento](docs/desenvolvimento.md) — stack, geração de código, testes.
- [Builds de distribuição](docs/build.md) — AppImage (Linux), MSIX/ZIP (Windows) e limitações por plataforma.

## Servidor de sincronização

O app é completo sem servidor. Para sincronizar entre aparelhos, hospede o [Polypodium Server](https://github.com/bruno1pb13/Polypodium_server) com Docker e aponte o app em **Configurações → Servidor**.

## Licença

[MIT](LICENSE)
