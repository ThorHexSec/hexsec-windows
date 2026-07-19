#!/usr/bin/env bash
# Structural validation — does not call winget.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ok=0
fail=0
pass() { echo "PASS  $1"; ok=$((ok + 1)); }
fail_msg() { echo "FAIL  $1"; fail=$((fail + 1)); }

[[ -f "$ROOT/install.ps1" ]] && pass "install.ps1" || fail_msg "install.ps1"
grep -q 'HexSecWinVersion = "1.2.1"' "$ROOT/lib/Common.ps1" && pass "version 1.2.1" || fail_msg "version not 1.2.1"
grep -q '\*\*1.2.1\*\*' "$ROOT/README.md" && pass "README version 1.2.1" || fail_msg "README version"
[[ -f "$ROOT/CHANGELOG.md" ]] && pass "CHANGELOG.md" || fail_msg "CHANGELOG.md"
grep -qi 'no WSL\|Windows-only\|Hyper-V' "$ROOT/README.md" && pass "Docker Windows-only docs" || fail_msg "missing Docker Windows-only note"
! grep -q 'EnableWsl' "$ROOT/install.ps1" && pass "EnableWsl removed" || fail_msg "EnableWsl still present"
[[ -f "$ROOT/lib/Common.ps1" ]] && pass "lib/Common.ps1" || fail_msg "Common.ps1"
[[ -f "$ROOT/README.md" ]] && pass "README.md" || fail_msg "README.md"
[[ -f "$ROOT/configs/profiles/developer-platform.yml" ]] && pass "profile" || fail_msg "profile"

[[ -f "$ROOT/lib/Privacy.ps1" ]] && pass "lib/Privacy.ps1" || fail_msg "Privacy.ps1"
[[ -f "$ROOT/docs/PRIVACY.md" ]] && pass "docs/PRIVACY.md" || fail_msg "PRIVACY.md"
[[ ! -f "$ROOT/configs/packages/privacy.txt" ]] && pass "no fake privacy package list" || fail_msg "privacy.txt must not live under packages/"

for m in base vcredist shell fonts browsers languages databases ides containers cloud-iac cloud-gcp iac-terraform cyber productivity media virt gaming; do
  [[ -f "$ROOT/configs/packages/${m}.txt" ]] && pass "packages/${m}.txt" || fail_msg "packages/${m}.txt"
done

for f in full.yml modules.yml; do
  [[ -f "$ROOT/ansible/playbooks/${f}" ]] && pass "ansible/${f}" || fail_msg "ansible/${f}"
done

# Gaming: Steam only — no extra stores as installable IDs
if grep -hE '^\s*[^#[:space:]]' "$ROOT/configs/packages/"*.txt | grep -qiE 'EpicGames|GOGGalaxy|HeroicGames'; then
  fail_msg "extra game stores found in package lists"
else
  pass "no Epic/GOG/Heroic in package lists"
fi

if grep -q 'Valve.Steam' "$ROOT/configs/packages/gaming.txt" \
  && grep -q 'Libretro.RetroArch' "$ROOT/configs/packages/gaming.txt"; then
  pass "Steam + RetroArch in gaming list"
else
  fail_msg "gaming must include Steam and RetroArch"
fi

if grep -qi 'WeMod' "$ROOT/configs/packages/gaming.txt"; then
  fail_msg "WeMod should be removed from gaming"
else
  pass "WeMod removed"
fi

grep -q 'RARLab.WinRAR' "$ROOT/configs/packages/base.txt" && pass "WinRAR in base" || fail_msg "WinRAR missing"
grep -q 'Microsoft.DotNet.SDK.10' "$ROOT/configs/packages/languages.txt" && pass ".NET SDK 10" || fail_msg ".NET SDK 10 missing"
grep -q 'Microsoft.VCRedist.2015+.x64' "$ROOT/configs/packages/vcredist.txt" \
  && grep -q 'Microsoft.VCRedist.2015+.x86' "$ROOT/configs/packages/vcredist.txt" \
  && pass "VC++ 2015+ x64+x86" || fail_msg "VC++ 2015+ x64/x86 missing"
grep -q 'Microsoft.VCRedist.2008.x86' "$ROOT/configs/packages/vcredist.txt" && pass "VC++ 2008 x86" || fail_msg "VC++ 2008 x86 missing"
grep -q 'EclipseAdoptium.Temurin.25.JDK' "$ROOT/configs/packages/languages.txt" && pass "JDK 25 LTS" || fail_msg "JDK 25 missing"
grep -q 'Anthropic.ClaudeCode' "$ROOT/configs/packages/ides.txt" && pass "Claude Code" || fail_msg "Claude Code missing"
grep -q 'OpenAI.Codex' "$ROOT/configs/packages/ides.txt" && pass "Codex" || fail_msg "Codex missing"
grep -q 'Vivaldi.Vivaldi' "$ROOT/configs/packages/browsers.txt" && pass "Vivaldi" || fail_msg "Vivaldi missing"
grep -q 'Oracle.VirtualBox' "$ROOT/configs/packages/virt.txt" && pass "VirtualBox" || fail_msg "VirtualBox missing"
grep -q 'SQLite.SQLite' "$ROOT/configs/packages/databases.txt" && pass "SQLite" || fail_msg "SQLite missing"
grep -q 'Disable-HexSecStickyKeys' "$ROOT/lib/Privacy.ps1" && pass "Sticky Keys function" || fail_msg "Sticky Keys missing"
grep -q 'AllowTelemetry' "$ROOT/lib/Privacy.ps1" && pass "telemetry policy" || fail_msg "telemetry missing"
grep -q 'StickyKeys' "$ROOT/lib/Privacy.ps1" && pass "StickyKeys registry" || fail_msg "StickyKeys reg missing"
grep -q 'Disable-HexSecExplorerRecents' "$ROOT/lib/Privacy.ps1" && pass "Explorer Recents" || fail_msg "Recents missing"
grep -q 'Remove-HexSecCopilot' "$ROOT/lib/Privacy.ps1" && pass "Copilot removal" || fail_msg "Copilot missing"
grep -q 'NoRecentDocsHistory' "$ROOT/lib/Privacy.ps1" && pass "NoRecentDocsHistory" || fail_msg "NoRecentDocsHistory missing"
grep -q 'TurnOffWindowsCopilot' "$ROOT/lib/Privacy.ps1" && pass "TurnOffWindowsCopilot" || fail_msg "TurnOffWindowsCopilot missing"

# Dotfiles (PowerShell 7 + Starship + Windows Terminal)
[[ -f "$ROOT/lib/Dotfiles.ps1" ]] && pass "lib/Dotfiles.ps1" || fail_msg "Dotfiles.ps1"
[[ -f "$ROOT/scripts/Install-Dotfiles.ps1" ]] && pass "Install-Dotfiles.ps1" || fail_msg "Install-Dotfiles.ps1"
[[ -f "$ROOT/configs/dotfiles/night-city.omp.json" ]] && pass "night-city.omp.json" || fail_msg "omp theme"
[[ -f "$ROOT/configs/dotfiles/starship.toml" ]] && pass "starship.toml" || fail_msg "starship.toml"
[[ -f "$ROOT/configs/dotfiles/Microsoft.PowerShell_profile.ps1" ]] && pass "pwsh profile" || fail_msg "pwsh profile"
[[ -f "$ROOT/configs/dotfiles/windows-terminal-night-city.json" ]] && pass "wt night-city scheme" || fail_msg "wt scheme"
[[ -f "$ROOT/configs/dotfiles/windows-terminal-fragment.json" ]] && pass "wt fragment" || fail_msg "wt fragment"
[[ -f "$ROOT/docs/dotfiles/README.md" ]] && pass "docs/dotfiles" || fail_msg "docs/dotfiles"
[[ -f "$ROOT/docs/dotfiles/profile.md" ]] && pass "docs profile" || fail_msg "docs profile"
[[ -f "$ROOT/docs/dotfiles/starship.md" ]] && pass "docs starship" || fail_msg "docs starship"
[[ -f "$ROOT/docs/dotfiles/oh-my-posh.md" ]] && pass "docs oh-my-posh" || fail_msg "docs oh-my-posh"
[[ -f "$ROOT/docs/dotfiles/windows-terminal.md" ]] && pass "docs windows-terminal" || fail_msg "docs windows-terminal"
[[ -f "$ROOT/docs/modules/dotfiles.md" ]] && pass "docs modules/dotfiles" || fail_msg "docs modules/dotfiles"
grep -q 'dotfiles' "$ROOT/install.ps1" && pass "dotfiles in install.ps1" || fail_msg "dotfiles missing from install"
grep -q 'Install-HexSecDotfiles' "$ROOT/lib/Dotfiles.ps1" && pass "Install-HexSecDotfiles" || fail_msg "Install-HexSecDotfiles"
grep -q 'Merge-HexSecWindowsTerminalSettings' "$ROOT/lib/Dotfiles.ps1" && pass "WT merge function" || fail_msg "WT merge"
grep -q 'NIGHT CITY' "$ROOT/configs/dotfiles/night-city.omp.json" && pass "Night City theme" || fail_msg "Night City theme"
grep -q 'palette = "night_city"' "$ROOT/configs/dotfiles/starship.toml" && pass "Starship Night City" || fail_msg "starship palette"
grep -q 'custom.docker' "$ROOT/configs/dotfiles/starship.toml" && pass "Starship docker module" || fail_msg "starship docker"
grep -q 'HEXSEC_IDENTITY' "$ROOT/configs/dotfiles/Microsoft.PowerShell_profile.ps1" && pass "profile identity" || fail_msg "profile identity"
grep -q 'starship init powershell' "$ROOT/configs/dotfiles/Microsoft.PowerShell_profile.ps1" && pass "starship init in profile" || fail_msg "starship init"
grep -q 'FCEE0A' "$ROOT/configs/dotfiles/night-city.omp.json" && pass "Night City chrome color" || fail_msg "theme colors"
grep -q '1E1E22' "$ROOT/configs/dotfiles/windows-terminal-night-city.json" && pass "WT Ghostty background" || fail_msg "WT bg"
grep -q '00F0FF' "$ROOT/configs/dotfiles/windows-terminal-night-city.json" && pass "WT Ghostty cyan" || fail_msg "WT cyan"
grep -q 'opacity' "$ROOT/lib/Dotfiles.ps1" && pass "WT opacity defaults" || fail_msg "WT opacity"
grep -q 'Starship.Starship' "$ROOT/configs/packages/base.txt" && pass "Starship winget" || fail_msg "Starship package"
grep -q 'VideoLAN.VLC' "$ROOT/configs/packages/media.txt" && pass "VLC" || fail_msg "VLC missing"
grep -q 'CodecGuide.K-LiteCodecPack.Mega' "$ROOT/configs/packages/media.txt" && pass "K-Lite Mega" || fail_msg "K-Lite missing"
grep -q 'MongoDB.Compass.Community' "$ROOT/configs/packages/databases.txt" && pass "Compass Community" || fail_msg "Compass Community"
if grep -qE '^MongoDB\.Compass$' "$ROOT/configs/packages/databases.txt"; then
  fail_msg "old MongoDB.Compass ID still present"
else
  pass "no non-Community Compass ID"
fi

grep -q 'Test-HexSecWingetPackageInstalled' "$ROOT/lib/Common.ps1" && pass "winget already-installed check" || fail_msg "missing installed check"
grep -q 'HexSecNoMachineScopeWingetIds' "$ROOT/lib/Common.ps1" && pass "no machine-scope list" || fail_msg "missing no-machine-scope"
grep -q 'Microsoft.PowerShell' "$ROOT/lib/Common.ps1" && grep -q 'HexSecNoMachineScopeWingetIds' "$ROOT/lib/Common.ps1" \
  && pass "PowerShell no machine scope" || fail_msg "PowerShell still forced machine scope"
grep -q 'Yaak.app' "$ROOT/configs/packages/productivity.txt" && pass "Yaak" || fail_msg "Yaak missing"
grep -q 'Microsoft.WindowsApp' "$ROOT/configs/packages/productivity.txt" && pass "Windows App" || fail_msg "Windows App missing"
grep -q 'Spotify.Spotify' "$ROOT/configs/packages/media.txt" && pass "Spotify" || fail_msg "Spotify missing"
grep -q 'Spotify.Spotify' "$ROOT/lib/Common.ps1" && grep -q 'Yaak.app' "$ROOT/lib/Common.ps1" \
  && pass "Spotify+Yaak user-scope" || fail_msg "Spotify/Yaak not user-scope"
grep -q '^Microsoft.PowerShell$' "$ROOT/configs/packages/base.txt" && pass "PowerShell exact ID" || fail_msg "PowerShell ID"

grep -q 'Invoke-HexSecUnelevatedScript' "$ROOT/lib/Common.ps1" && pass "unelevated pip helper" || fail_msg "missing unelevated pip helper"
grep -q 'trustlevel:0x20000' "$ROOT/lib/Common.ps1" && pass "medium-integrity de-elevation" || fail_msg "missing runas trustlevel"
grep -q 'uv tool install' "$ROOT/lib/Common.ps1" && pass "uv tool install for pip:*" || fail_msg "missing uv tool install"
grep -q 'Install-HexSecUserScopeCli' "$ROOT/lib/Common.ps1" && pass "user-scope CLI helper" || fail_msg "missing user-scope CLI helper"
grep -q 'Anthropic.ClaudeCode' "$ROOT/lib/Common.ps1" && grep -q 'OpenAI.Codex' "$ROOT/lib/Common.ps1" \
  && pass "Claude Code + Codex user-scope list" || fail_msg "Claude/Codex not in user-scope list"
grep -q 'claude.ai/install.ps1' "$ROOT/lib/Common.ps1" && pass "Claude native fallback" || fail_msg "Claude native fallback missing"
grep -q "@openai/codex" "$ROOT/lib/Common.ps1" && pass "Codex npm fallback" || fail_msg "Codex npm fallback missing"

for need in Wampserver.Wampserver MongoDB.Server PostgreSQL.PostgreSQL.16; do
  grep -q "$need" "$ROOT/configs/packages/databases.txt" && pass "databases has $need" || fail_msg "databases missing $need"
done

grep -qi 'Install everything' "$ROOT/README.md" \
  && grep -F '.\install.ps1' "$ROOT/README.md" \
  && pass "one-command install docs" || fail_msg "missing Install everything section"
if grep -RInE 'HexSec Arch|hexsec-arch|Arch Linux|pacman|gamer-platform' \
  --include='*.md' --include='*.txt' --include='*.ps1' --include='*.yml' \
  "$ROOT" 2>/dev/null | grep -v '/\.git/' | grep -v 'tests/test-structure.sh'; then
  fail_msg "cross-repo / Arch references found in docs or comments"
else
  pass "docs are Windows-only"
fi

echo "=== ${ok} passed, ${fail} failed ==="
[[ "$fail" -eq 0 ]]
