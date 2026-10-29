# scamsung no Windows via PowerShell: encontra bash.exe (Git for Windows) e executa o CLI.
# Uso:  powershell -ExecutionPolicy Bypass -File .\scamsung.ps1 doctor
#       powershell -ExecutionPolicy Bypass -File .\scamsung.ps1 -n apply light
$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$script = Join-Path $here 'scamsung'

$candidates = @()
$cmd = Get-Command bash.exe -ErrorAction SilentlyContinue
if ($cmd) { $candidates += $cmd.Source }
if ($env:ProgramFiles) { $candidates += (Join-Path $env:ProgramFiles 'Git\bin\bash.exe') }
if (${env:ProgramFiles(x86)}) { $candidates += (Join-Path ${env:ProgramFiles(x86)} 'Git\bin\bash.exe') }
if ($env:LOCALAPPDATA) { $candidates += (Join-Path $env:LOCALAPPDATA 'Programs\Git\bin\bash.exe') }

$bash = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $bash) {
    Write-Host 'scamsung precisa do bash do Git for Windows.' -ForegroundColor Yellow
    Write-Host '  winget install --id Git.Git -e'
    Write-Host '  winget install --id Google.PlatformTools -e'
    Write-Host 'Alternativa: WSL (wsl --install) e rode ./scamsung de dentro dele.'
    exit 1
}

& $bash $script @args
exit $LASTEXITCODE
