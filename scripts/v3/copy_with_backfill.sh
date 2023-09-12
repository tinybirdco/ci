#!/bin/bash
source .tinyenv

retry_duration=12 
retry_interval=1
max_retries=$((retry_duration / retry_interval))

# Parameters
COPY_TO="$1"
SQL="$2"
BACKFILL_COLUMN="$3"

BACKFILL_TIME=""
retry_count=0

if [ ! -z "$BACKFILL_COLUMN" ]; then
    while [[ $retry_count -lt $max_retries ]]; do
        output=$(tb --no-version-warning sql "select min($BACKFILL_COLUMN) as t from $COPY_TO" --semver $VERSION --format json)
        if [ -z "$output" ]; then
            echo "Output is empty"
            result=""
        else
            result=$(echo "$output" | python -c "import sys, json; print(json.load(sys.stdin)['data'][0]['t'])")
        fi

        if [[ -z $result || $result == "1970-01-01 00:00:00" ]]; then
            sleep $retry_interval
            retry_count=$((retry_count + 1))
        else
            BACKFILL_TIME=$result
            break
        fi
    done

    if [[ -z $BACKFILL_TIME ]]; then
        BACKFILL_TIME=$(date +"%Y-%m-%d %H:%M:%S")
    fi

    if [[ $SQL == *"WHERE"* ]]; then
        # SQL already has a WHERE clause, so add an AND condition
        SQL="$SQL AND $BACKFILL_COLUMN < '$BACKFILL_TIME'"
    else
        # SQL doesn't have a WHERE clause, so add the WHERE clause with the condition
        SQL="$SQL WHERE $BACKFILL_COLUMN < '$BACKFILL_TIME'"
    fi
fi

tb env datasource copy $COPY_TO --sql "$SQL" --wait --semver $VERSION

retry_count=0
while [[ $retry_count -lt $max_retries ]]; do
    count_live=$(tb --no-version-warning sql "select count() from $COPY_TO" --format json | python -c "import sys, json; print(json.load(sys.stdin)['data'][0]['count()'])")
    echo "Live count: $count_live"
    count_preview=$(tb --no-version-warning sql "select count() from $COPY_TO" --format json --semver $VERSION | python -c "import sys, json; print(json.load(sys.stdin)['data'][0]['count()'])")
    echo "Preview count: $count_preview"

    if [ $count_live -eq $count_preview ]; then
        echo "Both counts are equal."
        exit 0
    else
        echo "Counts are not equal."
    fi
    sleep $retry_interval
    retry_count=$((retry_count + 1))
done
