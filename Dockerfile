FROM alpine
LABEL org.opencontainers.image.source https://github.com/jc01rho/k8s-cleanup

ARG TARGETARCH

ENV ETCD_VERSION 3.4.0

RUN apk add --update bash curl docker  \
    && rm -rf /var/cache/apk/*

RUN cd /usr/local/bin \
    && curl -O https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/${TARGETARCH}/kubectl \
    && chmod 755 /usr/local/bin/kubectl

RUN if [ $TARGETARCH == "arm" ] ; then \
    cd /tmp \
    && curl -OL https://github.com/coreos/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-arm64.tar.gz \ 
    && tar zxf etcd-v${ETCD_VERSION}-linux-arm64.tar.gz \
    && cp etcd-v${ETCD_VERSION}-linux-arm64/etcdctl /usr/local/bin/etcdctl \
    && rm -rf etcd-v${ETCD_VERSION}-linux-arm64* \
    && chmod +x /usr/local/bin/etcdctl \
    ; else \
    cd /tmp \
    && curl -OL https://github.com/coreos/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz \ 
    && tar zxf etcd-v${ETCD_VERSION}-linux-amd64.tar.gz \
    && cp etcd-v${ETCD_VERSION}-linux-amd64/etcdctl /usr/local/bin/etcdctl \
    && rm -rf etcd-v${ETCD_VERSION}-linux-amd64* \
    && chmod +x /usr/local/bin/etcdctl \     
    ; fi
    
RUN VERSION="v1.27.0" ; wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz ; tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin ; rm -f crictl-$VERSION-linux-amd64.tar.gz
RUN VERSION="1.3.1" ; wget https://github.com/containerd/nerdctl/releases/download/v${VERSION}/nerdctl-${VERSION}-linux-amd64.tar.gz ; tar Cxzvf /usr/local/bin nerdctl-$VERSION-linux-amd64.tar.gz ; rm -f nerdctl-$VERSION-linux-amd64.tar.gz 

COPY vm-cache-clean.sh containerd-clean.sh docker-clean.sh k8s-clean.sh etcd-empty-dir-cleanup.sh nerdctl-clean.sh /bin/
RUN chmod +x /bin/docker-clean.sh /bin/k8s-clean.sh /bin/etcd-empty-dir-cleanup.sh /bin/vm-cache-clean.sh /bin/containerd-clean.sh /bin/nerdctl-clean.sh ; mkdir -p /etc ; 
RUN echo -e "runtime-endpoint: unix:///run/containerd/containerd.sock\nimage-endpoint: unix:///run/containerd/containerd.sock" > /etc/crictl.yaml

ENV DOCKER_CLEAN_INTERVAL 1800
ENV CONATINERD_CLEAN_INTERVAL 1800
ENV DROP_CACHES_INTERVAL 604800
ENV DAYS 7

CMD ["bash", "/bin/docker-clean.sh"]
