# Iterating your Tinybird data projects with a GitHub repository

We encourage you to follow the [`Working with git`](working_with_git_guide_url) guide for setting a proper GitHub workflow for iterating your Tinybird data project.

You will only need to define a secret key `ADMIN_TOKEN` in your repository.

> You can add them in the `Settings >> Secrets and variables >> Actions` section and create a "New repository secret" 

In case you want a tailored CI/CD solution, take a look to our [ci.yml](github_ci_file_url) and [cd.yml](github_cd_file_url) files.

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
[github_ci_file_url]: https://github.com/tinybirdco/ci/blob/main/github/workflows/ci.yml
[github_cd_file_url]: https://github.com/tinybirdco/ci/blob/main/github/workflows/cd.yml