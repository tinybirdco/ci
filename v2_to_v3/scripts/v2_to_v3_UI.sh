#!/bin/bash

# Default base directory for operations except for workflows
BASE_DIR="."

# Process command line options
while getopts ":hd:" opt; do
  case ${opt} in
    h )
      echo "Usage: $0 [-d <directory>]"
      echo "  -d  Specify the base directory for operations (default is the current directory). This does not affect workflow files, which are always updated in .github/workflows."
      echo "  -h  Display this help message."
      exit 0
      ;;
    d )
      BASE_DIR=$OPTARG
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      echo "Use -h for help."
      exit 1
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

WORKFLOW_VERSION="v3.1.0"
TINYBIRD_CLI_VERSION=">=3.2.0"

# Determine OS for sed in-place editing
SED_INPLACE_EXT="-i"
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS requires '' with -i for in-place editing without backup
    SED_INPLACE_EXT="-i ''"
fi

# Update .yml files in .github/workflows
echo "Updating workflow files in ./.github/workflows..."
find ./.github/workflows -type f -name "*.yml" -exec sed ${SED_INPLACE_EXT} -e "s|\(uses: tinybirdco/ci/.github/workflows/cd.yml@\)v[0-9]*\.[0-9]*\.[0-9]*|\1$WORKFLOW_VERSION|g" \
-e "s|\(uses: tinybirdco/ci/.github/workflows/release.yml@\)v[0-9]*\.[0-9]*\.[0-9]*|\1$WORKFLOW_VERSION|g" \
-e "s|\(uses: tinybirdco/ci/.github/workflows/ci.yml@\)v[0-9]*\.[0-9]*\.[0-9]*|\1$WORKFLOW_VERSION|g" \
-e "/tb_deploy/d" {} \;

# Detect if $BASE_DIR/deploy folder has v2 content and in that case rename it to ./deploy_v2
echo "Checking $BASE_DIR/deploy ..."
if [ -d "$BASE_DIR/deploy" ]; then
    # Check if the directory is not empty and contains subdirectories
    if [ -n "$(find "$BASE_DIR/deploy" -mindepth 1 -type d)" ]; then
        echo "Renaming $BASE_DIR/deploy to $BASE_DIR/deploy_bak and recreating $BASE_DIR/deploy..."
        mv "$BASE_DIR/deploy" "$BASE_DIR/deploy_bak"
        mkdir "$BASE_DIR/deploy"
        touch "$BASE_DIR/deploy/.gitkeep"
        echo "Folder renamed to $BASE_DIR/deploy_bak and $BASE_DIR/deploy recreated"
    else
        echo "$BASE_DIR/deploy does not come from v2. Leaving as is."
    fi
else
    echo "Folder $BASE_DIR/deploy does not exist. It will be created:"
    mkdir "$BASE_DIR/deploy"
    touch "$BASE_DIR/deploy/.gitkeep"
fi

BASE_DIR=$(realpath "$BASE_DIR" 2>/dev/null || readlink -f "$BASE_DIR")

# Update tinybird-cli version in requirements.txt
echo "Updating tinybird-cli version in $BASE_DIR/requirements.txt..."
if [ -f "$BASE_DIR/requirements.txt" ]; then
    sed ${SED_INPLACE_EXT} -E "s|tinybird-cli*.*|tinybird-cli$TINYBIRD_CLI_VERSION|g" "$BASE_DIR/requirements.txt"
else
    echo "tinybird-cli$TINYBIRD_CLI_VERSION" > "$BASE_DIR/requirements.txt"
fi

# Ensure scripts directory exists
echo "Ensuring $BASE_DIR/scripts exists..."
mkdir -p "$BASE_DIR/scripts"

# Download and update exec_test.sh and appned_fixtures
echo "Downloading and updating exec_test.sh..."
curl https://raw.githubusercontent.com/tinybirdco/ci/main/scripts/exec_test.sh > "$BASE_DIR/scripts/exec_test.sh"
curl https://raw.githubusercontent.com/tinybirdco/ci/main/scripts/append_fixtures.sh > "$BASE_DIR/scripts/append_fixtures.sh"
if [ $? -eq 0 ]; then
    chmod +x "$BASE_DIR/scripts/exec_test.sh"
    chmod +x "$BASE_DIR/scripts/append_fixtures.sh"
else
    echo "Error downloading exec_test.sh or append_fixtures.sh"
    exit 1
fi

# Update version in .tinyenv
echo "Updating VERSION in $BASE_DIR/.tinyenv to 0.0.0..."
if [ -f "$BASE_DIR/.tinyenv" ]; then
    sed ${SED_INPLACE_EXT} "s|VERSION=.*|VERSION=0.0.0|g" "$BASE_DIR/.tinyenv"
else
    echo "Error: .tinyenv file does not exist."
    exit 1
fi

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

delete_files "$BASE_DIR/datasources" "datasource" "VERSION"
delete_files "$BASE_DIR/pipes" "pipe" "VERSION"

echo "Script execution completed."
