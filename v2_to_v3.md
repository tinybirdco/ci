# How to migrate Tinybird Data Projects v2 to v3

## Using GitHub

You just need to enable `tb_deploy` in all workflows, create a new `release.yml` workflow, and start using (at least) the v3.0.0 version. 

That means, starting from a simple project:

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
+           tb_deploy: true          
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
+           tb_deploy: true          
        secrets:
            tb_admin_token: ${{ secrets.TB_ADMIN_TOKEN }}
            tb_host: https://api.tinybird.co
```

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
+       uses: tinybirdco/ci/.github/workflows/release.+ yml@v3.0.0
+       with:
+         tb_deploy: true
+         data_project_dir: .
+         job_to_run: ${{ inputs.job_to_run }}
+       secrets:
+         tb_admin_token: ${{ secrets.TB_ADMIN_TOKEN }}
+         tb_host: https://api.tinybird.co
```

## Using GitLab

The changes for this provider are a bit different. Apart from updating the CI/CD version, we need to remove the `cleanup_cd_env` step, because it is not needed, and include three new steps for promote, rollback and remove releases.

An example in a simple project would be:

```diff
-include: "https://raw.githubusercontent.com/tinybirdco/ci/v2.4.0/.gitlab/ci_cd.yaml"
+include: "https://raw.githubusercontent.com/tinybirdco/ci/v3.0.1/.gitlab/ci_cd.yaml"

.ci_config_rules:
-   - &ci_config_rule
+   - &ci_config_rule_tests
    if: $CI_PIPELINE_SOURCE == "merge_request_event"
+   allow_failure: true
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
+   TB_DEPLOY: "true"

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

run_cd:
    extends: .run_cd
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

+run_promote:
+   extends: .release_promote
+   dependencies: []
+   when: manual
+   rules:
+       - *cd_config_rule
+   variables:
+       <<: *cicd_variables
+
+run_rollback:
+   extends: .release_rollback
+   dependencies: []
+   when: manual
+   rules:
+       - *cd_config_rule
+   variables:
+       <<: *cicd_variables
+
+run_rm:
+   extends: .release_rm
+   dependencies: []
+   when: manual
+   rules:
+       - *cd_config_rule
+   variables:
+       <<: *cicd_variables
```