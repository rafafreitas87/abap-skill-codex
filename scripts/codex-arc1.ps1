# ARC-1 helper for Codex/PowerShell local workflows.
# Loads a machine-local env file, injects SAP_PASSWORD from the User environment,
# and keeps writes disabled unless -AllowWrites is passed explicitly.

$ErrorActionPreference = 'Stop'

$allArgs = @($args)
$allowWrites = $false
$envFile = Join-Path $env:USERPROFILE '.codex\configSap.env.txt'
$passArgs = New-Object System.Collections.Generic.List[string]

for ($i = 0; $i -lt $allArgs.Count; $i++) {
    switch -Regex ($allArgs[$i]) {
        '^-AllowWrites$' {
            $allowWrites = $true
            continue
        }
        '^-EnvFile$' {
            if ($i + 1 -ge $allArgs.Count) {
                throw '-EnvFile requires a path.'
            }
            $i++
            $envFile = $allArgs[$i]
            continue
        }
        default {
            [void]$passArgs.Add($allArgs[$i])
        }
    }
}

function Import-Arc1EnvFile {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "ARC-1 env file not found: $Path"
    }

    Get-Content -LiteralPath $Path | ForEach-Object {
        $line = $_.Trim()
        if (-not $line -or $line.StartsWith('#') -or -not $line.Contains('=')) {
            return
        }

        $name, $value = $line.Split('=', 2)
        $name = $name.Trim()
        $value = $value.Trim().Trim('"')

        if ($name -match 'PASSWORD|TOKEN|SECRET') {
            throw "Refusing to load secret value from env file: $name"
        }

        [Environment]::SetEnvironmentVariable($name, $value, 'Process')
    }
}

function Require-WriteApproval {
    if (-not $allowWrites) {
        throw 'This ARC-1 operation can modify SAP. Re-run with -AllowWrites when package and transport are confirmed.'
    }
}

Import-Arc1EnvFile -Path $envFile

$userPassword = [Environment]::GetEnvironmentVariable('SAP_PASSWORD', 'User')
if (-not $env:SAP_PASSWORD -and $userPassword) {
    [Environment]::SetEnvironmentVariable('SAP_PASSWORD', $userPassword, 'Process')
}

if ($allowWrites) {
    [Environment]::SetEnvironmentVariable('SAP_ALLOW_WRITES', 'true', 'Process')
} else {
    [Environment]::SetEnvironmentVariable('SAP_ALLOW_WRITES', 'false', 'Process')
}

if (-not (Get-Command arc1 -ErrorAction SilentlyContinue)) {
    throw 'arc1 was not found on PATH. Install with: npm install -g arc-1'
}

if ($passArgs.Count -eq 0) {
    & arc1 config show
    exit $LASTEXITCODE
}

$command = $passArgs[0]

switch ($command) {
    'write' {
        Require-WriteApproval
        if ($passArgs.Count -lt 2) {
            throw 'Usage: codex-arc1.ps1 -AllowWrites write <payload.json>'
        }
        $payloadPath = $passArgs[1]
        if (-not (Test-Path -LiteralPath $payloadPath)) {
            throw "Payload file not found: $payloadPath"
        }
        & arc1 call SAPWrite --json $payloadPath
        exit $LASTEXITCODE
    }
    'activate' {
        Require-WriteApproval
        if ($passArgs.Count -lt 3) {
            throw 'Usage: codex-arc1.ps1 -AllowWrites activate <TYPE> <NAME>'
        }
        $type = $passArgs[1]
        $name = $passArgs[2]
        & arc1 call SAPActivate --arg "type=$type" --arg "name=$name"
        exit $LASTEXITCODE
    }
    default {
        if ($command -eq 'activate') {
            Require-WriteApproval
        }
        if ($command -eq 'call' -and $passArgs.Count -ge 2 -and $passArgs[1] -in @('SAPWrite', 'SAPActivate')) {
            Require-WriteApproval
        }
        & arc1 @passArgs
        exit $LASTEXITCODE
    }
}
