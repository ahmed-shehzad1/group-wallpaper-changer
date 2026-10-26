$ErrorActionPreference = "Stop"
$wallpaper = Join-Path $PSScriptRoot "wallpaper.jpg"
if (-not (Test-Path -LiteralPath $wallpaper)) {
    Write-Host "Wallpaper image not found: $wallpaper" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WallpaperSetter {
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int action, int param, string value, int winIni);
}
"@
$result = [WallpaperSetter]::SystemParametersInfo(20, 0, $wallpaper, 3)
if ($result -eq 0) {
    Write-Host "Windows could not change the wallpaper." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "Wallpaper changed successfully!" -ForegroundColor Green
Write-Host "Image: $wallpaper"
Read-Host "Press Enter to exit"
