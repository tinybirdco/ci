# Iterating your Tinybird data projects with a GitLab repository

These are the steps to follow:

1. Define these CI/CD variables in your repository:

    - `ADMIN_TOKEN` (required): the admin token from your Tinybird workspace
    - `TB_HOST` (optional): in case your Tinybird workspace isn't in EU region
    - `DATA_PROJECT_DIR` (optional): in case your data project is located in a folder and not in the main root

> You can add them in the `Settings >> CI/CD >> Variables` section, and "Add variable"

2. Follow the [`Working with git`](working_with_git_guide_url) guide
3. Done 🎉


## Snippets

These are some snippets to include in your GitLab CI configuration file for improving your developer experience:

### Pre-commit formatting

```yml
pre-commit:
  stage: test
  image: registry.gitlab.com/winny/pre-commit-docker:latest
  variables:
    PRE_COMMIT_HOME: .pre-commit-cache
  cache:
    - key:
        files: [.pre-commit-config.yaml]
      paths: [.pre-commit-cache]
  script:
    - tb fmt --yes --line-length 100
```


[working_with_git_guide_url]: https://www.tinybird.co/docs/guides/working-with-git.html