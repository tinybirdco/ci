# Iterating your Tinybird data projects with a GitHub repository

These are the steps to follow:

1. Define these CI/CD variables in your repository:

    - `ADMIN_TOKEN` (required): the admin token from your Tinybird workspace
    - `TB_HOST` (optional): in case your Tinybird workspace isn't in EU region
    - `DATA_PROJECT_DIR` (optional): in case your data project is located in a folder and not in the main root

> You can add them in the `Settings >> Secrets and variables >> Actions` and create a "New repository secret" 

2. Follow the [`Working with git`](working_with_git_guide_url) guide
3. Done 🎉


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

[working_with_git_guide_url]: https://www.tinybird.co/docs/guides/working-with-git.html