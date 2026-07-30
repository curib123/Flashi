param(
    [ValidateSet('android-arm64', 'android-arm', 'android-x64')]
    [string]$TargetPlatform = 'android-arm64'
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$symbolDirectory = Join-Path $projectRoot 'build\symbols'
$environmentFile = Join-Path $projectRoot '.env'

Push-Location $projectRoot
try {
    $buildArguments = @(
        'build'
        'apk'
        '--release'
        '--target-platform'
        $TargetPlatform
        '--split-debug-info'
        $symbolDirectory
    )
    if (Test-Path -LiteralPath $environmentFile) {
        $buildArguments += "--dart-define-from-file=$environmentFile"
    }
    flutter @buildArguments
}
finally {
    Pop-Location
}
