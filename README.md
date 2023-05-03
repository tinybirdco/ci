<p>
  <a href="https://www.tinybird.co/join-our-slack-community"><img alt="Slack Status" src="https://img.shields.io/badge/slack-chat-1FCC83?style=flat&logo=slack"></a>
</p>

# CI Flows for Tinybird Projects

Collection of configuration files that enable CI flows for Tinybird projects. 

## Features

- Templates for popular CI tools like GitHub Actions and GitLab CI

## GitLab

1. Include external YAML file in your CI/CD jobs
2. Define variables `TB_HOST`, `ADMIN_TOKEN` and `DATA_PROJECT_DIR`
3. Extend `.run_ci` and `.cleanup_ci_branch` with rules and variables

```

include: "https://raw.githubusercontent.com/tinybirdco/ci/main/.gitlab/ci_branching.yaml"

.ci_variables:
  variables: &ci_variables
    TB_HOST: "<tinybird_api_endpoint_region_ie_https://api.tinybird.co>"
    ADMIN_TOKEN: "<tinybird_admin_token>"
    DATA_PROJECT_DIR: "<your_data_project_directory>"


run_ci:
  extends: .run_ci
  rules:
    - <set_your_rules>
  variables:
    <<: *ci_variables

cleanup_ci:
  extends: .cleanup_ci_branch
  rules:
    - <set_your_rules>
  variables:
    <<: *ci_variables

```

## GitHub

1. Using inputs `tb_host` and `admin_token`
2. Call reusable job workflow

```
 ci_branching:
    uses: tinybirdco/ci/.github/workflows/ci_branching.yml@main
    with:
      tb_host: <tinybird_api_endpoint_region_ie_https://api.tinybird.co>
    secrets: 
      admin_token: <tinybird_admin_token>
```