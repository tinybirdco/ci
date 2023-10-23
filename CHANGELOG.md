Next release
============

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