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
3. Extend `.run_ci`, `.cleanup_ci_branch` and `run_cd` with rules and variables

```

include: "https://raw.githubusercontent.com/tinybirdco/ci/main/.gitlab/ci_branching.yaml"

.ci_config_rules:
  - &ci_config_rule
    if: $CI_PIPELINE_SOURCE == "merge_request_event"
    changes:
      - .gitlab-ci.yml
      - shared_internal_test/*
  - &ci_cleanup_rule
    if: $CI_PIPELINE_SOURCE == "merge_request_event"
    when: always

.ci_variables:
  variables: &ci_variables
    TB_HOST: "<tinybird_api_endpoint_region_ie_https://api.tinybird.co>"
    ADMIN_TOKEN: "<tinybird_admin_token>"
    DATA_PROJECT_DIR: "<your_data_project_directory>"
    
.cd_config_rules:
  - &cd_config_rule
    if: $CI_COMMIT_BRANCH == '$CI_DEFAULT_BRANCH' && $CI_PIPELINE_SOURCE == 'merge_request_event'

.cd_variables:
  variables: &ci_variables
    TB_HOST: "<tinybird_api_endpoint_region_ie_https://api.tinybird.co>"
    ADMIN_TOKEN: "<tinybird_admin_token>"
    DATA_PROJECT_DIR: "<your_data_project_directory>"


run_ci:
  extends: .run_ci
  rules:
    - *ci_config_rule
  variables:
    <<: *ci_variables

cleanup_ci:
  extends: .cleanup_ci_branch
  rules:
    - *ci_cleanup_rule
  variables:
    <<: *ci_variables
    
run_cd:
  extends: .run_cd
  rules:
    - *cd_config_rule
  variables:
    <<: *cd_variables

```

## GitHub

1. Using inputs `tb_host` and `admin_token`
2. Call reusable job workflow => See example [here](https://github.com/tinybirdco/ecommerce_data_project/tree/master/.github)
