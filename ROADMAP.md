# Roadmap

## Goal

Turn `win11-loadout-installer` into a custom installer frontend for Windows 11 that minimizes the visible stock setup flow while still using Microsoft's installation engine under the hood.

## Guiding principle

Do not replace Windows installation logic unless absolutely necessary.

Prefer:

- collecting choices ourselves
- generating configuration ourselves
- handing off to Windows for the heavy lifting
- taking over again immediately after first boot

## Phases

### Phase 1: Installer orchestration

- CLI-based installer flow
- ISO selection
- edition selection
- profile selection
- local account setup
- handoff into `win11-gaming-loadout`

### Phase 2: OOBE reduction

- more complete `autounattend.xml`
- local account by default
- reduced Microsoft account prompts
- more reliable first-logon execution

### Phase 3: Profile-aware deployment

- pass selected profile directly into the installed system
- preseed app/module choices
- preseed desktop modules such as Rainmeter

### Phase 4: Preinstall takeover

- boot into a custom WinPE launcher
- gather settings before Windows Setup
- own the visible installer experience before deployment begins

### Phase 5: Branded setup masking

- treat Windows Setup as a backend process
- minimize or hide stock setup screens where possible
- present a more continuous custom installer experience

### Phase 6: Disk and deployment control

- disk selection
- partition layout
- more advanced install targeting
- safer validation before destructive actions

## Risks

- Windows updates can change setup behavior
- unattended behavior can differ between builds
- WinPE and deployment work is easy to break
- full takeover raises maintenance cost significantly

## Non-goals for now

- replacing the entire Microsoft install engine
- bypassing licensing or activation
- unsafe low-level hacks that are hard to maintain
