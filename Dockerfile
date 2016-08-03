FROM alpine:3.4
MAINTAINER smizy

ENV KAFKA_VERSION        0.10.0.0
ENV KAFKA_SCALA_VERSION  2.11
ENV KAFKA_HOME           /usr/local/kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}
ENV KAFKA_CONF_DIR       ${KAFKA_HOME}/config
ENV KAFKA_LOG_DIR        /var/log/kafka
ENV KAFKA_HEAP_OPTS      -Xmx256M 
ENV KAFKA_ZK_QUORUM      zookeeper-1.vnet:2181,zookeeper-2.vnet:2181,zookeeper-3.vnet:2181

ENV JAVA_HOME   /usr/lib/jvm/default-jvm
ENV PATH        $PATH:${JAVA_HOME}/bin:${KAFKA_HOME}/bin
ENV LOG_DIR     ${KAFKA_LOG_DIR}

RUN set -x \
    && apk update \
    && apk --no-cache add \
        bash \
        openjdk8-jre \
        su-exec \
    && mirror_url=$( \
        wget -q -O - http://www.apache.org/dyn/closer.cgi/kafka/ \
        | sed -n 's#.*href="\(http://ftp.[^"]*\)".*#\1#p' \
        | head -n 1 \
    ) \   
    && wget -q -O - ${mirror_url}/${KAFKA_VERSION}/kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz \
        | tar -xzf - -C /usr/local \
    && rm -rf ${KAFKA_HOME}/site-docs \
    ## user/dir/permmsion
    && adduser -D  -g '' -s /sbin/nologin -u 1000 docker \
    && adduser -D  -g '' -s /sbin/nologin kafka \
    && mkdir -p \
        ${KAFKA_LOG_DIR} \
    && chmod -R 755 \
        ${KAFKA_LOG_DIR} \
    && chown -R kafka \
        ${KAFKA_LOG_DIR} 

COPY etc/*  ${KAFKA_CONF_DIR}/
COPY bin/*  /usr/local/bin/
COPY lib/*  /usr/local/lib/

WORKDIR ${KAFKA_HOME}

EXPOSE 9092

VOLUME ["${KAFKA_LOG_DIR}", "${KAFKA_HOME}"]

ENTRYPOINT ["entrypoint.sh"]
CMD ["server"]