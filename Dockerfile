FROM eclipse-temurin:11-jre-alpine

ARG LIQUIBASE_URL=https://github.com/liquibase/liquibase/releases/download/v4.17.2/liquibase-4.17.2.tar.gz
ARG LIQUIBASE_CHECKSUM_SHA1=8829fef88d890d7c77a45912dc6b81acee209c92

ARG SL4J_VERSION=1.7.32
ARG SL4J_CHECKSUM_SHA1=266455a2fe7a8c0281caeaeccb66ed7521c6a992

ENV LIQUIBASE_HOME=/usr/local/liquibase/

COPY ./liquibase-shim.sh /usr/local/bin/liquibase

# Liquibase itself
RUN apk update -qq \
    && apk add --no-cache curl bash \
    && curl -L --output /tmp/liquibase-bin.tar.gz ${LIQUIBASE_URL} \
    && mkdir -p /usr/local/liquibase \
    && echo "$LIQUIBASE_CHECKSUM_SHA1 */tmp/liquibase-bin.tar.gz" | sha1sum -c - \
    && tar -xzf /tmp/liquibase-bin.tar.gz -C /usr/local/liquibase \
    && chmod +x /usr/local/liquibase/liquibase \
    && curl -L --output /usr/local/liquibase/lib/sl4j-api-${SL4J_VERSION}.jar \
    https://repo1.maven.org/maven2/org/slf4j/slf4j-ext/${SL4J_VERSION}/slf4j-ext-${SL4J_VERSION}.jar \
    && echo "$SL4J_CHECKSUM_SHA1 */usr/local/liquibase/lib/sl4j-api-$SL4J_VERSION.jar" | sha1sum -c - \
    && apk del curl libssh2 libcurl \
    && rm /tmp/liquibase-bin.tar.gz

ARG JDBC_POSTGRESQL_VERSION=42.3.0
ARG JDBC_POSTGRESQL_CHECKSUM_SHA1=1310ec11f694b4246c07309eedeacc6a57d6ffd2

ARG JDBC_SQLSERVER_VERSION=9.4.0
ARG JDBC_SQLSERVER_CHECKSUM_SHA1=75a670b77ee3e63080d0af90962caa77bc3b7dff

ARG JDBC_MYSQL_VERSION=8.0.27
ARG JDBC_MYSQL_CHECKSUM_SHA1=9243dc26efa3909b13517e002a89d7f5

ARG JDBC_MARIADB_VERSION=2.7.3
ARG JDBC_MARIADB_CHECKSUM_SHA1=4a2edc05bd882ad19371d2615c2635dccf8d74f0

ARG JDBC_JTDS_VERSION=1.3.1
ARG JDBC_JTDS_CHECKSUM_SHA1=b29ee78ac9281721e2665102e29f5d3b33102fa9

# DB drivers and extra extensions
RUN apk update -qq \
    && apk add --no-cache curl unzip ca-certificates \
    && mkdir -p /usr/local/liquibase/jdbc_drivers/ \
    \
    ## PostgreSQL
    && curl --insecure -L --output /usr/local/liquibase/jdbc_drivers/postgresql.jar \
    https://jdbc.postgresql.org/download/postgresql-${JDBC_POSTGRESQL_VERSION}.jar \
    && echo "$JDBC_POSTGRESQL_CHECKSUM_SHA1 */usr/local/liquibase/jdbc_drivers/postgresql.jar" | sha1sum -c - \
    \
    ## MariaDB
    && curl --insecure -L --output /usr/local/liquibase/jdbc_drivers/mariadb.jar \
    https://downloads.mariadb.com/Connectors/java/connector-java-${JDBC_MARIADB_VERSION}/mariadb-java-client-${JDBC_MARIADB_VERSION}.jar \
    && echo "$JDBC_MARIADB_CHECKSUM_SHA1 */usr/local/liquibase/jdbc_drivers/mariadb.jar" | sha1sum -c - \
    \
    ## Native driver from Microsoft for SQL Server
    && curl -L --output /usr/local/liquibase/jdbc_drivers/mssql.jar \
    https://github.com/microsoft/mssql-jdbc/releases/download/v${JDBC_SQLSERVER_VERSION}/mssql-jdbc-${JDBC_SQLSERVER_VERSION}.jre8.jar \
    && echo "$JDBC_SQLSERVER_CHECKSUM_SHA1 */usr/local/liquibase/jdbc_drivers/mssql.jar" | sha1sum -c - \
    \
    ## MySQL driver
    && mkdir -p /tmp/mysql \
    && curl --insecure -L --output /tmp/mysql-connector-java.tar.gz \
    https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${JDBC_MYSQL_VERSION}.tar.gz \
    && echo "$JDBC_MYSQL_CHECKSUM_SHA1 */tmp/mysql-connector-java.tar.gz" | md5sum -c - \
    && tar -xzf /tmp/mysql-connector-java.tar.gz -C /tmp/mysql \
    && cp /tmp/mysql/mysql-connector-java-${JDBC_MYSQL_VERSION}/mysql-connector-java-${JDBC_MYSQL_VERSION}.jar \
    /usr/local/liquibase/jdbc_drivers/mysql.jar \
    && rm -rf /tmp/mysql \
    && rm -f /tmp/mysql-connector-java.tar.gz \
    \
    ## JTDS Driver for SQL Server
    && mkdir -p /tmp/jtds \
    && curl --insecure -L --output /tmp/jtds.zip \
    https://downloads.sourceforge.net/project/jtds/jtds/${JDBC_JTDS_VERSION}/jtds-${JDBC_JTDS_VERSION}-dist.zip \
    && echo "$JDBC_JTDS_CHECKSUM_SHA1 */tmp/jtds.zip" | sha1sum -c - \
    && unzip /tmp/jtds.zip -d /tmp/jtds \
    && cp /tmp/jtds/jtds-${JDBC_JTDS_VERSION}.jar /usr/local/liquibase/jdbc_drivers/jtds.jar \
    && rm -rf /tmp/jtds \
    && rm -f /tmp/jtds.zip

ARG LIQUIBASE_EXTRA_MSSQL_VERSION=1.3.2
ARG LIQUIBASE_EXTRA_MSSQL_CHECKSUM_SHA1=da0b01c977e941c78cf523b02673800c5f5ff36b

RUN mkdir -p /usr/local/liquibase/liquibase_extra \
    && curl --insecure -L --output /usr/local/liquibase/liquibase_extra/liquibase-mssql.jar \
    https://liquibase.jira.com/wiki/download/attachments/1998867/liquibase-mssql-$LIQUIBASE_EXTRA_MSSQL_VERSION.jar?api=v2 \
    && echo "$LIQUIBASE_EXTRA_MSSQL_CHECKSUM_SHA1 */usr/local/liquibase/liquibase_extra/liquibase-mssql.jar" | sha1sum -c - \
    && apk del curl libssh2 libcurl unzip

WORKDIR /changelogs

ARG MY_LIQUIBASE_SHOW_BANNER=false
ENV MY_LIQUIBASE_SHOW_BANNER=${MY_LIQUIBASE_SHOW_BANNER}

COPY ./docker-entrypoint.sh /docker-entrypoint
RUN chmod +x /docker-entrypoint
ENTRYPOINT ["/docker-entrypoint"]
CMD ["liquibase"]
