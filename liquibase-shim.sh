#!/usr/bin/env bash
# This script makes sure that our extra class paths are set when executing liquibase

set -o pipefail
set +e

# Script trace mode
if [ "${DEBUG_MODE,,}" == "true" ]; then
    set -o xtrace
fi

extraClassPaths="${LIQUIBASE_HOME}/internal/lib/postgresql.jar:${LIQUIBASE_HOME}/internal/lib/mssql-jdbc.jar:${LIQUIBASE_HOME}/internal/lib/mariadb-java-client.jar:${LIQUIBASE_HOME}/internal/lib/mysql-jdbc.jar:${LIQUIBASE_HOME}/internal/lib/mssql-jtds.jar:${LIQUIBASE_HOME}/lib/liquibase-mssql.jar"
binPath="${LIQUIBASE_HOME}/liquibase"

if [ "$1" = '--version' ]; then
    exec $binPath --version
    exit $?
fi

if [ "$1" = '--help' ]; then
    exec $binPath --help
    exit $?
fi

exec $binPath --classpath="$extraClassPaths" -- "${@:1}"
