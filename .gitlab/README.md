# Iterating your Tinybird data projects with a GitLab repository

Follow the [`Working with version control`](https://www.tinybird.co/docs/production/working-with-version-control) guide, which explains how to set up your GitLab CI for iterating your Tinybird data project.
A new ENV variable `TB_ADMIN_TOKEN` will be needed in your repository.

> Visit `Settings >> CI/CD >> Variables` section, and "Add variable" 

If a tailored CI/CD solution is needed, take a look at our [ci_cd.yml](https://github.com/tinybirdco/ci/blob/main/.gitlab/ci_cd.yml) file.


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
