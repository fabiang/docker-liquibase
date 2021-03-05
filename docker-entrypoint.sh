#!/bin/bash
set -e

if [ "$1" = 'liquibase' ]; then
    exec liquibase "${@:2}"
fi

exec "$@"
