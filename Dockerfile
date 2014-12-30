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


EXPOSE 2181 2888 3888

ENV ZOO_LOG4J_PROP INFO,CONSOLE
