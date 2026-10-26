# Group Wallpaper Changer (Windows)

This project includes a one-time wallpaper changer and an optional GitHub-based updater for Windows 10/11.

## Automatic GitHub wallpaper updates

The client updater checks the configured public GitHub `wallpaper.jpg` every 5 minutes. When the image content changes, it downloads the JPEG and applies it as the wallpaper for the current Windows user. At sign-in, it starts automatically after the client has installed it once.

### Configure your repository

In `Client-Wallpaper-Updater.ps1`, confirm this URL matches your public repository, branch, and image path:

`https://raw.githubusercontent.com/ahmed-shehzad1/group-wallpaper-changer/main/wallpaper.jpg`

If your repository differs, change the URL before pushing. Keep the image filename `wallpaper.jpg` unless you also update the script.

### Client setup

1. Download the repository ZIP and extract it.
2. Open PowerShell in the extracted folder.
3. Run this command once:

   `powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-Client-Updater.ps1`

4. The updater starts immediately and runs at future sign-ins. It checks GitHub every 5 minutes.

The user must explicitly run the installer once. A GitHub download cannot run itself just by being downloaded. The updater downloads **only the fixed wallpaper image**; it does not execute scripts or programs from GitHub.

## Stop / uninstall

Run `Uninstall-Client-Updater.ps1` from the extracted project folder, or run it with PowerShell using `-ExecutionPolicy Bypass`.

## Manual one-time change

1. Download and extract the repository ZIP.
2. Double-click `Run-Wallpaper-Changer.bat`.

## Notes

- Changes only the currently signed-in Windows user's wallpaper.
- No administrator rights are intended to be required.
- Automatic updates require an internet connection and a public GitHub repository.
- The client checks every 5 minutes; it is not an instant push notification.
