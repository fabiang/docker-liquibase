# Docker image with Liquibase

This Docker image includes Liquibase 3.6 and supports the following:

- PostgreSQL
- Mysql
- SQLServer
- SQLServer Extension for Liquibase

## Usage

Example for SQL Server:

```
docker run --rm -it fabiang/liquibase \
    --changeLogFile=somepath/db.changelog.xml \
    --driver=com.microsoft.sqlserver.jdbc.SQLServerDriver \
    --url="jdbc:sqlserver://mysqlserverinstance;databaseName=database;integratedSecurity=false;" \
    update
```
