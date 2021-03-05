FROM java:8-jre-alpine

MAINTAINER Fabian Grutschus <f.grutschus@lubyte.de>

ARG LIQUIBASE_URL=https://github.com/liquibase/liquibase/releases/download/v4.3.1/liquibase-4.3.1.tar.gz
ARG JDBC_POSTGRESQL_VERSION=42.2.19
ARG JDBC_SQLSERVER_VERSION=9.2.1
ARG JDBC_MYSQL_VERSION=8.0.16
ARG JDBC_JTDS_VERSION=1.3.1
ARG SL4J_VERSION=1.7.30

ENV LIQUIBASE_HOME=/usr/local/liquibase/

COPY ./liquibase-shim.sh /usr/local/bin/liquibase

# Liquibase itself
RUN apk update \
    && apk add --no-cache curl bash \
    && curl -L --output /tmp/liquibase-bin.tar.gz ${LIQUIBASE_URL=} \
    && mkdir -p /usr/local/liquibase \
    && tar -xzf /tmp/liquibase-bin.tar.gz -C /usr/local/liquibase \
    && chmod +x /usr/local/liquibase/liquibase \
    && curl -L --output /usr/local/liquibase/lib/sl4j-api-${SL4J_VERSION}.jar https://repo1.maven.org/maven2/org/slf4j/slf4j-ext/${SL4J_VERSION}/slf4j-ext-${SL4J_VERSION}.jar \
    && apk del curl libssh2 libcurl \
    && rm /tmp/liquibase-bin.tar.gz

# DB drivers and extra extensions
RUN apk update \
    && apk add --no-cache curl unzip \
    && mkdir -p /usr/local/liquibase/jdbc_drivers/ \
    ## PostgreSQL
    && curl -L --output /usr/local/liquibase/jdbc_drivers/postgresql.jar https://jdbc.postgresql.org/download/postgresql-${JDBC_POSTGRESQL_VERSION}.jar \
    ## Native driver from Microsoft for SQL Server
    && curl -L --output /usr/local/liquibase/jdbc_drivers/mssql-jdbc.jar https://github.com/microsoft/mssql-jdbc/releases/download/${JDBC_SQLSERVER_VERSION}/mssql-jdbc-${JDBC_SQLSERVER_VERSION}.jre8.jar \
    ## MySQL driver
    && mkdir -p /tmp/mysql \
    && curl -L --output /tmp/mysql-connector-java.tar.gz https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${JDBC_MYSQL_VERSION}.tar.gz \
    && tar -xzf /tmp/mysql-connector-java.tar.gz -C /tmp/mysql \
    && cp /tmp/mysql/mysql-connector-java-${JDBC_MYSQL_VERSION}/mysql-connector-java-${JDBC_MYSQL_VERSION}.jar /usr/local/liquibase/jdbc_drivers/mysql.jar \
    && rm -rf /tmp/mysql \
    && rm -f /tmp/mysql-connector-java.tar.gz \
    ## JTDS Driver for SQL Server
    && mkdir -p /tmp/jtds \
    && curl -L --output /tmp/jtds.zip https://kent.dl.sourceforge.net/project/jtds/jtds/${JDBC_JTDS_VERSION}/jtds-${JDBC_JTDS_VERSION}-dist.zip \
    && unzip /tmp/jtds.zip -d /tmp/jtds \
    && cp /tmp/jtds/jtds-${JDBC_JTDS_VERSION}.jar /usr/local/liquibase/jdbc_drivers/jtds.jar \
    && rm -rf /tmp/jtds \
    && rm -f /tmp/jtds.zip

RUN mkdir -p /usr/local/liquibase/liquibase_extra \
    && curl -L --output /usr/local/liquibase/liquibase_extra/liquibase-mssql.jar https://liquibase.jira.com/wiki/download/attachments/1998867/liquibase-mssql-1.3.2.jar?api=v2 \
    && apk del curl libssh2 libcurl unzip

WORKDIR /changelogs

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["liquibase"]
