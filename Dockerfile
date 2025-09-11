FROM eclipse-temurin:11-jre-alpine

ARG LIQUIBASE_VERSION=4.17.2
ARG LIQUIBASE_URL=https://github.com/liquibase/liquibase/releases/download/v4.17.2/liquibase-4.17.2.tar.gz
ARG LIQUIBASE_CHECKSUM_SHA256=85e910880006bdccfd7d6805a4601bff3311f4eadebc68081b4bfeac5ec7af40

ARG SL4J_VERSION=1.7.32
ARG SL4J_CHECKSUM_SHA1=266455a2fe7a8c0281caeaeccb66ed7521c6a992

ENV LIQUIBASE_HOME=/usr/local/liquibase

COPY ./liquibase-shim.sh /usr/local/bin/liquibase
COPY ./liquibase-drivers.sh /usr/local/bin/liquibase-drivers

RUN chmod +x /usr/local/bin/liquibase-drivers

# Liquibase itself
RUN apk update -qq \
    && apk add --no-cache curl bash \
    && curl -L --output /tmp/liquibase-bin.tar.gz ${LIQUIBASE_URL} \
    && mkdir -p /usr/local/liquibase \
    && echo "$LIQUIBASE_CHECKSUM_SHA256 */tmp/liquibase-bin.tar.gz" | sha256sum -c - \
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
    && mkdir -p ${LIQUIBASE_HOME}/internal/lib \
    \
    ## PostgreSQL
    && if [ $(liquibase-drivers | grep 'PostgreSQL JDBC Driver'; echo $?) -gt 0 ]; then \
        curl --fail --insecure -L --output ${LIQUIBASE_HOME}/internal/lib/postgresql.jar \
            https://jdbc.postgresql.org/download/postgresql-${JDBC_POSTGRESQL_VERSION}.jar \
        && echo "$JDBC_POSTGRESQL_CHECKSUM_SHA1 *${LIQUIBASE_HOME}/internal/lib/postgresql.jar" | sha1sum -c -; \
    fi \
    \
    ## MariaDB
    && if [ $(liquibase-drivers | grep 'mariadb-java-client'; echo $?) -gt 0 ]; then \
        curl --fail --insecure -L --output ${LIQUIBASE_HOME}/internal/lib/mariadb-java-client.jar \
            https://downloads.mariadb.com/Connectors/java/connector-java-${JDBC_MARIADB_VERSION}/mariadb-java-client-${JDBC_MARIADB_VERSION}.jar \
        && echo "$JDBC_MARIADB_CHECKSUM_SHA1 *${LIQUIBASE_HOME}/internal/lib/mariadb-java-client.jar" | sha1sum -c -; \
    fi \
    \
    ## Native driver from Microsoft for SQL Server
    && if [ $(liquibase-drivers | grep 'Microsoft JDBC Driver for SQL Server'; echo $?) -gt 0 ]; then \
        curl -L --fail --output ${LIQUIBASE_HOME}/internal/lib/mssql-jdbc.jar \
            https://github.com/microsoft/mssql-jdbc/releases/download/v${JDBC_SQLSERVER_VERSION}/mssql-jdbc-${JDBC_SQLSERVER_VERSION}.jre8.jar \
        && echo "$JDBC_SQLSERVER_CHECKSUM_SHA1 *${LIQUIBASE_HOME}/internal/lib/mssql-jdbc.jar" | sha1sum -c -; \
    fi \
    \
    ## MySQL driver
    && if [ $(liquibase-drivers | grep -E 'Oracle .* MySQL'; echo $?) -gt 0 ]; then \
        mkdir -p /tmp/mysql \
        && curl --fail --insecure -L --output /tmp/mysql-connector-java.tar.gz \
            https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${JDBC_MYSQL_VERSION}.tar.gz \
        && echo "$JDBC_MYSQL_CHECKSUM_SHA1 */tmp/mysql-connector-java.tar.gz" | md5sum -c - \
        && tar -xzf /tmp/mysql-connector-java.tar.gz -C /tmp/mysql \
        && cp /tmp/mysql/mysql-connector-java-${JDBC_MYSQL_VERSION}/mysql-connector-java-${JDBC_MYSQL_VERSION}.jar \
            ${LIQUIBASE_HOME}/internal/lib/mysql-jdbc.jar \
        && rm -rf /tmp/mysql \
        && rm -f /tmp/mysql-connector-java.tar.gz; \
    fi \
    \
    ## JTDS Driver for SQL Server
    && if [ $(liquibase-drivers | grep -E 'jTDS JDBC Driver'; echo $?) -gt 0 ]; then \
        mkdir -p /tmp/jtds \
        && curl --fail --insecure -L --output /tmp/jtds.zip \
            https://downloads.sourceforge.net/project/jtds/jtds/${JDBC_JTDS_VERSION}/jtds-${JDBC_JTDS_VERSION}-dist.zip \
        && echo "$JDBC_JTDS_CHECKSUM_SHA1 */tmp/jtds.zip" | sha1sum -c - \
        && unzip /tmp/jtds.zip -d /tmp/jtds \
        && cp /tmp/jtds/jtds-${JDBC_JTDS_VERSION}.jar ${LIQUIBASE_HOME}/internal/lib/mssql-jtds.jar \
        && rm -rf /tmp/jtds \
        && rm -f /tmp/jtds.zip; \
    fi

ARG LIQUIBASE_EXTRA_MSSQL_CHECKSUM_SHA256=6f8eb2f803e76209deb8f250ca3a8b9e1807b3e9287b320cce1cfe4fb3a845cf

RUN curl -L --fail --output ${LIQUIBASE_HOME}/lib/liquibase-mssql.jar \
        https://github.com/liquibase/liquibase-mssql/releases/download/liquibase-mssql-${LIQUIBASE_VERSION}/liquibase-mssql-${LIQUIBASE_VERSION}.jar \
    && echo "${LIQUIBASE_EXTRA_MSSQL_CHECKSUM_SHA256} ${LIQUIBASE_HOME}/lib/liquibase-mssql.jar" | sha256sum --check - --warn;

WORKDIR /changelogs

ARG MY_LIQUIBASE_SHOW_BANNER=false

COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint
ENTRYPOINT ["docker-entrypoint"]
CMD ["liquibase"]
