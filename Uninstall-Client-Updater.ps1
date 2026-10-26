$taskName = 'Group Wallpaper Updater'
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
$installFolder = Join-Path $env:LOCALAPPDATA 'GroupWallpaperUpdater'
Remove-Item -LiteralPath $installFolder -Recurse -Force -ErrorAction SilentlyContinue
Write-Host 'Group Wallpaper Updater has been removed.' -ForegroundColor Green
