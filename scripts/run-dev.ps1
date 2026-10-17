[CmdletBinding()]
param(
    [ValidateSet('Run', 'Build', 'Install', 'Check')][string]$Action = 'Run',
    [string]$DeviceId = '',
    [string]$DevEcoHome = '',
    [string]$SdkHome = ''
)
$ErrorActionPreference = 'Stop'
$taskRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
Set-Location -LiteralPath $taskRoot
if (!$DevEcoHome) { $DevEcoHome = $env:TASK_IDE_HOME }
if (!$DevEcoHome) { $DevEcoHome = $env:DEVECO_HOME }
if (!$DevEcoHome) { throw 'Set TASK_IDE_HOME or pass -DevEcoHome. See README.md.' }
$DevEcoHome = [IO.Path]::GetFullPath($DevEcoHome)
if (!$SdkHome) { $SdkHome = $env:TASK_SDK_HOME }
if (!$SdkHome) { $SdkHome = Join-Path $DevEcoHome 'sdk' }
$SdkHome = [IO.Path]::GetFullPath($SdkHome)
$taskNode = Join-Path $DevEcoHome 'tools\node\node.exe'
$taskOhpm = Join-Path $DevEcoHome 'tools\ohpm\bin\ohpm.bat'
$taskHvigor = Join-Path $DevEcoHome 'tools\hvigor\bin\hvigorw.js'
$taskJava = Join-Path $DevEcoHome 'jbr\bin\java.exe'
$taskHdc = Join-Path $SdkHome 'default\openharmony\toolchains\hdc.exe'
foreach ($taskFile in @($taskNode, $taskOhpm, $taskHvigor, $taskJava, $taskHdc)) {
    if (!(Test-Path -LiteralPath $taskFile -PathType Leaf)) { throw "Missing tool: $taskFile" }
}
$env:TASK_IDE_HOME = $DevEcoHome
$env:NODE_HOME = Join-Path $DevEcoHome 'tools\node'
$env:JAVA_HOME = Join-Path $DevEcoHome 'jbr'
$env:DEVECO_SDK_HOME = $SdkHome
$env:Path = "$env:NODE_HOME;$env:JAVA_HOME\bin;$env:Path"

function Invoke-TaskTool([string]$Tool, [string[]]$ToolArguments) {
    $taskPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $taskOutput = & $Tool @ToolArguments 2>&1
        $taskExit = $LASTEXITCODE
    } finally { $ErrorActionPreference = $taskPreference }
    $taskText = ($taskOutput | ForEach-Object { "$_" }) -join [Environment]::NewLine
    if ($taskExit -ne 0) { throw "Tool failed (exit $taskExit): $Tool`n$taskText" }
    return $taskText
}
function Invoke-TaskHdc([string[]]$ToolArguments) {
    $taskText = Invoke-TaskTool $taskHdc (@('-t', $DeviceId) + $ToolArguments)
    if ($taskText -match '\[Fail\]|Error Code:|error: failed') { throw "HDC failed: $taskText" }
    return $taskText
}
$taskConfig = Get-Content -LiteralPath (Join-Path $taskRoot 'products\default\src\main\ets\config\ApiConfig.ets') -Raw -Encoding UTF8
$taskOriginMatch = [regex]::Match($taskConfig, "BACKEND_ORIGIN\s*:\s*string\s*=\s*'([^']+)'")
if (!$taskOriginMatch.Success) { throw 'Cannot read BACKEND_ORIGIN from ApiConfig.ets.' }
$taskOrigin = [Uri]$taskOriginMatch.Groups[1].Value
if ($taskOrigin.Scheme -notin @('http', 'https')) { throw 'BACKEND_ORIGIN must use http or https.' }
$taskBundle = 'com.example.yyoutianxian_arkts'
$taskHap = Join-Path $taskRoot 'products\default\build\default\outputs\default\default-default-unsigned.hap'

if ($Action -ne 'Build') {
    $taskTargetsText = Invoke-TaskTool $taskHdc @('list', 'targets')
    $taskTargets = @($taskTargetsText -split '\r?\n' | ForEach-Object { $_.Trim() } | Where-Object { $_ -and $_ -ne '[Empty]' })
    if (!$DeviceId) {
        if ($taskTargets.Count -ne 1) { throw 'Start one emulator, or pass -DeviceId from hdc list targets.' }
        $DeviceId = $taskTargets[0]
    }
    if ($DeviceId -notin $taskTargets) { throw "Device is not connected: $DeviceId" }
    $taskType = (Invoke-TaskHdc @('shell', 'param', 'get', 'const.product.devicetype')).Trim()
    $taskApi = (Invoke-TaskHdc @('shell', 'param', 'get', 'const.ohos.apiversion')).Trim()
    if ($taskType -ne '2in1' -or [int]$taskApi -lt 26) { throw 'The verified desktop layout requires a MateBook 2in1 API26+ emulator.' }
    $taskForwarding = Invoke-TaskHdc @('fport', 'ls')
    $taskForwardPattern = 'tcp:' + $taskOrigin.Port + '\s+(tcp:\d+)\s+\[Reverse\]'
    $taskForwardMatch = [regex]::Match($taskForwarding, $taskForwardPattern)
    if ($taskOrigin.IsLoopback -and $taskForwardMatch.Success -and $taskForwardMatch.Groups[1].Value -ne ('tcp:' + $taskOrigin.Port)) {
        throw 'The emulator backend port already forwards to another service. Resolve it before continuing.'
    }
    try {
        $taskResponse = Invoke-WebRequest -Uri ($taskOrigin.AbsoluteUri.TrimEnd('/') + '/api/user/profile') -UseBasicParsing -TimeoutSec 8
        $taskStatus = [int]$taskResponse.StatusCode
    } catch {
        if ($_.Exception.Response) { $taskStatus = [int]$_.Exception.Response.StatusCode }
        else { throw 'Backend is unavailable. Start the matching backend before running this script. See README.md.' }
    }
    if ($taskStatus -ne 401) { throw "Expected unauthenticated backend status 401, received $taskStatus. Check BACKEND_ORIGIN." }
    if ($Action -eq 'Check') {
        [pscustomobject]@{ Frontend = $taskRoot; DevEco = $DevEcoHome; SDK = $SdkHome; Device = $DeviceId; API = $taskApi; Backend = $taskOrigin.AbsoluteUri; BackendStatus = $taskStatus }
        exit 0
    }
}

if ($Action -in @('Run', 'Build')) {
    [IO.File]::WriteAllText((Join-Path $taskRoot 'local.properties'), ('hwsdk.dir=' + $SdkHome.Replace('\', '/')), (New-Object Text.UTF8Encoding($false)))
    $taskLogDirectory = Join-Path $taskRoot '.hvigor\logs'
    New-Item -ItemType Directory -Path $taskLogDirectory -Force | Out-Null
    Write-Host 'Installing all module dependencies...'
    Write-Host (Invoke-TaskTool $taskOhpm @('install', '--all'))
    Write-Host 'Building the original main layout with aligned APIs...'
    $taskBuildLog = Join-Path $taskLogDirectory 'build-api26.log'
    try {
        $taskBuildOutput = Invoke-TaskTool $taskNode @($taskHvigor, '--mode', 'module', '-p', 'product=default', '-p', 'module=default@default', '-p', 'buildMode=debug', 'assembleHap', '--no-daemon')
        [IO.File]::WriteAllText($taskBuildLog, $taskBuildOutput, (New-Object Text.UTF8Encoding($false)))
    } catch {
        [IO.File]::WriteAllText($taskBuildLog, $_.Exception.Message, (New-Object Text.UTF8Encoding($false)))
        throw
    }
    if ($taskBuildOutput -notmatch 'BUILD SUCCESSFUL' -or !(Test-Path -LiteralPath $taskHap -PathType Leaf)) { throw "Build did not produce the expected HAP. See $taskBuildLog" }
    Write-Host "Build successful. Log: $taskBuildLog"
    if ($Action -eq 'Build') { exit 0 }
}

if (!(Test-Path -LiteralPath $taskHap -PathType Leaf)) { throw 'HAP missing. Run -Action Build first.' }
if ($taskOrigin.IsLoopback -and !$taskForwardMatch.Success) {
    Write-Host (Invoke-TaskHdc @('rport', ('tcp:' + $taskOrigin.Port), ('tcp:' + $taskOrigin.Port)))
}
# Stop before updating. A stop immediately after installation can race a new launch.
if ((Invoke-TaskHdc @('shell', 'pidof', $taskBundle)).Trim()) {
    Invoke-TaskHdc @('shell', 'aa', 'force-stop', $taskBundle) | Out-Null
    $taskStopDeadline = [DateTime]::UtcNow.AddSeconds(15)
    while ((Invoke-TaskHdc @('shell', 'pidof', $taskBundle)).Trim()) {
        if ([DateTime]::UtcNow -ge $taskStopDeadline) { throw 'The existing app did not stop before installation.' }
        Start-Sleep -Milliseconds 300
    }
}
$taskInstalled = Invoke-TaskHdc @('install', '-r', $taskHap)
if ($taskInstalled -notmatch 'install bundle successfully') { throw "Install did not succeed: $taskInstalled" }
function Test-TaskAppReady {
    if (!(Invoke-TaskHdc @('shell', 'pidof', $taskBundle)).Trim()) { return $false }
    $taskRemoteLayout = '/data/local/tmp/youtianxian-startup-check.json'
    try {
        $taskDump = Invoke-TaskHdc @('shell', 'uitest', 'dumpLayout', '-b', $taskBundle, '-p', $taskRemoteLayout)
        if ($taskDump -notmatch 'DumpLayout saved to:') { return $false }
        $taskLayout = Invoke-TaskHdc @('shell', 'cat', $taskRemoteLayout)
        # Inspect only node types, never print or store form values or session data.
        return ([regex]::Matches($taskLayout, '"type"\s*:\s*"Text"').Count -ge 6)
    } catch { return $false }
    finally {
        Invoke-TaskHdc @('shell', 'rm', '-f', $taskRemoteLayout) | Out-Null
    }
}
$taskReady = $false
for ($taskAttempt = 1; $taskAttempt -le 3; $taskAttempt++) {
    $taskStarted = Invoke-TaskHdc @('shell', 'aa', 'start', '-a', 'DefaultAbility', '-b', $taskBundle)
    if ($taskStarted -notmatch 'start ability successfully') { throw "App did not start: $taskStarted" }
    $taskStartDeadline = [DateTime]::UtcNow.AddSeconds(8)
    while ([DateTime]::UtcNow -lt $taskStartDeadline) {
        if (Test-TaskAppReady) {
            Start-Sleep -Milliseconds 600
            if (Test-TaskAppReady) { $taskReady = $true; break }
        }
        Start-Sleep -Milliseconds 400
    }
    if ($taskReady) { break }
    Write-Host "Waiting for the application window; retry $taskAttempt of 3..."
}
if (!$taskReady) { throw 'The app did not show a stable login/workspace window. Check the emulator and application logs.' }
Write-Host "Installed and started on $DeviceId. Sign in with your backend account. Window sizing is unchanged."
