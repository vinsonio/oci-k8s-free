# Conventional Commits Quick Reference

**Format**: `<type>(<scope>): <subject>`

## Quick Examples

```bash
# Feature
git commit -m "feat(kubernetes): add auto-scaling support"

# Bug fix
git commit -m "fix(networking): correct VCN route table"

# Docs (no version bump)
git commit -m "docs: add architecture diagram"

# Breaking change (major version)
git commit -m "feat(variables)!: rename all variables

BREAKING CHANGE: See MIGRATION.md for details"
```

## Commit Types

| Type       | Purpose     | Version |
| ---------- | ----------- | ------- |
| `feat`     | Feature     | Minor ↑ |
| `fix`      | Bug fix     | Patch ↑ |
| `docs`     | Docs        | —       |
| `style`    | Formatting  | —       |
| `refactor` | Restructure | —       |
| `perf`     | Performance | —       |
| `test`     | Tests       | —       |
| `chore`    | Maintenance | —       |

## Scopes

- `kubernetes` - OKE cluster
- `networking` - VCN/subnets
- `bastion` - Bastion module
- `vpn` - VPN module
- `observability` - Logging/monitoring
- `docs` - Documentation
- `ci` - GitHub Actions
- `terraform` - Provider/version

## Breaking Changes

Use `!` or add footer:

```bash
# Option 1: Add ! after scope
git commit -m "feat(api)!: restructure outputs"

# Option 2: Add BREAKING CHANGE footer
git commit -m "feat: change variable format

BREAKING CHANGE: Vars renamed (see MIGRATION.md)"
```

**Result**: Version jumps to next major (0.1.0 → 1.0.0)

## Tips

✅ Use lowercase  
✅ Use imperative mood ("add feature" not "adds feature")  
✅ Don't end with period  
✅ Reference issues: "fix(vpn): issue #42"  
✅ Keep subject under 50 chars

## Resources

- Full guide: [docs/RELEASE-MANAGEMENT.md](docs/RELEASE-MANAGEMENT.md)
- Setup: [RELEASE_PLEASE_SETUP.md](RELEASE_PLEASE_SETUP.md)
- Learn: [conventionalcommits.org](https://www.conventionalcommits.org/)
