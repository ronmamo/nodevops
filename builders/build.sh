#!/bin/bash
set -e
DIR="$(cd $(dirname $0) && pwd)"

if [ $# -lt 1 ] || [ ! -e $DIR/$1 ]; then
	echo "specify base - $(ls -d $DIR/*/))"
	exit 1
fi

ECHO() { printf "\e[1;32m$1 \e[0m$2\n"; }

build_args() {
	for ARG in $@; do
		if [[ ! -z ${!ARG} ]]; then
			BUILD_ARGS="$BUILD_ARGS --build-arg $ARG=${!ARG}"
		fi
	done
}

append_snippets() {
	for SNIP in ${@:3}; do 
		FILE=$SNIP.$2
		if [ -e $FILE ]; then
			echo "" >> $1 && echo "## $FILE >>" >> $1
			cat $FILE >> $1
		fi
	done
}

interpolate() {
	for ARG in ${@:2}; do
		if [[ ! -z ${!ARG} ]]; then
			sed -i "s/\$$ARG/${!ARG}/g" $1
			sed -i "s/\${$ARG}/${!ARG}/g" $1
		fi
	done
}

BASE=$1 && shift
SNIPPETS="$@"
IMAGE=${IMAGE:-nodevops/agent}
PUSH=${PUSH:-}
BUILD_DIR="$(cd $DIR/.. && pwd)"

cd $DIR/$BASE || cd $DIR
DOCKERFILE_TMP=$DIR/Dockerfile.tmp
POSTBUILD_TMP=$DIR/docker-postbuild.tmp
rm -f $DOCKERFILE_TMP || true
rm -f $POSTBUILD_TMP || true

append_snippets $POSTBUILD_TMP postbuild.sh $SNIPPETS

if [ -e $POSTBUILD_TMP ]; then
	interpolate $POSTBUILD_TMP GITHUB_TOKEN
	chmod +x $POSTBUILD_TMP
	SNIPPETS="$SNIPPETS postbuild"
fi

append_snippets $DOCKERFILE_TMP Dockerfile base $SNIPPETS nodevops

if [ ! -e $DOCKERFILE_TMP ]; then
	echo "could not build $IMAGE. specify snippets - $(ls $DIR/$BASE/ | cut -d "." -f 1 | tr '\n' ' ')"
	exit 1
fi

# build_args GITHUB_TOKEN SLACK_TOKEN ARTIFACTORY_APIKEY ARTIFACTORY_URL ARTIFACTORY_REPO BUILD_TYPE PUSH_TYPE DEPLOY_TYPE

ECHO "building:" "$IMAGE ($SNIPPETS)"
OUT=$(docker build $BUILD_ARGS $VOLUMES -t $IMAGE -f $DOCKERFILE_TMP $BUILD_DIR)
# docker build $BUILD_ARGS $VOLUMES -t $IMAGE -f $DOCKERFILE_TMP $BUILD_DIR

if [ ! -z "$PUSH" ]; then
  docker push $IMAGE
fi
