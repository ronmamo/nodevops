
# todo use .env
ARG BUILD_TYPE
ARG PUSH_TYPE
ARG DEPLOY_TYPE

ENV BUILD_TYPE=
ENV PUSH_TYPE=
ENV DEPLOY_TYPE=

ENV PATH=/nodevops:/nodevops/scripts:$PATH

WORKDIR /workspace

VOLUME /workspace

ADD scripts /nodevops/scripts
