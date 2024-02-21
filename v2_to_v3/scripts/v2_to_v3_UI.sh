#!/bin/bash

WORKFLOW_VERSION="v3.1.0"
TINYBIRD_CLI_VERSION=">=3.2.0"

# Update .yml files in .github/workflows
echo "Updating workflow files in ./.github/workflows..."
find ./.github/workflows -type f -name "*.yml" -exec sed -i '' -e "s|\(uses: tinybirdco/ci/.github/workflows/cd.yml@\)v[0-9]*\.[0-9]*\.[0-9]*|\1$WORKFLOW_VERSION|g" \
-e "s|\(uses: tinybirdco/ci/.github/workflows/release.yml@\)v[0-9]*\.[0-9]*\.[0-9]*|\1$WORKFLOW_VERSION|g" \
-e "s|\(uses: tinybirdco/ci/.github/workflows/ci.yml@\)v[0-9]*\.[0-9]*\.[0-9]*|\1$WORKFLOW_VERSION|g" \
-e "/tb_deploy/d" {} \;

# Update tinybird-cli version in requirements.txt
echo "Updating tinybird-cli version in ./requirements.txt..."
if [ -f "./requirements.txt" ]; then
    sed -i '' "s|tinybird-cli==.*|tinybird-cli$TINYBIRD_CLI_VERSION|g" ./requirements.txt
else
    echo "tinybird-cli$TINYBIRD_CLI_VERSION" > ./requirements.txt
fi

# Download and update exec_test.sh from github/tinybirdco
echo "Downloading and updating exec_test.sh..."
mkdir -p ./scripts
curl https://raw.githubusercontent.com/tinybirdco/ci/main/scripts/exec_test.sh > ./scripts/exec_test.sh
curl https://raw.githubusercontent.com/tinybirdco/ci/main/scripts/append_fixtures.sh > ./scripts/append_fixtures.sh
if [ $? -eq 0 ]; then
    chmod +x ./scripts/exec_test.sh
    chmod +x ./scripts/append_fixtures.sh
else
    echo "Error downloading exec_test.sh or append_fixtures.sh"
    exit 1
fi

# Update version in .tinyenv
echo "Updating VERSION in ./.tinyenv... to 0.0.0"
if [ -f "./.tinyenv" ]; then
    sed -i '' "s|VERSION=.*|VERSION=0.0.0|g" ./.tinyenv
else
    echo "Error: .tinyenv file does not exist."
    exit 1
fi

# Detect if ./deploy folder has v2 content and in that case rename it to ./deploy_v2
echo "Checking ./deploy ..."
if [ -d "./deploy" ]; then
    # Check if the directory is not empty and contains subdirectories
    if find "./deploy" -mindepth 1 -type d | read; then
        echo "Renaming ./deploy to ./deploy_v2 and recreating ./deploy..."
        mv "./deploy" "./deploy_v2"
        mkdir "./deploy"
        touch "./deploy/.gitkeep"
        echo "Folder renamed to ./devploy_v2 and ./deploy recreated"
    else
        echo "./deploy does not come from v2. Leaving as is."
    fi
else
    echo "Folder ./deploy does not exist. It will be created:"
    mkdir "./deploy"
    touch "./deploy/.gitkeep"
fi

# Files with VERSION have been regenerated with the suffix in the UI PR step, so it's safe to delete the legacy ones
echo "Deleting legacy VERSION pipes and datasources files"
delete_files() {
  local dir=$1
  local extension=$2
  local pattern=$3
  
  find "$dir" -type f -name "*.$extension" | while read -r file; do
    if awk 'NR==1 {exit ($0 ~ /^'$pattern'/ ? 0 : 1)}' "$file"; then
      echo "Deleting $file..."
      rm "$file"
    fi
  done
}

delete_files "./datasources" "datasource" "VERSION"
delete_files "./pipes" "pipe" "VERSION"

echo "Script execution completed."
