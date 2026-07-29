param(
    [ValidateSet('android-arm64', 'android-arm', 'android-x64')]
    [string]$TargetPlatform = 'android-arm64'
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$symbolDirectory = Join-Path $projectRoot 'build\symbols'

Push-Location $projectRoot
try {
    flutter build apk `
        --release `
        --target-platform $TargetPlatform `
        --split-debug-info $symbolDirectory
}
finally {
    Pop-Location
}
