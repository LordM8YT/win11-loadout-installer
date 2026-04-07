# Win11 Loadout Installer

Win11 Loadout Installer is a terminal-first custom installer layer for Windows 11.

It does not replace Windows Setup. Instead, it sits in front of it, collects user choices, prepares install configuration, and hands off to Windows Setup while keeping the user experience centered around a custom loadout flow.

## Disclaimer

Use this project at your own risk.

This repository modifies Windows installation behavior and is experimental. No warranty is provided, and the maintainers take no responsibility for broken installs, data loss, boot issues, unsupported configurations, or any other damage caused by using it.

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
4. Choose local account details
5. Pick optional tweaks and apps
6. Generate `autounattend.xml`
7. Stage post-install payload
8. Launch Windows Setup with the generated configuration
9. Resume post-install customization after first login

## Profiles

- `Competitive`
- `FiveM`
- `Streamer`
- `Creator`

## Current state

This repository currently contains the first CLI scaffold for the installer experience.

It is intended to work alongside:
[win11-gaming-loadout](https://github.com/LordM8YT/win11-gaming-loadout)

## Setup Takeover Roadmap

The long-term goal is to hide as much of the stock Windows setup experience as possible without replacing the Microsoft installation engine itself.

Current direction:

1. Collect install choices in our own CLI flow
2. Generate unattended setup and payload config
3. Reduce OOBE and account-setup noise
4. Hand off into Windows installation
5. Resume with our own first-logon experience

Planned phases for a deeper takeover:

1. Phase 1: Better orchestration
   Add more installer-side options for disk layout, machine identity, profiles, and post-install modules.
2. Phase 2: Stronger handoff
   Push more setup choices into unattended configuration so less of stock OOBE is visible.
3. Phase 3: Preinstall environment
   Boot into a custom WinPE-based launcher that gathers choices before Windows setup runs.
4. Phase 4: Setup masking
   Launch Microsoft setup behind our own interface and treat it as the installation engine rather than the visible product.
5. Phase 5: Full branded flow
   Merge preinstall selection, unattended deployment, and post-install loadout into one continuous custom experience.

What 100% removal of visible Windows setup would require:

- A custom WinPE frontend
- Custom disk and edition handling
- Reliable unattended deployment
- Automatic first-boot handoff
- Ongoing maintenance for new Windows releases

That is possible in theory, but it is a much larger and more fragile project than the current installer layer.

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
