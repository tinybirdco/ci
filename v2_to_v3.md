# How to migrate Tinybird Data Projects v2 to v3

## Using GitHub

In this case, the changes are easy. You just need to enable `tb_deploy` in all workflows, create a new `release.yml` workflow, and start using (at least) the 2.5.1 version. That means, starting from a simple project:

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
-       uses: tinybirdco/ci/.github/workflows/ci.yml@main
+       uses: tinybirdco/ci/.github/workflows/ci.yml@2.5.1
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
-       uses: tinybirdco/ci/.github/workflows/ci.yml@main
+       uses: tinybirdco/ci/.github/workflows/ci.yml@2.5.1
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
+       uses: tinybirdco/ci/.github/workflows/release.+ yml@2.5.1
+       with:
+         tb_deploy: true
+         data_project_dir: .
+         job_to_run: ${{ inputs.job_to_run }}
+       secrets:
+         tb_admin_token: ${{ secrets. TB_ADMIN_TOKEN }}
+         tb_host: https://api.tinybird.co
```

## Using GitLab

