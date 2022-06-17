# Docker image for Liquibase [![CircleCI](https://circleci.com/gh/fabiang/docker-liquibase.svg?style=svg)](https://circleci.com/gh/fabiang/docker-liquibase)

This Docker image includes [Liquibase](https://www.liquibase.org) and supports the following DBMS:

- PostgreSQL
- Mysql
- MariaDB
- SQLServer
- SQLServer Extension for Liquibase

[![fabiang/liquibase](http://dockeri.co/image/fabiang/liquibase)](https://registry.hub.docker.com/r/fabiang/liquibase)

## Usage

Example for SQL Server:

```
docker run --rm -it fabiang/liquibase liquibase \
    --changeLogFile=somepath/db.changelog.xml \
    --driver=com.microsoft.sqlserver.jdbc.SQLServerDriver \
    --url="jdbc:sqlserver://mysqlserverinstance;databaseName=database;integratedSecurity=false;" \
    update
```
