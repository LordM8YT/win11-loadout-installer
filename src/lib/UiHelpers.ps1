function Write-Section {
    param([string]$Title)

    Write-Host ""
    Write-Host "== $Title ==" -ForegroundColor Cyan
}

function Show-Menu {
    param(
        [string]$Title,
        [string[]]$Options
    )

    Write-Section $Title

    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host ("[{0}] {1}" -f ($i + 1), $Options[$i])
    }

    while ($true) {
        $choice = Read-Host "Velg et nummer"
        $parsed = 0
        if ([int]::TryParse($choice, [ref]$parsed)) {
            if ($parsed -ge 1 -and $parsed -le $Options.Count) {
                return $parsed - 1
            }
        }

        Write-Host "Ugyldig valg. Proev igjen." -ForegroundColor Yellow
    }
}

function Read-YesNo {
    param(
        [string]$Prompt,
        [bool]$Default = $true
    )

    $suffix = if ($Default) { "[Y/n]" } else { "[y/N]" }

    while ($true) {
        $value = Read-Host "$Prompt $suffix"
        if ([string]::IsNullOrWhiteSpace($value)) {
            return $Default
        }

        switch ($value.Trim().ToLowerInvariant()) {
            "y" { return $true }
            "yes" { return $true }
            "n" { return $false }
            "no" { return $false }
        }

        Write-Host "Skriv y eller n." -ForegroundColor Yellow
    }
}

function Read-OptionalText {
    param(
        [string]$Prompt,
        [string]$Default = ""
    )

    $value = Read-Host $Prompt
    if ([string]::IsNullOrWhiteSpace($value)) {
        return $Default
    }

    return $value.Trim()
}

function Read-RequiredText {
    param([string]$Prompt)

    while ($true) {
        $value = Read-Host $Prompt
        if (-not [string]::IsNullOrWhiteSpace($value)) {
            return $value.Trim()
        }

        Write-Host "Dette feltet kan ikke vaere tomt." -ForegroundColor Yellow
    }
}
