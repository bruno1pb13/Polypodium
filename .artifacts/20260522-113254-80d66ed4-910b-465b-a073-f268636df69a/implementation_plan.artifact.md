# Implementar Transições Suaves e Rápidas

O objetivo é substituir as transições de tela padrão por animações mais fluidas, rápidas e suaves, aplicando uma mudança global no tema do aplicativo.

## Mudanças Propostas

### Core - Tema e Navegação

#### [app_theme.dart](file:///home/bruno/Documentos/botanica01/lib/core/theme/app_theme.dart)
- Implementar um `PageTransitionsBuilder` personalizado chamado `SmoothPageTransitionsBuilder`.
- Este builder utilizará uma combinação de `FadeTransition` e `SlideTransition` (deslocamento sutil de baixo para cima ou da direita) com uma curva de animação suave (`Curves.easeOutCubic`).
- Aplicar este builder globalmente através do `PageTransitionsTheme` no `ThemeData` (tanto para `light` quanto `dark`).
- Isso garantirá que todas as telas abertas via `MaterialPageRoute` utilizem a nova animação automaticamente.

### [NEW] [smooth_page_transitions_builder.dart](file:///home/bruno/Documentos/botanica01/lib/core/theme/smooth_page_transitions_builder.dart)
- Arquivo contendo a implementação da classe `SmoothPageTransitionsBuilder`.

## Plano de Verificação

### Verificação Manual
- Navegar entre as telas do app (Home -> Detalhes, Home -> Espécies, etc.) e observar a fluidez.
- Verificar se a animação parece "mais rápida" e "suave" como solicitado.

### Testes Automatizados
- Executar `flutter test` para garantir que as mudanças no tema não afetaram a renderização básica dos widgets.
