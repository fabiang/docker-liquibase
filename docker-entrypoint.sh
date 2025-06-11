#!/usr/bin/env bash

set -o pipefail
set +e

if [ "$1" = 'liquibase' ]; then
    if [ "$MY_LIQUIBASE_SHOW_BANNER" == '0' ] || [ "$MY_LIQUIBASE_SHOW_BANNER" == 'false' ]; then
        exec liquibase "--show-banner=false ${@:2}"
    else
        exec liquibase "${@:2}"
    fi
fi

exec "$@"
