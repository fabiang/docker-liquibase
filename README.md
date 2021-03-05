# Docker image with Liquibase

This Docker image includes Liquibase 3.6 and supports the following:

- PostgreSQL
- Mysql
- SQLServer
- SQLServer Extension for Liquibase

[![Build Status](https://travis-ci.com/fabiang/docker-liquibase.svg?branch=master)](https://travis-ci.com/fabiang/docker-liquibase)
[![fabiang/liquibase](http://dockeri.co/image/fabiang/liquibase)](https://registry.hub.docker.com/u/fabiang/liquibase/)

## Usage

Example for SQL Server:

```
docker run --rm -it fabiang/liquibase liquibase \
    --changeLogFile=somepath/db.changelog.xml \
    --driver=com.microsoft.sqlserver.jdbc.SQLServerDriver \
    --url="jdbc:sqlserver://mysqlserverinstance;databaseName=database;integratedSecurity=false;" \
    update
```
