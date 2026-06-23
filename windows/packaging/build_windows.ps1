# build_windows.ps1 — builds a Windows MSIX installer and a portable ZIP.
#
# Usage: .\windows\packaging\build_windows.ps1

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot = Resolve-Path "$ScriptDir\..\.."
Set-Location $ProjectRoot

Write-Host "==> Building Flutter Windows (release)..." -ForegroundColor Cyan
$BuildArgs = @("build", "windows", "--release")
if ($env:BUILD_NAME) { $BuildArgs += "--build-name=$env:BUILD_NAME" }
if ($env:BUILD_NUMBER) { $BuildArgs += "--build-number=$env:BUILD_NUMBER" }

flutter @BuildArgs

# Ensure msix is available
Write-Host "==> Generating MSIX Installer..." -ForegroundColor Cyan
$MsixArgs = @("pub", "run", "msix:create", "--install-certificate=false")
if ($env:BUILD_NAME) {
    # MSIX version must be in format x.x.x.x
    $MsixVer = $env:BUILD_NAME
    if ($env:BUILD_NUMBER) { $MsixVer = "$env:BUILD_NAME.$env:BUILD_NUMBER" }
    else { $MsixVer = "$env:BUILD_NAME.0" }
    $MsixArgs += "--version=$MsixVer"
}
flutter @MsixArgs

# Create Portable ZIP
Write-Host "==> Creating Portable ZIP..." -ForegroundColor Cyan
$BuildPath = "$ProjectRoot\build\windows\x64\runner\Release"
$ZipOutput = "$ProjectRoot\build\Polypodium-Windows-Portable.zip"

if (Test-Path $ZipOutput) {
    Remove-Item $ZipOutput
}

# Copying to a temp folder to avoid zipping the MSIX if it's in the same folder
$TempZipDir = "$ProjectRoot\build\portable_temp"
if (Test-Path $TempZipDir) { Remove-Item -Recurse $TempZipDir }
New-Item -ItemType Directory -Path $TempZipDir | Out-Null

Copy-Item -Path "$BuildPath\*" -Destination $TempZipDir -Recurse -Exclude "*.msix", "*.exe.symbol"

Compress-Archive -Path "$TempZipDir\*" -DestinationPath $ZipOutput

Remove-Item -Recurse $TempZipDir

Write-Host "`nSuccessfully built Windows targets:" -ForegroundColor Green
Write-Host " - MSIX: build\windows\x64\runner\Release\Polypodium.msix"
Write-Host " - ZIP:  build\Polypodium-Windows-Portable.zip"
