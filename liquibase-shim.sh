#!/usr/bin/env bash
# This script makes sure that our extra class paths are set when executing liquibase

set -o pipefail
set +e

# Script trace mode
if [ "${DEBUG_MODE,,}" == "true" ]; then
    set -o xtrace
fi

extraClassPaths="/usr/local/liquibase/jdbc_drivers/postgresql.jar:/usr/local/liquibase/jdbc_drivers/mssql.jar:/usr/local/liquibase/jdbc_drivers/mariadb.jar:/usr/local/liquibase/jdbc_drivers/mysql.jar:/usr/local/liquibase/jdbc_drivers/jtds.jar:/usr/local/liquibase/liquibase_extra/liquibase-mssql.jar"
binPath="/usr/local/liquibase/liquibase"

if [ "$1" = '--version' ]; then
    exec $binPath --version
    return
fi

if [ "$1" = '--help' ]; then
    exec $binPath --help
    return
fi

exec $binPath --classpath="$extraClassPaths" "${@:1}"
