[CmdletBinding()]
param([switch]$CheckOnly)
$ErrorActionPreference = 'Stop'
try {
    $configPath = Join-Path $PSScriptRoot 'config.local.json'
    if (-not (Test-Path -LiteralPath $configPath)) { throw 'Create config.local.json from config.example.json and fill your own QQ path/account.' }
    $config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
    if (-not [IO.Path]::IsPathRooted([string]$config.qqExe)) { throw 'qqExe must be an absolute path.' }
    $qq = [IO.Path]::GetFullPath([string]$config.qqExe)
    if (-not (Test-Path -LiteralPath $qq -PathType Leaf)) { throw 'Configured QQ.exe does not exist.' }
    if ([IO.Path]::GetFileName($qq) -ine 'QQ.exe') { throw 'qqExe must point to QQ.exe.' }
    $number = [string]$config.qqNumber
    if ($number -notmatch '^[1-9][0-9]{4,11}$') { throw 'Fill your QQ account number in config.local.json.' }
    $port = [int]$config.oneBotPort
    if ($port -lt 1 -or $port -gt 65535) { throw 'oneBotPort must be between 1 and 65535.' }
    $shell = Join-Path $PSScriptRoot 'runtime\shell'
    if ($config.shellDirectory) {
        $configuredShell = [string]$config.shellDirectory
        $shell = if ([IO.Path]::IsPathRooted($configuredShell)) { [IO.Path]::GetFullPath($configuredShell) } else { [IO.Path]::GetFullPath((Join-Path $PSScriptRoot $configuredShell)) }
    }
    foreach ($file in 'NapCatWinBootMain.exe','NapCatWinBootHook.dll','qqnt.json','loadNapCat.js','napcat.mjs') {
        if (-not (Test-Path -LiteralPath (Join-Path $shell $file) -PathType Leaf)) { throw "Missing runtime file: $file. Run Install.ps1 first." }
    }
    $client = New-Object Net.Sockets.TcpClient
    try { $task=$client.ConnectAsync('127.0.0.1',$port); $occupied=($task.Wait(500) -and $client.Connected) } catch { $occupied=$false } finally { $client.Dispose() }
    if ($CheckOnly) { Write-Output "Configuration/runtime files OK. OneBot port listening: $occupied. No QQ process started."; exit 0 }
    if ($occupied) { Write-Output 'OneBot port already in use. Keeping the current backend; verify its identity before using it.'; exit 0 }
    $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        # Only elevate this known local script. No account, token or shell command is passed through UAC arguments.
        $argsForAdmin = '-NoLogo -NoProfile -ExecutionPolicy Bypass -NoExit -File "{0}"' -f $PSCommandPath
        Start-Process -FilePath (Join-Path $PSHOME 'powershell.exe') -ArgumentList $argsForAdmin -Verb RunAs -WorkingDirectory $PSScriptRoot | Out-Null
        exit 0
    }
    Set-Location -LiteralPath $shell
    $env:NAPCAT_PATCH_PACKAGE=Join-Path $shell 'qqnt.json'
    $env:NAPCAT_LOAD_PATH=Join-Path $shell 'loadNapCat.js'
    $env:NAPCAT_INJECT_PATH=Join-Path $shell 'NapCatWinBootHook.dll'
    $env:NAPCAT_MAIN_PATH=Join-Path $shell 'napcat.mjs'
    Write-Output 'Starting official NapCat with administrator permissions. Keep this window open.'
    & (Join-Path $shell 'NapCatWinBootMain.exe') $qq (Join-Path $shell 'NapCatWinBootHook.dll') $number
    exit $LASTEXITCODE
} catch { Write-Error $_; exit 1 }
