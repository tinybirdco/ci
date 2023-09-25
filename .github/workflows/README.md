# Iterating your Tinybird data projects with a GitHub repository

Please, follow the [`Working with git`](https://www.tinybird.co/docs/guides/working-with-git.html) guide. It will setup automatically your GitHub workflow for iterating your Tinybird data project.
A new secret key `TB_ADMIN_TOKEN` will be needed in your repository.

> Visit `Settings >> Secrets and variables >> Actions` section and create a "New repository secret" 

In case a tailored CI/CD solution is needed, take a look at our [ci.yml](https://github.com/tinybirdco/ci/tree/main/.github/workflows/ci.yml) and [cd.yml](https://github.com/tinybirdco/ci/tree/main/.github/workflows/cd.yml) files.

## Snippets

These are some snippets to include in your GitHub workflow configuration file for improving your developer experience:

### Pre-commit formatting

```yml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: check-yaml
      - id: end-of-file-fixer
      - id: trailing-whitespace
  - repo: local
    hooks:
      - id: tb-fmt
        name: tb fmt
        entry: tb fmt --yes --line-length 100
        language: system
        files: '\.(incl|pipe|datasource)$'
```