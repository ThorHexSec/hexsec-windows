#!/usr/bin/env bash
# Structural validation — does not call winget.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ok=0
fail=0
pass() { echo "PASS  $1"; ok=$((ok + 1)); }
fail_msg() { echo "FAIL  $1"; fail=$((fail + 1)); }

[[ -f "$ROOT/install.ps1" ]] && pass "install.ps1" || fail_msg "install.ps1"
grep -q 'HexSecWinVersion = "1.0.3"' "$ROOT/lib/Common.ps1" && pass "version 1.0.3" || fail_msg "version not 1.0.3"
grep -q '\*\*1.0.3\*\*' "$ROOT/README.md" && pass "README version 1.0.3" || fail_msg "README version"
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

grep -q 'Invoke-HexSecUnelevatedScript' "$ROOT/lib/Common.ps1" && pass "unelevated pip helper" || fail_msg "missing unelevated pip helper"
grep -q 'trustlevel:0x20000' "$ROOT/lib/Common.ps1" && pass "medium-integrity de-elevation" || fail_msg "missing runas trustlevel"
grep -q 'uv tool install' "$ROOT/lib/Common.ps1" && pass "uv tool install for pip:*" || fail_msg "missing uv tool install"

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
