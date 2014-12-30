FROM debian:jessie
MAINTAINER Greg Symons <gsymons@gsconsulting.biz>



#Install prerequisites
RUN apt-get update && apt-get install -y \
    openjdk-7-jre-headless \
    wget

#Install zookeeper
RUN groupadd -r zookeeper && \
    useradd -r -g zookeeper -d /var/lib/zookeeper -M zookeeper && \
    mkdir -p /opt/zookeeper && \
    mkdir -p /var/lib/zookeeper && \
    chown zookeeper:zookeeper /var/lib/zookeeper && \
    wget -O zookeeper-3.4.6.tar.gz \
        http://apache.mirrors.lucidnetworks.net/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz && \
    tar -C /opt/zookeeper \
        --strip-components=1 \
        -xvzf zookeeper-3.4.6.tar.gz \
        --wildcards \
        '*/conf/*' '*/lib/*' '*/bin/*' '*/zookeeper-*.jar' && \
    rm -rf zookeeper-3.4.6.tar.gz

#Install confd
RUN mkdir -p /opt/confd/bin && \
    mkdir -p /opt/confd/conf.d && \
    mkdir -p /opt/confd/templates && \
    wget -O /opt/confd/bin/confd \
        https://github.com/kelseyhightower/confd/releases/download/v0.7.1/confd-0.7.1-linux-amd64

EXPOSE 2181 2888 3888

ENV ZOO_LOG4J_PROP INFO,CONSOLE
