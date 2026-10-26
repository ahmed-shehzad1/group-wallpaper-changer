# Checks a fixed GitHub raw-image URL and applies the wallpaper when it changes.
# It downloads only wallpaper.jpg; it never downloads or executes repository scripts.
$ErrorActionPreference = 'Stop'

# Change this URL if your GitHub username, repository, branch, or image path differs.
$WallpaperUrl = 'https://raw.githubusercontent.com/ahmed-shehzad1/group-wallpaper-changer/main/wallpaper.jpg'
$CheckIntervalSeconds = 10
$AppFolder = Join-Path $env:LOCALAPPDATA 'GroupWallpaperUpdater'
$WallpaperPath = Join-Path $AppFolder 'wallpaper.jpg'
$TempPath = Join-Path $AppFolder 'wallpaper.download'

New-Item -ItemType Directory -Path $AppFolder -Force | Out-Null

if (-not ('GroupWallpaperNative' -as [type])) {
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class GroupWallpaperNative {
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern bool SystemParametersInfo(int action, int param, string value, int winIni);
}
"@
}

function Update-WallpaperIfChanged {
    try {
        # Cache-busting query helps ensure the newest public GitHub file is fetched.
        $separator = if ($WallpaperUrl.Contains('?')) { '&' } else { '?' }
        $downloadUrl = $WallpaperUrl + $separator + 'check=' + [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
        Invoke-WebRequest -Uri $downloadUrl -OutFile $TempPath -TimeoutSec 30 -Headers @{ 'Cache-Control' = 'no-cache' }

        $bytes = [System.IO.File]::ReadAllBytes($TempPath)
        # Confirm it is a JPEG before replacing the current wallpaper.
        if ($bytes.Length -lt 3 -or $bytes[0] -ne 0xFF -or $bytes[1] -ne 0xD8 -or $bytes[2] -ne 0xFF) {
            Remove-Item $TempPath -Force -ErrorAction SilentlyContinue
            return
        }

        $newHash = (Get-FileHash -LiteralPath $TempPath -Algorithm SHA256).Hash
        $oldHash = if (Test-Path -LiteralPath $WallpaperPath) {
            (Get-FileHash -LiteralPath $WallpaperPath -Algorithm SHA256).Hash
        } else { '' }

        if ($newHash -ne $oldHash) {
            Move-Item -LiteralPath $TempPath -Destination $WallpaperPath -Force
            $ok = [GroupWallpaperNative]::SystemParametersInfo(20, 0, $WallpaperPath, 3)
            if (-not $ok) { Write-EventLog -LogName Application -Source 'Windows PowerShell' -EntryType Warning -EventId 1000 -Message 'Group wallpaper updater could not apply the new wallpaper.' -ErrorAction SilentlyContinue }
        } else {
            Remove-Item -LiteralPath $TempPath -Force -ErrorAction SilentlyContinue
        }
    } catch {
        # A temporary network failure is harmless; try again at the next interval.
        Remove-Item -LiteralPath $TempPath -Force -ErrorAction SilentlyContinue
    }
}

while ($true) {
    Update-WallpaperIfChanged
    Start-Sleep -Seconds $CheckIntervalSeconds
}
