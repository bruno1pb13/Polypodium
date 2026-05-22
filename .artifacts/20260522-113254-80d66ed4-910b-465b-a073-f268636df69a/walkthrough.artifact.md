# Transições de Tela Suaves e Rápidas

Implementei uma nova lógica de transição de tela global para tornar a experiência de uso do app mais fluida e ágil.

## O que foi feito

### 1. Criado o `SmoothPageTransitionsBuilder`
Criei um construtor de transições personalizado em [smooth_page_transitions_builder.dart](file:///home/bruno/Documentos/botanica01/lib/core/theme/smooth_page_transitions_builder.dart) que utiliza:
- **FadeTransition**: Suaviza a entrada da tela.
- **SlideTransition**: Adiciona um deslocamento lateral sutil (5% do eixo X) para dar profundidade.
- **Curves.easeOutQuart**: Uma curva de animação que começa rápido (zippy) e termina suavemente, atendendo ao pedido de transições "rápidas porém suaves".

### 2. Aplicação Global no Tema
O novo builder foi aplicado ao [app_theme.dart](file:///home/bruno/Documentos/botanica01/lib/core/theme/app_theme.dart), garantindo que tanto no modo claro quanto no escuro, e em ambas as plataformas (Android/iOS), a navegação padrão do Flutter (`MaterialPageRoute`) utilize essa nova animação.

## Verificação
- O código foi analisado estaticamente com `flutter analyze` (sem erros nos arquivos modificados).
- Os testes existentes foram executados com `flutter test` e todos passaram, garantindo a integridade do app.
