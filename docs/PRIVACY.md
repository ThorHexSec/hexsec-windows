# Privacy module

Applied by `lib/Privacy.ps1` via:

```powershell
.\install.ps1 -Module privacy
.\scripts\Set-Privacy.ps1
```

This is **configuration hardening**, not a winget package list. There is no `configs/packages/privacy.txt`.

## What it does

| Area | Actions |
|------|---------|
| Telemetry / diagnostics | `AllowTelemetry = 0`, feedback off, advertising ID off, tailored experiences off |
| Activity / location | Activity History off, location deny |
| Speech / input | Online speech off, inking/typing personalization restricted |
| Search / tips | Cortana / web search off, Windows tips / consumer features off |
| Error reporting | Windows Error Reporting disabled |
| Accessibility | Sticky Keys, Filter Keys, Toggle Keys, Mouse Keys hotkeys off |
| File Explorer | Recents / frequent folders off; Recent folder cleared |
| Copilot | Uninstall (winget + Appx) + policies to block reinstall |

## Implementation

| File | Role |
|------|------|
| `lib/Privacy.ps1` | Registry / policy / uninstall logic |
| `scripts/Set-Privacy.ps1` | Thin wrapper → `install.ps1 -Module privacy` |
| `README.md` § privacy | User-facing package/tables overview |

## Notes

- Requires Administrator for machine policies and Copilot Appx removal.
- Sign out or reboot after applying.
- On Windows 11 Pro, Microsoft may still enforce a minimum diagnostic floor.
- Re-run after major Windows upgrades if Copilot or Recents return.
