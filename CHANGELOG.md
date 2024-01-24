Next Release (v3.0.0)
=====================

- Add `CI_FLAGS` and `CD_FLAGS` env vars to `tb deploy`, they can be defined per Data Project and PR via `.tinyenv`
- Update rollback job to include the `--yes` flag to `tb release rollback`
- Split CI jobs into:
  - Deployment + test
- Make deployment idempotent in CI and CD.
- Remove `ci-deploy.sh` and `cd-deploy.sh` in favour of `deploy.sh`
- Add `postdeploy.sh` as a custom script to be run before the test job. It can be used to run data operations (such as populates), promote release, etc.
- Remove `tb deploy`
- Add `dry_run_rm_oldest_rollback` and `rm_oldest_rollback` jobs to delete the oldest rollback Release by creation date

**Read [this](v2_to_v3.md) to migrate from v2.x to v3.0.0**


v2.5.0
=======

- Support for `./tests/regression.yaml` inside the Data Project folder. More information [here](https://www.tinybird.co/docs/guides/continuous-integration.html#testing-strategies).

v2.4.0
=======

- Fix manual jobs for v3 releases on GitHub
- Fix: Do `tb auth` before a custom deployment in the CD templates. Custom deployments where not working in v2.3.0, users in this version of the CD template need to update to v2.4.0.


v2.3.0
======

- Support for a `requirements.txt` file inside the Data Project folder. That way you can control which version of the `tinybird-cli` to install.
- Environments in CI are now created with a fixed name using the Pull Request number.
- Environments are not cleaned up after CI finishes. This is a very convenient workflow to debug issues directly in the Environment with the changes of the branch deployed.
- Users updating from previous versions need to do some actions:
  - GitHub: Add the `closed` type like [this](https://github.com/tinybirdco/ci_analytics/pull/12/commits/01a207ab2dac38a18ea76c81b0b3087ad3f9cb91).
  - GitLab: Change the rule to run the clean up job on merge:

  ```yaml
  - &cli_cleanup_rule
    if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
    changes:
      - .gitlab-ci.yml
      - ./**/*
    when: always
    ```
- If you have doubts when updating just drop the .github or .gitlab-ci.yml workflow and re-run `tb init --git` using the latest version of `tinybird-cli` to re-generate the CI/CD templates.
- `.tinyenv` now supports `export OBFUSCATE_REGEX_PATTERN=<regex>` to have a list of regex separated by `|` to obfuscate the output of regression tests. It requires version 1.0.1 of tinybird-cli.
- `.tinyenv` variables written to `GITHUB_ENV` to make them available in all GitHub Actions workflow
