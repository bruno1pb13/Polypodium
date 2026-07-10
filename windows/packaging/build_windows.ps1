# build_windows.ps1 — builds a Windows MSIX installer and a portable ZIP.
#
# Usage: .\windows\packaging\build_windows.ps1

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot = Resolve-Path "$ScriptDir\..\.."
Set-Location $ProjectRoot

if (-not $env:MSIX_IDENTITY_NAME) {
    throw "Repository variable MSIX_IDENTITY_NAME is not configured. Copy the Package/Identity Name value from Partner Center."
}
if (-not $env:MSIX_PUBLISHER) {
    throw "Repository variable MSIX_PUBLISHER is not configured. Copy the Package/Identity Publisher value from Partner Center."
}

# The Store identity is public metadata, supplied by GitHub Actions repository
# variables so the repository can keep harmless local placeholders.
$PubspecPath = Join-Path $ProjectRoot "pubspec.yaml"
$Pubspec = [System.IO.File]::ReadAllText($PubspecPath, [System.Text.Encoding]::UTF8)
$Pubspec = $Pubspec -replace '(?m)^(\s*publisher:)\s*.*$', "`$1 $env:MSIX_PUBLISHER"
$Pubspec = $Pubspec -replace '(?m)^(\s*identity_name:)\s*.*$', "`$1 $env:MSIX_IDENTITY_NAME"
[System.IO.File]::WriteAllText($PubspecPath, $Pubspec, (New-Object System.Text.UTF8Encoding($false)))

Write-Host "==> Building Flutter Windows (release)..." -ForegroundColor Cyan
$BuildArgs = @("build", "windows", "--release")
if ($env:BUILD_NAME) { $BuildArgs += "--build-name=$env:BUILD_NAME" }
if ($env:BUILD_NUMBER) { $BuildArgs += "--build-number=$env:BUILD_NUMBER" }

flutter @BuildArgs

# Ensure msix is available
Write-Host "==> Generating MSIX Installer..." -ForegroundColor Cyan
$MsixArgs = @("pub", "run", "msix:create", "--store")
if ($env:BUILD_NAME) {
    # Microsoft Store requires the fourth (revision) component to be zero.
    # Keep the semantic app version and do not append the CI build number.
    if ($env:BUILD_NAME -notmatch '^\d+\.\d+\.\d+$') {
        throw "BUILD_NAME must use semantic version format x.y.z for MSIX packaging (received: $env:BUILD_NAME)."
    }
    $MsixVer = "$env:BUILD_NAME.0"
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
