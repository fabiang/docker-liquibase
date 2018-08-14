#!/bin/bash

set -e

exec /usr/local/bin/liquibase --classpath="/opt/jdbc_drivers/postgresql.jar:\
/opt/jdbc_drivers/mssql-jdbc.jar:\
/opt/jdbc_drivers/mysql.jar:\
/opt/liquibase_extra/liquibase-mssql.jar" "$@"
