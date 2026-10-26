$ErrorActionPreference = 'Stop'
$sourceScript = Join-Path $PSScriptRoot 'Client-Wallpaper-Updater.ps1'
if (-not (Test-Path -LiteralPath $sourceScript)) {
    throw 'Client-Wallpaper-Updater.ps1 is missing. Keep it beside this installer.'
}

$installFolder = Join-Path $env:LOCALAPPDATA 'GroupWallpaperUpdater'
New-Item -ItemType Directory -Path $installFolder -Force | Out-Null
$installedScript = Join-Path $installFolder 'Client-Wallpaper-Updater.ps1'
Copy-Item -LiteralPath $sourceScript -Destination $installedScript -Force

$taskName = 'Group Wallpaper Updater'
$powerShell = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
$action = New-ScheduledTaskAction -Execute $powerShell -Argument "-NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$installedScript`""
$trigger = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Days 0) -MultipleInstances IgnoreNew
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description 'Checks the configured public GitHub wallpaper image and applies it when changed.' -Force | Out-Null
Start-ScheduledTask -TaskName $taskName
Write-Host 'Installed. The updater will check GitHub every 5 minutes and apply a changed wallpaper.' -ForegroundColor Green
Write-Host 'It runs for the current Windows user at sign-in. No administrator rights should be needed.'
