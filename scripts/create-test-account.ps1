[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][ValidatePattern('^[A-Za-z0-9_.-]{3,64}$')][string]$Username,
    [Uri]$BackendOrigin = 'http://127.0.0.1:8080'
)
$ErrorActionPreference = 'Stop'
if ($BackendOrigin.Scheme -notin @('http', 'https')) { throw 'Use an http or https backend origin.' }
$taskBase = $BackendOrigin.AbsoluteUri.TrimEnd('/') + '/api'
$taskFixture = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'demo-profile.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$taskSecure = Read-Host 'Password for the NEW test account (6-64 characters)' -AsSecureString
$taskPointer = [IntPtr]::Zero
$taskAuth = $null
try {
    $taskPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($taskSecure)
    $taskPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($taskPointer)
    if ($taskPassword.Length -lt 6 -or $taskPassword.Length -gt 64) { throw 'Password must contain 6-64 characters.' }
    $taskBody = @{ username = $Username; nickname = $taskFixture.nickname; password = $taskPassword } | ConvertTo-Json -Compress
    $taskAuth = Invoke-RestMethod -Uri "$taskBase/auth/register" -Method Post -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($taskBody))
    if ($taskAuth.code -ne 200) { throw "Registration failed: $($taskAuth.message)" }
    $taskProfile = @{ nickname = $taskFixture.nickname; email = "$Username@example.com"; department = $taskFixture.department } | ConvertTo-Json -Compress
    $taskUpdated = Invoke-RestMethod -Uri "$taskBase/user/profile" -Method Put -Headers @{ Authorization = 'Bearer ' + $taskAuth.data.accessToken } -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($taskProfile))
    if ($taskUpdated.code -ne 200) { throw "Account created, but profile setup failed: $($taskUpdated.message). Sign in with the created account to review it." }
    Write-Host "Created account '$Username'. Sign in with the password you entered. No shared/upload records were inserted."
} finally {
    if ($taskAuth -and $taskAuth.code -eq 200) {
        try {
            $taskRevoke = @{ refreshToken = $taskAuth.data.refreshToken } | ConvertTo-Json -Compress
            Invoke-RestMethod -Uri "$taskBase/auth/logout" -Method Post -ContentType 'application/json; charset=utf-8' -Body $taskRevoke | Out-Null
        } catch { Write-Warning 'Could not revoke the temporary registration session.' }
    }
    if ($taskPointer -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($taskPointer) }
    $taskPassword = $null; $taskBody = $null; $taskRevoke = $null; $taskAuth = $null
    $taskSecure.Dispose()
}
