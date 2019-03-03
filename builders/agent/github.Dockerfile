
ARG HUB_VERSION="2.6.1"

RUN curl -L -o /tmp/hub-${HUB_VERSION}.tgz https://github.com/github/hub/releases/download/v${HUB_VERSION}/hub-linux-386-${HUB_VERSION}.tgz \
    && tar -xz -C /tmp -f /tmp/hub-${HUB_VERSION}.tgz \
    && mv /tmp/hub-linux-386-${HUB_VERSION}/bin/hub /usr/bin \
    && rm -rf /tmp/hub-${HUB_VERSION} /tmp/hub
