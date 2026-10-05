# Builds de distribuição

## Linux (AppImage)

### Pré-requisitos

Dependências de sistema:

```bash
sudo pacman -S gtk3 ninja cmake pkg-config libnotify
# ou no Ubuntu/Debian:
# sudo apt install libgtk-3-dev libnotify-dev ninja-build cmake pkg-config
```

`appimagetool` no PATH:

```bash
mkdir -p ~/.local/bin
wget -O ~/.local/bin/appimagetool-x86_64.AppImage \
  https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x ~/.local/bin/appimagetool-x86_64.AppImage
```

Na primeira build (Linux e Windows), o CMake do plugin `printing` (impressão das etiquetas) baixa o pdfium de [pdfium-binaries](https://github.com/bblanchon/pdfium-binaries), então é preciso internet; no Linux a `libpdfium.so` vai junto no `lib/` do bundle.

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
| Escanear etiqueta | Indisponível — `mobile_scanner` não suporta Linux (gerar e imprimir etiquetas funciona) |
| Sync com servidor | Funciona normalmente via HTTP |

## Windows (MSIX e ZIP)

O script de build gera o instalador (`.msix`) e a versão portátil (`.zip`):

```powershell
.\windows\packaging\build_windows.ps1
```

Artefatos de saída:

- **Instalador:** `build\windows\x64\runner\Release\Polypodium.msix`
- **Portátil:** `build\Polypodium-Windows-Portable.zip`

### Limitações no Windows

| Funcionalidade | Comportamento |
|---|---|
| Notificações de irrigação | Desabilitadas — `workmanager` não suporta Windows |
| Geolocalização | Funciona normalmente via Windows Location Services |
| Escanear etiqueta | Indisponível — `mobile_scanner` não suporta Windows (gerar e imprimir etiquetas funciona) |
| Sync com servidor | Funciona normalmente via HTTP |
