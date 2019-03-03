#!/bin/bash
set -e

. ./test-common.sh

cleanup() { 
	{
		TRACE-OFF
		RM $RELEASE
		DOCKER-RM $RELEASE
        KUBE-RM .
	} > /dev/null
}

trap cleanup EXIT

# start minikube
TESTING "minikube"
minikube status || \
case $OSTYPE in 
    linux*) minikube start -vm-driver=none ;;
    *) minikube start ;;
esac

eval $(minikube docker-env)
echo

export USE_CACHES=true
export NO_PROMPT=true
export NO_DETECT=true
../build.sh

# init
cd examples/getting-started
RELEASE=getting-started-test-3
RM nodevops $RELEASE
DOCKER-RM $RELEASE
KUBE-RM .

TRACE
docker run -it --rm -v $PWD:/workspace nodevops/agent init
./nodevops init getting-started go docker kubernetes
./nodevops build $RELEASE
# ./nodevops push $RELEASE
./nodevops deploy $RELEASE
TRACE-OFF

ASSERT-DOCKER $RELEASE
ASSERT-PODS $RELEASE
