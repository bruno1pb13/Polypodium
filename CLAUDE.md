# Polypodium - Guia de Desenvolvimento

## Comandos Úteis
- **Build Runner**: `flutter pub run build_runner build --delete-conflicting-outputs`
- **Executar App**: `flutter run`
- **Testes**: `flutter test`
- **Análise**: `flutter analyze`

## Padrões do Projeto
- **Arquitetura**: Feature-first com camadas (domain, data, presentation).
- **Gerenciamento de Estado**: Riverpod com `riverpod_annotation`.
- **Banco de Dados**: Drift (SQLite).
- **Enums**: Localizados em `lib/core/enums.dart`.
- **UI**: Estilo Glassmorphism com fundos de imagem e desfoque.
- **Busca**: Componente reutilizável `AppSearchBar` em `lib/core/widgets/`.

## Filtros e Ordenação
Todas as telas de listagem (Home, Espécies, Solos, Localizações) devem suportar:
1. Busca textual via `AppSearchBar`.
2. Ordenação via `PopupMenuButton` integrado ao `AppSearchBar`.
3. Provedores Riverpod específicos para filtragem e ordenação (ex: `filteredSortedPlantsProvider`).
