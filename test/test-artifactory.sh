#!/bin/sh
set -e
DIR=$(cd $(dirname $0) && pwd)

error() { echo "error: $@"; exit 1; }

# artifactory
docker-compose up -d artifactory
while ! curl -s -f -m 0.5 localhost:8081; do sleep 2; done

curl -q -uadmin:password -XPOST "http://localhost:8081/artifactory/api/security/apiKey" || true
export ARTIFACTORY_APIKEY=$(curl -uadmin:password -XGET "http://localhost:8081/artifactory/api/security/apiKey" | jq -r .apiKey)
export ARTIFACTORY_REPO=example-repo-local
export ARTIFACTORY_URL=http://host.docker.internal:8081/artifactory

# init
cd examples/getting-started
[ -e rm getting-started-test-2.zip ] && rm getting-started-test-2.zip

docker run --rm -v $PWD:/workspace nodevops/agent init
./nodevops init getting-started-test-2 artifactory

# build
RELEASE=getting-started-test-2.zip
BUILD_TYPE=zip ./nodevops build $RELEASE

# push
./nodevops push $RELEASE

rm $RELEASE
./nodevops pull $RELEASE

[ -e $RELEASE ] || error "should pulled"

docker-compose stop artifactory &
