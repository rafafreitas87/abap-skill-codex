# Local ARC-1 Codex Setup

Use this setup when Codex should operate SAP ABAP through ARC-1 from a local Windows machine.

## Files

Versioned in this repository:

- `scripts/codex-arc1.ps1` - PowerShell helper for ARC-1 calls.
- `templates/configSap.env.example` - template for local SAP connection settings.

Local only, never committed:

- `C:\Users\<user>\.codex\configSap.env.txt` - real SAP URL, client, user, package, and transport.
- `SAP_PASSWORD` - stored only as a user environment variable or transient process variable.

## Local Config

Create:

```powershell
Copy-Item .\templates\configSap.env.example $env:USERPROFILE\.codex\configSap.env.txt
notepad $env:USERPROFILE\.codex\configSap.env.txt
```

Example:

```text
SAP_URL=https://20.62.45.108:44300
SAP_CLIENT=100
SAP_USER=MGLDEV01
SAP_INSECURE=true

SAP_ALLOW_WRITES=false
SAP_ALLOWED_PACKAGES=ZTRF01005
SAP_ALLOWED_TRANSPORTS=S4HK903338
```

Do not put `SAP_PASSWORD` in this file.

## Password

Set the password for the current Windows user:

```powershell
[Environment]::SetEnvironmentVariable("SAP_PASSWORD", "<password>", "User")
```

Remove it after the session or lab work:

```powershell
[Environment]::SetEnvironmentVariable("SAP_PASSWORD", $null, "User")
```

## Read-Only Check

```powershell
.\scripts\codex-arc1.ps1 call SAPRead --arg type=SYSTEM --arg name=SYSTEM
```

Or show the effective ARC-1 policy:

```powershell
.\scripts\codex-arc1.ps1
```

## Writes

ABAP writes go directly to the SAP server. Keep writes off until package and transport are confirmed.

Create from a payload file:

```powershell
.\scripts\codex-arc1.ps1 -AllowWrites write .\payloads\create-domain.json
```

Activate an object:

```powershell
.\scripts\codex-arc1.ps1 -AllowWrites activate DOMA ZRFT_DOMA1
```

The helper refuses `SAPWrite` and `SAPActivate` unless `-AllowWrites` is present.
