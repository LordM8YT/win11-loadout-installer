[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "lib\UiHelpers.ps1")
. (Join-Path $PSScriptRoot "lib\ProfileCatalog.ps1")

$script:DependencyRepoUrl = "https://github.com/LordM8YT/win11-gaming-loadout.git"
$script:DependencyRoot = (Join-Path $PSScriptRoot "..\deps\win11-gaming-loadout")

function Test-IsElevated {
    $null = & fltmc.exe 2>$null
    return ($LASTEXITCODE -eq 0)
}

function Ensure-Administrator {
    if (-not (Test-IsElevated)) {
        throw "Dette scriptet maa kjores som administrator for aa kunne lese editions og starte ISO-builderen."
    }
}

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
        [int]$EditionIndex,
        [string]$ComputerName,
        [string]$LocalUsername,
        [bool]$HasLocalPassword,
        [bool]$UseDebloat,
        [bool]$UseApps
    )

    return [pscustomobject]@{
        IsoPath = $IsoPath
        Profile = $Profile.Key
        EditionIndex = $EditionIndex
        ComputerName = $ComputerName
        LocalUsername = $LocalUsername
        HasLocalPassword = $HasLocalPassword
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
    Write-Host "Edition:  $($Plan.EditionIndex)"
    Write-Host "PC-navn:  $($Plan.ComputerName)"
    Write-Host "Bruker:   $($Plan.LocalUsername)"
    Write-Host "Passord:  $(if ($Plan.HasLocalPassword) { 'Ja' } else { 'Nei' })"
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

function Ensure-DependencyRepo {
    Write-Section "Loadout dependency"

    $depsDir = Split-Path -Path $script:DependencyRoot -Parent
    if (-not (Test-Path -LiteralPath $depsDir)) {
        New-Item -ItemType Directory -Path $depsDir | Out-Null
    }

    if (Test-Path -LiteralPath (Join-Path $script:DependencyRoot ".git")) {
        Write-Host "Oppdaterer win11-gaming-loadout..."
        git -C $script:DependencyRoot pull --ff-only
    }
    else {
        Write-Host "Laster ned win11-gaming-loadout..."
        git clone $script:DependencyRepoUrl $script:DependencyRoot
    }

    $builderPath = Join-Path $script:DependencyRoot "Build-GamingISO.ps1"
    if (-not (Test-Path -LiteralPath $builderPath)) {
        throw "Fant ikke Build-GamingISO.ps1 i dependency-repoet."
    }

    return (Resolve-Path -LiteralPath $builderPath).Path
}

function Get-WindowsEditions {
    param([string]$IsoPath)

    $diskImage = $null
    try {
        $diskImage = Mount-DiskImage -ImagePath $IsoPath -PassThru
        $volume = $diskImage | Get-Volume
        $drive = "$($volume.DriveLetter):"
        $wimPath = Join-Path $drive "sources\install.wim"
        $esdPath = Join-Path $drive "sources\install.esd"
        $imagePath = if (Test-Path -LiteralPath $wimPath) { $wimPath } else { $esdPath }

        if (-not (Test-Path -LiteralPath $imagePath)) {
            throw "Fant ikke install.wim eller install.esd i ISO-en."
        }

        return Get-WindowsImage -ImagePath $imagePath | Select-Object ImageIndex, ImageName, Architecture
    }
    finally {
        if ($diskImage) {
            Dismount-DiskImage -ImagePath $IsoPath -ErrorAction SilentlyContinue
        }
    }
}

function Select-EditionIndex {
    param([string]$IsoPath)

    $editions = Get-WindowsEditions -IsoPath $IsoPath

    Write-Section "Tilgjengelige editions"
    foreach ($edition in $editions) {
        Write-Host ("[{0}] {1} ({2})" -f $edition.ImageIndex, $edition.ImageName, $edition.Architecture)
    }

    while ($true) {
        $value = Read-Host "Skriv edition index"
        $parsed = 0
        if ([int]::TryParse($value, [ref]$parsed)) {
            if ($editions.ImageIndex -contains $parsed) {
                return $parsed
            }
        }

        Write-Host "Ugyldig edition index. Velg et av numrene over." -ForegroundColor Yellow
    }
}

function Start-LoadoutBuild {
    param(
        [string]$BuilderPath,
        [pscustomobject]$Plan,
        [string]$LocalPassword
    )

    Write-Section "Starter builder"
    Write-Host "Bruker repo: $script:DependencyRoot"
    $workingRoot = Join-Path $script:DependencyRoot "work"
    $outputRoot = Join-Path $script:DependencyRoot "output"

    $arguments = @(
        "-ExecutionPolicy", "Bypass",
        "-NoProfile",
        "-File", $BuilderPath,
        "-IsoPath", $Plan.IsoPath,
        "-EditionIndex", $Plan.EditionIndex,
        "-WorkingRoot", $workingRoot,
        "-OutputRoot", $outputRoot,
        "-ComputerName", $Plan.ComputerName,
        "-LocalUsername", $Plan.LocalUsername
    )

    if (-not [string]::IsNullOrWhiteSpace($LocalPassword)) {
        $arguments += @("-LocalPassword", $LocalPassword)
    }

    & powershell.exe @arguments
}

Show-Banner

try {
    Ensure-Administrator
    $isoPath = Select-IsoPath
    $editionIndex = Select-EditionIndex -IsoPath $isoPath
    $profile = Select-Profile
    Write-Section "Lokal konto"
    $computerName = Read-OptionalText -Prompt "Maskinnavn (tom = GAMINGLAB-PC)" -Default "GAMINGLAB-PC"
    $localUsername = Read-RequiredText -Prompt "Lokalt brukernavn"
    $localPassword = Read-OptionalText -Prompt "Lokalt passord (tomt = ingen passord)" -Default ""
    $useDebloat = Read-YesNo -Prompt "Aktiver debloat og stoyreduksjon?" -Default $true
    $useApps = Read-YesNo -Prompt "Installer kuraterte apper etter installasjon?" -Default $true

    $plan = Build-Plan -IsoPath $isoPath -Profile $profile -EditionIndex $editionIndex -ComputerName $computerName -LocalUsername $localUsername -HasLocalPassword (-not [string]::IsNullOrWhiteSpace($localPassword)) -UseDebloat $useDebloat -UseApps $useApps
    Show-Plan -Plan $plan

    if (-not (Read-YesNo -Prompt "Last ned eller oppdater loadout-repoet og start bygging naa?" -Default $true)) {
        Write-Host "Avbrutt." -ForegroundColor Yellow
        exit 0
    }

    $savedPlan = Save-Plan -Plan $plan
    $builderPath = Ensure-DependencyRepo
    Write-Section "Ferdig"
    Write-Host "Plan lagret i: $savedPlan" -ForegroundColor Green
    Start-LoadoutBuild -BuilderPath $builderPath -Plan $plan -LocalPassword $localPassword
}
catch {
    Write-Host ""
    Write-Host "Feil: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
