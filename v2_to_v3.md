# How to migrate Tinybird Data Projects v3.0.0 to v3.1.1

## Using GitHub

Nothing to do, remove and rollback release jobs do not exist anymore, since they could be executed by mistake. You should run them via API, Dashboard or CLI.

## Using GitLab

```diff
-include: "https://raw.githubusercontent.com/tinybirdco/ci/v3.0.0/.gitlab/ci_cd.yaml"
+include: "https://raw.githubusercontent.com/tinybirdco/ci/v3.0.1/.gitlab/ci_cd.yaml"

      variables:
        <<: *cicd_variables

    run_rollback:
      extends: .release_rollback
      dependencies: []
      when: manual
      rules:
        - *cd_config_rule
      variables:
        <<: *cicd_variables

    run_rm:
      extends: .release_rm
      dependencies: []
      when: manual
      rules:
        - *cd_config_rule
      variables:
        <<: *cicd_variables

    dry_run_rm_oldest_rollback:
      extends: .dry_run_release_rm_oldest_rollback
      dependencies: []
```

# How to migrate Tinybird Data Projects v2 to v3

## Using GitHub

Releases are enabled by default in v3.0.0. Update your CI/CD workflows to use the v3.0.0 tag so they look like this:

`.github/workflows/tinybird_ci.yml`
```diff
name: Tinybird - CI Workflow

on:
    workflow_dispatch:
    pull_request:
        paths:
            - '*'
        branches:
            - main
        types: [opened, reopened, labeled, unlabeled, synchronize, closed]

concurrency: ${{ github.workflow }}-${{ github.event.pull_request.number }}

jobs:
    ci:
-       uses: tinybirdco/ci/.github/workflows/ci.yml@v2.4.0
+       uses: tinybirdco/ci/.github/workflows/ci.yml@v3.0.0
        with:
            data_project_dir: .
        secrets:
            tb_admin_token: ${{ secrets.TB_ADMIN_TOKEN }}
            tb_host: https://api.tinybird.co
```

`.github/workflows/tinybird_cd.yml`
```diff
name: Tinybird - CD Workflow

on:
    workflow_dispatch:
    push:
        paths:
            - '*'
        branches:
            - main

jobs:
    cd:
-       uses: tinybirdco/ci/.github/workflows/ci.yml@v2.4.0
+       uses: tinybirdco/ci/.github/workflows/ci.yml@v3.0.0
        with:
            data_project_dir: .
        secrets:
            tb_admin_token: ${{ secrets.TB_ADMIN_TOKEN }}
            tb_host: https://api.tinybird.co
```

Additionally you should add the `release` workflow.

`.github/workflows/tinybird_release.yml`
```diff
+ name: Tinybird - Releases Workflow
+ 
+ on:
+   workflow_dispatch:
+     inputs:
+       job_to_run:
+         description: 'Select the job to run manually'
+         required: true
+         default: 'promote'
+ 
+ jobs:
+     release: 
+       uses: tinybirdco/ci/.github/workflows/release.yml@v3.0.0
+       with:
+         data_project_dir: .
+         job_to_run: ${{ inputs.job_to_run }}
+       secrets:
+         tb_admin_token: ${{ secrets.TB_ADMIN_TOKEN }}
+         tb_host: https://api.tinybird.co
```

Additionally add `append_fixtures.sh` and `exec_test.sh` to your `scripts` folder. You can get them from [scripts folder](https://github.com/tinybirdco/ci/tree/main/scripts)


## Using GitLab

Releases are enabled by default in v3.0.0. Update your CI pipeline to use the v3.0.0 tag so they look like this:

```diff
-include: "https://raw.githubusercontent.com/tinybirdco/ci/v2.4.0/.gitlab/ci_cd.yaml"
+include: "https://raw.githubusercontent.com/tinybirdco/ci/v3.0.0/.gitlab/ci_cd.yaml"

.ci_config_rules:
-   - &ci_config_rule
+   - &ci_config_rule_tests
    if: $CI_PIPELINE_SOURCE == "merge_request_event"
+   allow_failure: false
+   - &ci_config_rule_test_deploy  
+   if: $CI_PIPELINE_SOURCE == "merge_request_event" 
+   allow_failure: false  
    - &ci_cleanup_rule
    if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

.cd_config_rules:
    - &cd_config_rule
    if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

.cicd_variables:
    variables: &cicd_variables
    TB_HOST: "https://api.tinybird.co"
    TB_ADMIN_TOKEN: $TB_ADMIN_TOKEN
    DATA_PROJECT_DIR: "."

-run_ci:
+deploy_ci:
-   extends: .run_ci
+   extends: .tb_deploy_ci
    rules:
-        - *ci_config_rule
+        - *ci_config_rule_deploy   
    variables:
        <<: *cicd_variables

+tests_ci:
+   extends: .tb_test
+   needs: ["deploy_ci"]
+   rules:
+       - *ci_config_rule_tests
+   variables:
+      <<: *cicd_variables

cleanup_ci_env:
-    extends: .cleanup_ci_branch
+    extends: .tb_cleanup_ci_branch
    when: always
    rules:
        - *ci_cleanup_rule
    variables:
        <<: *cicd_variables

-run_cd:
+deploy_main:
-    extends: .run_cd
+    extends: .tb_deploy_main
    rules:
        - *cd_config_rule
    variables:
        <<: *cicd_variables

-cleanup_cd_env:
-   extends: .cleanup_cd_branch
-   needs: ["run_cd"]
-   when: always
-   rules:
-       - *cd_config_rule
-   variables:
-       <<: *cicd_variables

+run_release_promote:
+   extends: .release_promote
+   dependencies: []
+   when: manual
+   rules:
+       - *cd_config_rule
+   variables:
+       <<: *cicd_variables
+
+run_release_rollback:
+   extends: .release_rollback
+   dependencies: []
+   when: manual
+   rules:
+       - *cd_config_rule
+   variables:
+       <<: *cicd_variables
+
+run_release_rm:
+   extends: .release_rm
+   dependencies: []
+   when: manual
+   rules:
+       - *cd_config_rule
+   variables:
+       <<: *cicd_variables
+
+dry_run_rm_oldest_rollback:
+    extends: .dry_run_release_rm_oldest_rollback
+    dependencies: []
+    when: manual
+    rules:
+    - *cd_config_rule
+    variables:
+    <<: *cicd_variables
+
+run_rm_oldest_rollback:
+    extends: .release_rm_oldest_rollback
+    dependencies: []
+    when: manual
+    rules:
+    - *cd_config_rule
+    variables:
+    <<: *cicd_variables
```

Additionally add `append_fixtures.sh` and `exec_test.sh` to your `scripts` folder. You can get them from [scripts folder](https://github.com/tinybirdco/ci/tree/main/scripts)