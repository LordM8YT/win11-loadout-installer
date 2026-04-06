[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "lib\UiHelpers.ps1")
. (Join-Path $PSScriptRoot "lib\ProfileCatalog.ps1")

function Show-Banner {
    Clear-Host
    Write-Host "Win11 Loadout Installer" -ForegroundColor Green
    Write-Host "Terminal-first custom installer layer for Windows 11"
}

function Select-IsoPath {
    Write-Section "ISO"
    $isoPath = Read-Host "Skriv inn full sti til Windows 11 ISO"

    if (-not (Test-Path -LiteralPath $isoPath)) {
        throw "Fant ikke ISO-filen: $isoPath"
    }

    return (Resolve-Path -LiteralPath $isoPath).Path
}

function Select-Profile {
    $profiles = Get-LoadoutProfiles
    $options = foreach ($profile in $profiles) {
        "{0} - {1}" -f $profile.Label, $profile.Description
    }

    $selectedIndex = Show-Menu -Title "Velg loadout-profil" -Options $options
    return $profiles[$selectedIndex]
}

function Build-Plan {
    param(
        [string]$IsoPath,
        [pscustomobject]$Profile,
        [bool]$UseDebloat,
        [bool]$UseApps
    )

    return [pscustomobject]@{
        IsoPath = $IsoPath
        Profile = $Profile.Key
        Debloat = $UseDebloat
        Apps = $UseApps
        CreatedAt = (Get-Date).ToString("s")
    }
}

function Show-Plan {
    param([pscustomobject]$Plan)

    Write-Section "Oppsummering"
    Write-Host "ISO:      $($Plan.IsoPath)"
    Write-Host "Profil:   $($Plan.Profile)"
    Write-Host "Debloat:  $($Plan.Debloat)"
    Write-Host "Apps:     $($Plan.Apps)"
}

function Save-Plan {
    param([pscustomobject]$Plan)

    $outputDir = Join-Path $PSScriptRoot "..\output"
    if (-not (Test-Path -LiteralPath $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir | Out-Null
    }

    $planPath = Join-Path $outputDir "install-plan.json"
    $Plan | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $planPath -Encoding UTF8
    return (Resolve-Path -LiteralPath $planPath).Path
}

Show-Banner

try {
    $isoPath = Select-IsoPath
    $profile = Select-Profile
    $useDebloat = Read-YesNo -Prompt "Aktiver debloat og stoyreduksjon?" -Default $true
    $useApps = Read-YesNo -Prompt "Installer kuraterte apper etter installasjon?" -Default $true

    $plan = Build-Plan -IsoPath $isoPath -Profile $profile -UseDebloat $useDebloat -UseApps $useApps
    Show-Plan -Plan $plan

    if (-not (Read-YesNo -Prompt "Lagre planutkast for senere bygging?" -Default $true)) {
        Write-Host "Avbrutt." -ForegroundColor Yellow
        exit 0
    }

    $savedPlan = Save-Plan -Plan $plan
    Write-Section "Ferdig"
    Write-Host "Plan lagret i: $savedPlan" -ForegroundColor Green
    Write-Host "Neste steg er aa koble denne wizard-en til ISO-builderen og Windows Setup-handoff."
}
catch {
    Write-Host ""
    Write-Host "Feil: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
