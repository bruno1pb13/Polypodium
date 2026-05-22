# PlantLog

App de acompanhamento de plantas - offline-first.

O **PlantLog** é uma ferramenta para ajudar entusiastas de botânica a gerenciar suas coleções de plantas, registrar atividades e receber lembretes de cuidados, tudo funcionando de forma independente de conexão com a internet.

## 🚀 Funcionalidades

- **Gerenciamento de Plantas:** Adicione e edite informações sobre suas plantas, incluindo fotos, espécies e localização.
- **Histórico de Atividades:** Registre regas, adubações, podas e outras manutenções (Entradas).
- **Espécies e Locais:** Organize suas plantas por espécies e os locais onde elas estão dispostas.
- **Notificações:** Receba lembretes para não esquecer de cuidar das suas plantas.
- **Offline-first:** Todos os dados são armazenados localmente no dispositivo.

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev)
- **Gerenciamento de Estado:** [Riverpod](https://riverpod.dev) com `riverpod_generator`
- **Banco de Dados Local:** [Drift](https://drift.simonbinder.eu) (SQLite)
- **Tarefas em Segundo Plano:** [Workmanager](https://pub.dev/packages/workmanager)
- **Notificações:** [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- **Injeção de Dependências:** Riverpod

## 🏁 Como Iniciar

### Pré-requisitos

- Flutter SDK instalado (versão compatível com o `pubspec.yaml`).
- Dispositivo Android/iOS ou emulador configurado.

### Configuração

1. Clone o repositório.
2. Instale as dependências:
   ```bash
   flutter pub get
   ```
3. Execute o gerador de código (necessário para Drift e Riverpod):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Execute o aplicativo:
   ```bash
   flutter run
   ```
