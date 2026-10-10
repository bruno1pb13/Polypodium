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
- **Vasos**: `lib/features/pots/` — vasos/jardineiras/canteiros (`PotsTable`) com várias plantas cada (`plants.potId`); `PotsRepository.movePlantsToPot` move plantas entre vasos registrando um replantio, e a localização do vaso se propaga às plantas. No sync a entidade se chama `bed`.
- **Início**: painel em `lib/features/dashboard/` (`DashboardScreen`), tela inicial do app; a lista de plantas abre a partir dele. O histórico de registros fica em `lib/features/activity/` (`ActivityScreen`).

## Filtros e Ordenação
Todas as telas de listagem (Minhas Plantas — `HomeScreen`, Espécies, Solos, Localizações, Vasos) devem suportar:
1. Busca textual via `AppSearchBar`.
2. Ordenação via `PopupMenuButton` integrado ao `AppSearchBar`.
3. Provedores Riverpod específicos para filtragem e ordenação (ex: `filteredSortedPlantsProvider`).
