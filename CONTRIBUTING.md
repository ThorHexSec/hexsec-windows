# Contributing

Thank you for contributing to HexSec Windows.

## Principles

1. Keep winget package IDs in `configs/packages/*.txt`. Do not hardcode lists in Ansible.
2. Prefer winget. Use `pip:` only when winget has no suitable package. `pip:` must install unelevated (user scope).
3. Document every package-set change in `README.md` and `CHANGELOG.md`.
4. Privacy / registry logic belongs in `lib/Privacy.ps1` and `docs/PRIVACY.md` — not under `configs/packages/`.
5. Keep this project self-contained. Do not reference unrelated repositories in docs or comments.
6. Follow [Semantic Versioning](https://semver.org/): breaking changes bump MAJOR; compatible features bump MINOR; fixes bump PATCH.

## Workflow

```powershell
.\install.ps1 -DryRun -Module <name>
.\tests\test-structure.sh   # from Git Bash or Linux
```

1. Run dry-run for affected modules.  
2. Update docs when behaviour or package lists change.  
3. Add a CHANGELOG entry under an Unreleased or version section.  
4. Open a pull request with a clear summary.
