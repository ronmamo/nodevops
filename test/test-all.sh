#!/bin/sh
set -e

./test-builders.sh

./test-gitea.sh

./test-github.sh

./test-minikube.sh

#./test-artifactory.sh
