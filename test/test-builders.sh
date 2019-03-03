#!/bin/bash
set -e

. ./test-common.sh

export USE_CACHES=true
export NO_PROMPT=true
export NO_DETECT=true
../build.sh

# java
TESTING "example-java"
cd $DIR/examples/example-java
RM target/ nodevops .git

TRACE
docker run --rm -v $PWD:/workspace nodevops/agent init
./nodevops init example-java maven
./nodevops build
TRACE-OFF

ASSERT-FILE "target/helloworld-jar-with-dependencies.jar"

# go
TESTING "getting-started"
cd $DIR/examples/getting-started
RM getting-started-test-2 nodevops

TRACE
docker run --rm -v $PWD:/workspace nodevops/agent init
./nodevops init getting-started-test-2 go
./nodevops build getting-started-test-2
TRACE-OFF

ASSERT-FILE "getting-started-test-2"
