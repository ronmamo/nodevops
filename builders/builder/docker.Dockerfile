
ARG DOCKER_VERSION="18.09.0"

RUN curl -L -o /tmp/docker-${DOCKER_VERSION}.tgz https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz \
    && tar -xz -C /tmp -f /tmp/docker-${DOCKER_VERSION}.tgz \
    && mv /tmp/docker/docker /usr/bin \
    && rm -rf /tmp/docker-${DOCKER_VERSION} /tmp/docker
