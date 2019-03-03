
RUN curl -Lo /usr/bin/jfrog https://api.bintray.com/content/jfrog/jfrog-cli-go/\$latest/jfrog-cli-linux-386/jfrog?bt_package=jfrog-cli-linux-386 && \
    chmod a+x /usr/bin/jfrog

ARG ARTIFACTORY_REPO
ARG ARTIFACTORY_URL
ARG ARTIFACTORY_APIKEY

ENV ARTIFACTORY_REPO=
ENV ARTIFACTORY_URL=
ENV ARTIFACTORY_APIKEY=

RUN jfrog rt c $ARTIFACTORY_REPO --url=$ARTIFACTORY_URL --apikey=$ARTIFACTORY_APIKEY
