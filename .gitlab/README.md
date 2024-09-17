# Iterating your Tinybird data projects with a GitLab repository

Follow the [`Working with version control`](https://www.tinybird.co/docs/production/working-with-version-control) guide, which explains how to set up your GitLab CI for iterating your Tinybird data project.

TL;DR: run `tb init --git` from your main git branch, making sure the command succeeds.

A new ENV variable `TB_ADMIN_TOKEN` will be needed in your repository.

> Visit `Settings >> CI/CD >> Variables` section, and "Add variable" 

It's recommended that you build your CI/CD pipeline based on our [ci_cd.yaml](https://github.com/tinybirdco/ci/blob/main/.gitlab/ci_cd.yml) template file.

If you want to include the provided `ci_cd.yaml` template into your GitLab pipeline you can do next:

```yml
# include latest release, to avoid the dependency you can just copy the jobs and paste them into your GitLab pipeline, it's just tinybird-cli commands and shell script
include: "https://raw.githubusercontent.com/tinybirdco/ci/v4.0.1/.gitlab/ci_cd.yaml"

variables:
  # User your Tinybird API region endpoint: https://www.tinybird.co/docs/api-reference/overview#regions-and-endpoints
  # You can copy it from the region drop down in the Tinybird UI
  TB_HOST: "https://api.tinybird.co"
  TB_ADMIN_TOKEN: $TB_ADMIN_TOKEN
  # this is the folder where your Tinybird data project is, change it to your folder. If it's in the root just use '.'
  DATA_PROJECT_DIR: tinybird

deploy_ci:
  extends: .tb_deploy_ci
  rules:
    # runs on merge request: it creates a new Tinybird Branch and deploy changed Datafiles (obtained with a git diff)
    - if: $CI_MERGE_REQUEST_ID
      changes:
        # These are references to the DATA_PROJECT_DIR, change them accordingly
        - tinybird/*
        - tinybird/**/*

test_ci:
  extends: .tb_test
  needs: ["deploy_ci"]
  rules:
    # runs on merge request: it runs tests if any in the MR
    - if: $CI_MERGE_REQUEST_ID
      changes:
        - tinybird/*
        - tinybird/**/*

cleanup_ci:
  extends: .tb_cleanup_ci_branch
  rules:
    # runs on merge, it removes the temporary Tinybird Branch
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      when: always
      changes:
        - tinybird/*
        - tinybird/**/*

deploy_main:
  extends: .tb_deploy_main
  rules:
    # runs on merge: Runs the same deployment as `deploy_ci` but in the main Workspace instead of a Tinybird Branch
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      changes:
        - tinybird/*
        - tinybird/**/*
```


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
