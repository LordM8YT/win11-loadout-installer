# Win11 Loadout Installer

Win11 Loadout Installer is a terminal-first custom installer layer for Windows 11.

It does not replace Windows Setup. Instead, it sits in front of it, collects user choices, prepares install configuration, and hands off to Windows Setup while keeping the user experience centered around a custom loadout flow.

## Vision

- Terminal-driven installer similar in spirit to tools like `archinstall`
- Custom branding and profile selection before Windows Setup
- Generate unattended configuration from user choices
- Hand off to Windows Setup as the installation engine
- Resume with a post-install loadout phase after first boot

## Planned flow

1. Select a Windows 11 ISO
2. Choose edition
3. Choose install profile
4. Pick optional tweaks and apps
5. Generate `autounattend.xml`
6. Stage post-install payload
7. Launch Windows Setup with the generated configuration
8. Resume post-install customization after first login

## Profiles

- `Competitive`
- `FiveM`
- `Streamer`
- `Creator`

## Current state

This repository currently contains the first CLI scaffold for the installer experience.

It is intended to work alongside:
[win11-gaming-loadout](https://github.com/LordM8YT/win11-gaming-loadout)

## Project layout

- `src/Start-LoadoutInstaller.ps1`: entrypoint for the terminal installer
- `src/lib/ProfileCatalog.ps1`: profile definitions
- `src/lib/UiHelpers.ps1`: CLI helpers for prompts and menus

## Quick start

```powershell
Set-ExecutionPolicy -Scope Process Bypass
cd "C:\Users\Patri\Desktop\win11-loadout-installer\src"
.\Start-LoadoutInstaller.ps1
```

## Scope

This project focuses on the installer orchestration experience.

The lower-level ISO customization and payload logic should stay reusable and separate so both projects can evolve independently.

