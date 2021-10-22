FROM java:8-jre-alpine

MAINTAINER Fabian Grutschus <f.grutschus@lubyte.de>

ARG LIQUIBASE_URL=https://github.com/liquibase/liquibase/releases/download/v4.5.0/liquibase-4.5.0.tar.gz
ARG LIQUIBASE_CHECKSUM=f7a5440c348cf87308698447691e6c30fff433de

ARG SL4J_VERSION=1.7.32
ARG SL4J_CHECKSUM=266455a2fe7a8c0281caeaeccb66ed7521c6a992

ENV LIQUIBASE_HOME=/usr/local/liquibase/

COPY ./liquibase-shim.sh /usr/local/bin/liquibase

# Liquibase itself
RUN apk update -qq \
    && apk add --no-cache curl bash \
    && curl -v -L --output /tmp/liquibase-bin.tar.gz ${LIQUIBASE_URL=} \
    && mkdir -p /usr/local/liquibase \
    && echo "$LIQUIBASE_CHECKSUM */tmp/liquibase-bin.tar.gz" | sha1sum -c - \
    && tar -xzf /tmp/liquibase-bin.tar.gz -C /usr/local/liquibase \
    && chmod +x /usr/local/liquibase/liquibase \
    && curl -v -L --output /usr/local/liquibase/lib/sl4j-api-${SL4J_VERSION}.jar \
        https://repo1.maven.org/maven2/org/slf4j/slf4j-ext/${SL4J_VERSION}/slf4j-ext-${SL4J_VERSION}.jar \
    && echo "$SL4J_CHECKSUM */usr/local/liquibase/lib/sl4j-api-$SL4J_VERSION.jar" | sha1sum -c - \
    && apk del curl libssh2 libcurl \
    && rm /tmp/liquibase-bin.tar.gz

ARG JDBC_POSTGRESQL_VERSION=42.3.0
ARG JDBC_POSTGRESQL_CHECKSUM=1310ec11f694b4246c07309eedeacc6a57d6ffd2

ARG JDBC_SQLSERVER_VERSION=9.4.0
ARG JDBC_SQLSERVER_CHECKSUM=75a670b77ee3e63080d0af90962caa77bc3b7dff

ARG JDBC_MYSQL_VERSION=8.0.27
ARG JDBC_MYSQL_CHECKSUM=9243dc26efa3909b13517e002a89d7f5

ARG JDBC_JTDS_VERSION=1.3.1
ARG JDBC_JTDS_CHECKSUM=b29ee78ac9281721e2665102e29f5d3b33102fa9

# DB drivers and extra extensions
RUN apk update -qq \
    && apk add --no-cache curl unzip ca-certificates \
    && mkdir -p /usr/local/liquibase/jdbc_drivers/ \
    ## PostgreSQL
    && curl -v --insecure -L --output /usr/local/liquibase/jdbc_drivers/postgresql.jar \
        https://jdbc.postgresql.org/download/postgresql-${JDBC_POSTGRESQL_VERSION}.jar \
    && echo "$JDBC_POSTGRESQL_CHECKSUM */usr/local/liquibase/jdbc_drivers/postgresql.jar" | sha1sum -c - \
    ## Native driver from Microsoft for SQL Server
    && curl -v -L --output /usr/local/liquibase/jdbc_drivers/mssql-jdbc.jar \
        https://github.com/microsoft/mssql-jdbc/releases/download/v${JDBC_SQLSERVER_VERSION}/mssql-jdbc-${JDBC_SQLSERVER_VERSION}.jre8.jar \
    && echo "$JDBC_SQLSERVER_CHECKSUM */usr/local/liquibase/jdbc_drivers/mssql-jdbc.jar" | sha1sum -c - \
    ## MySQL driver
    && mkdir -p /tmp/mysql \
    && curl -v --insecure -L --output /tmp/mysql-connector-java.tar.gz \
        https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${JDBC_MYSQL_VERSION}.tar.gz \
    && echo "$JDBC_MYSQL_CHECKSUM */tmp/mysql-connector-java.tar.gz" | md5sum -c - \
    && tar -xzf /tmp/mysql-connector-java.tar.gz -C /tmp/mysql \
    && cp /tmp/mysql/mysql-connector-java-${JDBC_MYSQL_VERSION}/mysql-connector-java-${JDBC_MYSQL_VERSION}.jar \
        /usr/local/liquibase/jdbc_drivers/mysql.jar \
    && rm -rf /tmp/mysql \
    && rm -f /tmp/mysql-connector-java.tar.gz \
    ## JTDS Driver for SQL Server
    && mkdir -p /tmp/jtds \
    && curl -v --insecure -L --output /tmp/jtds.zip \
        https://kent.dl.sourceforge.net/project/jtds/jtds/${JDBC_JTDS_VERSION}/jtds-${JDBC_JTDS_VERSION}-dist.zip \
    && echo "$JDBC_JTDS_CHECKSUM */tmp/jtds.zip" | sha1sum -c - \
    && unzip /tmp/jtds.zip -d /tmp/jtds \
    && cp /tmp/jtds/jtds-${JDBC_JTDS_VERSION}.jar /usr/local/liquibase/jdbc_drivers/jtds.jar \
    && rm -rf /tmp/jtds \
    && rm -f /tmp/jtds.zip

ARG LIQUIBASE_EXTRA_MSSQL_VERSION=1.3.2
ARG LIQUIBASE_EXTRA_MSSQL_CHECKSUM=da0b01c977e941c78cf523b02673800c5f5ff36b

RUN mkdir -p /usr/local/liquibase/liquibase_extra \
    && curl -v --insecure -L --output /usr/local/liquibase/liquibase_extra/liquibase-mssql.jar \
        https://liquibase.jira.com/wiki/download/attachments/1998867/liquibase-mssql-$LIQUIBASE_EXTRA_MSSQL_VERSION.jar?api=v2 \
    && echo "$LIQUIBASE_EXTRA_MSSQL_CHECKSUM */usr/local/liquibase/liquibase_extra/liquibase-mssql.jar" | sha1sum -c - \
    && apk del curl libssh2 libcurl unzip

WORKDIR /changelogs

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["liquibase"]
