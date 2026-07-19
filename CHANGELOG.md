# Changelog

All notable changes to **HexSec Windows** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.1] — 2026-07-19

### Added

- Productivity: **Yaak** (`Yaak.app`), **Windows App** (`Microsoft.WindowsApp`).
- Spotify and Yaak install **unelevated** (`--scope user`) so elevated winget succeeds reliably.

### Fixed

- **Microsoft.PowerShell** no longer forced with `--scope machine` (that caused uninstall/reinstall loops).
- All winget packages: skip when already installed (`winget list` / `pwsh` on PATH for PowerShell 7) before calling `winget install`.

## [1.2.0] — 2026-07-19

### Added

- **Starship** (`Starship.Starship`) as primary PowerShell prompt; Night City `starship.toml` via module `dotfiles`.
- Media: **VLC** (`VideoLAN.VLC`), **K-Lite Codec Pack Mega** (`CodecGuide.K-LiteCodecPack.Mega`).

### Changed

- MongoDB GUI: `MongoDB.Compass` → **`MongoDB.Compass.Community`**.
- PowerShell profile prefers Starship; Oh My Posh Night City remains as fallback.

## [1.1.1] — 2026-07-19

### Added

- Windows Terminal **Night City** color scheme aligned with HexSec macOS Ghostty (`configs/dotfiles/windows-terminal-*.json`).
- Module `dotfiles` merges scheme + profile defaults (opacity 86%, acrylic, JetBrainsMono Nerd 13) into `settings.json` and deploys a Fragments file.

## [1.1.0] — 2026-07-19

### Added

- Module **`dotfiles`**: PowerShell 7 profile + Oh My Posh **Night City** theme (0xH3xS3C).
- Sources under `configs/dotfiles/`; installer in `lib/Dotfiles.ps1` + `scripts/Install-Dotfiles.ps1`.
- Docs: `docs/dotfiles/` and `docs/modules/dotfiles.md`.

## [1.0.4] — 2026-07-19

### Fixed

- **Claude Code** (`Anthropic.ClaudeCode`) and **Codex** (`OpenAI.Codex`) install **unelevated** with `--scope user`. If winget fails, fall back to the official native installer (`claude.ai/install.ps1`) and `npm install -g @openai/codex` respectively.

## [1.0.3] — 2026-07-19

### Fixed

- `pip:*` packages (checkov, Ansible, etc.) install **unelevated** into the interactive user profile even when `install.ps1` runs as Administrator. Prefer `uv tool install`; fall back to `python -m pip install --user`.

## [1.0.2] — 2026-07-19

### Removed

- Scoop support (`scoop:` prefixes, bootstrap, `-BootstrapScoop`). Package installs use **winget** only, with `pip:` reserved for tools without a suitable winget ID.

## [1.0.1] — 2026-07-19

### Changed

- Docker Desktop is **Windows-only** (Hyper-V). WSL is not used and is not part of the profile.
- Removed `-EnableWsl` from `install.ps1` / `Install-All.ps1` and Ansible vars.
- Documentation updated: no WSL install steps; Docker troubleshooting points to Hyper-V.

## [1.0.0] — 2026-07-19

### Added

- Initial stable release of HexSec Windows for Windows 11 Pro.
- Full and modular installer (`install.ps1`) with dry-run support.
- Profile `developer-platform` with privacy-first hardening.
- Modules: privacy, base, vcredist (x64+x86), shell, fonts, browsers, languages (.NET 10, JDK 25 LTS), databases (WAMP, MongoDB, PostgreSQL, SQLite), ides, containers (OpenLens), cloud-iac (OpenTofu default), cyber, productivity, media, virt, gaming (Steam + RetroArch).
- Privacy hardening: telemetry reduction, Sticky Keys off, Explorer Recents off, Copilot uninstall + block policies.
- Ansible adapter playbooks that delegate to PowerShell (single source of truth for packages).
- Structure tests (`tests/test-structure.sh`).
- Documentation: README, MODULES, PRIVACY, CONTRIBUTING, LICENSE.

[1.0.4]: CHANGELOG.md
[1.0.3]: CHANGELOG.md
[1.0.2]: CHANGELOG.md
[1.0.1]: CHANGELOG.md
[1.0.0]: CHANGELOG.md
