FROM debian:jessie
MAINTAINER Greg Symons <gsymons@gsconsulting.biz>

EXPOSE 2181 2888 3888

ENV CONFD_EXTRA_ARGS ""
ENV ETCD_NODES http://127.0.0.1:4001
ENV ETCD_PREFIX /core-services/zookeeper
ENV ZK_INIT true
ENV ZK_PEERPORT 2888
ENV ZK_LEADERPORT 3888
ENV ZK_LOGLEVEL INFO
ENV ZK_STABILIZATION_SECS 15

#Install prerequisites
RUN apt-get update && \
    apt-get install -y \
        openjdk-7-jre-headless \
        supervisor \
        wget && \
    apt-get clean

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
    rm zookeeper-3.4.6.tar.gz

#Install confd
RUN mkdir -p /opt/confd/bin && \
    mkdir -p /opt/confd/conf.d && \
    mkdir -p /opt/confd/templates && \
    wget -O /opt/confd/bin/confd \
        https://github.com/kelseyhightower/confd/releases/download/v0.7.1/confd-0.7.1-linux-amd64 && \
    chmod 755 /opt/confd/bin/confd

#Install etcdctl
RUN mkdir -p /opt/etcd && \
    wget -O etcd.tar.gz \
        https://github.com/coreos/etcd/releases/download/v0.4.6/etcd-v0.4.6-linux-amd64.tar.gz && \
    tar -C /opt/etcd \
        --strip-components=1 \
        -xvzf etcd.tar.gz \
        --wildcards \
        '*/etcdctl' && \
    rm etcd.tar.gz

#Copy helper scripts
COPY helper-scripts/* /usr/local/bin/
RUN mkdir -p /var/run/supervisord && \
    chmod 755 /var/run/supervisord && \
    chmod 755 /usr/local/bin/*

COPY confd/conf.d/*.toml /opt/confd/conf.d/
COPY confd/templates/*.tmpl /opt/confd/templates/
COPY supervisor/supervisord.conf /etc/supervisor/supervisord.conf

ENTRYPOINT ["/usr/local/bin/zkinit"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
VOLUME ["/var/lib/zookeeper"]
