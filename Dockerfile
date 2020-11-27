FROM alpine

ARG TARGETARCH

ENV ETCD_VERSION 3.4.0

RUN apk add --update bash curl docker \
    && rm -rf /var/cache/apk/*

RUN cd /usr/local/bin \
    && curl -O https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/${TARGETARCH}/kubectl \
    && chmod 755 /usr/local/bin/kubectl

RUN if [ $TARGETARCH == "arm" ] ; then ETCDTARGETARCH=arm64; else ETCDTARGETARCH=amd64; fi

RUN cd /tmp \
    && curl -OL https://github.com/coreos/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-${ETCDTARGETARCH}.tar.gz \ 
    && tar zxf etcd-v${ETCD_VERSION}-linux-${ETCDTARGETARCH}.tar.gz \
    && cp etcd-v${ETCD_VERSION}-linux-${ETCDTARGETARCH}/etcdctl /usr/local/bin/etcdctl \
    && rm -rf etcd-v${ETCD_VERSION}-linux-${ETCDTARGETARCH}* \
    && chmod +x /usr/local/bin/etcdctl

COPY docker-clean.sh k8s-clean.sh etcd-empty-dir-cleanup.sh /bin/
RUN chmod +x /bin/docker-clean.sh /bin/k8s-clean.sh /bin/etcd-empty-dir-cleanup.sh

ENV DOCKER_CLEAN_INTERVAL 1800
ENV DAYS 7

CMD ["bash", "/bin/docker-clean.sh"]
