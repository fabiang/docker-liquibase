#!/bin/bash
set -e

if [ "$1" = 'liquibase' ]; then
    # --version and --help can't follow --classpath
    if [ "$2" = '--version' ]; then
        exec liquibase --version
        return
    fi

    if [ "$2" = '--help' ]; then
        exec liquibase --help
        return
    fi

    exec liquibase --classpath="/opt/jdbc_drivers/postgresql.jar:/opt/jdbc_drivers/mssql-jdbc.jar:/opt/jdbc_drivers/mysql.jar:/opt/liquibase_extra/liquibase-mssql.jar" "${@:2}"
fi

exec "$@"
