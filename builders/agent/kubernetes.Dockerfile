
ARG KUBE_VERSION="1.13.2"

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBE_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl

ENV KUBECONFIG=/workspace/.kube/config