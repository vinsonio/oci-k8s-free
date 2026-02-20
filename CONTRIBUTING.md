# Contributing to Free OCI K8S

We love your input! We want to make contributing to this project as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features

## Our Development Process

1. **Fork the repo** and create your branch from `main`.
2. **If you've added code** that should be tested, add tests.
3. **If you've changed APIs**, update the documentation.
4. **Ensure the test suite passes**.
5. **Make sure your code lints**.
6. **Follow Conventional Commits** for your commit messages (see below).
7. **Issue that pull request!**

## Conventional Commits

This project uses **Conventional Commits** for automated versioning and changelog generation via [release-please](https://github.com/googleapis/release-please).

### Commit Message Format

Your commit messages should follow this format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: A new feature (triggers minor version bump)
- **fix**: A bug fix (triggers patch version bump)
- **docs**: Documentation changes only
- **style**: Changes that don't affect code meaning (formatting, whitespace, etc.)
- **refactor**: Code changes that neither fix bugs nor add features
- **perf**: Code changes that improve performance
- **test**: Adding or updating tests
- **chore**: Changes to build process, dependencies, etc.

**BREAKING CHANGE**: Add this in the footer to trigger a major version bump

```
BREAKING CHANGE: description of breaking change
```

### Examples

```
feat(kubernetes): add auto-scaling support to worker nodes

Add support for cluster autoscaler to scale worker nodes
based on demand within free-tier limits.

Fixes #42
```

```
fix(networking): correct security list rules for pod traffic

Allow bidirectional traffic on port 443 for pod-to-pod communication.
```

```
docs: update Always-Free resources guide with pricing changes
```

## Any contributions you make will be under the MIT Software License

In short, when you submit code changes, your submissions are understood to be under the same [MIT License](LICENSE) that covers the project. Feel free to contact the maintainers if that's a concern.

## Report bugs using GitHub's issues

We use GitHub issues to track public bugs. Report a bug by opening a new issue; it's that easy!

## License

By contributing, you agree that your contributions will be licensed under its MIT License.
