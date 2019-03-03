#!/bin/bash
set -e

. ./test-common.sh

export USE_CACHES=true
export NO_PROMPT=true
../build.sh

GITHUB() { curl -s -X ${3:-POST} $GITHUB_API/$1 -H "Authorization: token $GITHUB_TOKEN" -H "accept: application/json" -H "Content-Type: application/json" -d "$2"; }

cleanup() { 
	{
		TRACE-OFF
		docker-compose rm -sf registry || true
		DOCKER-RM $RELEASE $DOCKER_REGISTRY/$RELEASE './app'
		./nodevops cicd stop || true
		DOCKER-RM nodevops-ngrok nodevops-webhook
		[ ! -z "$HOOK_ID" ] && GITHUB repos/$ORG/$REPO/hooks/$HOOK_ID "" DELETE || true
		RM $RELEASE .git tmp 
	} > /dev/null
}

trap cleanup EXIT

# start local
TESTING "github"
cd $DIR
docker-compose rm -sf registry > /dev/null
docker-compose up -d registry
WAIT-CURL localhost:5000

export GITHUB_URL=github.com
export GITHUB_API=https://api.github.com
export GITHUB_USER=noodevops #noo
GITHUB_EMAIL="noodevops@what.ever"
export GITHUB_TOKEN="74f49e9ba881bf4469a8"
export GITHUB_TOKEN="${GITHUB_TOKEN}2427eb00f87c46336044" # ehhh
export WEBHOOK_SECRET=blablabla
ORG=noodevops #noo
REPO=test1
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
BASE="master-$TIMESTAMP"
BRANCH="develop-$TIMESTAMP"

# init
cd $DIR/examples/getting-started
ARTIFACT=getting-started
RM nodevops .git tmp 

# git clone
git clone https://$GITHUB_URL/$ORG/$REPO.git tmp > /dev/null
mv tmp/.git/ .
rm -rf tmp

export BUILD_TYPE="go docker"
export PUSH_TYPE=docker
export DEPLOY_TYPE=docker
export OPS_TYPE=github
export DOCKER_REGISTRY=localhost:5000

TRACE
docker run -it --rm -v $PWD:/workspace nodevops/agent init
./nodevops init $ARTIFACT go docker
./nodevops cicd start $ARTIFACT
TRACE-OFF
docker logs -f nodevops-webhook 2>&1 | grep -v "executing /workspace/nodevops" &

# git push to branches
./nodevops bash -c "
	git checkout -b $BASE;
	git add nodevops;
	git -c user.name=$GITHUB_USER -c user.email=$GITHUB_EMAIL commit -m'commit base';
	git push --set-upstream https://$GITHUB_USER:$GITHUB_TOKEN@$GITHUB_URL/$ORG/$REPO.git $BASE;
"

./nodevops bash -c "
	git checkout -b $BRANCH;
	git add . ;
	git -c user.name=$GITHUB_USER -c user.email=$GITHUB_EMAIL commit -m'commit branch';
	git push --set-upstream https://$GITHUB_USER:$GITHUB_TOKEN@$GITHUB_URL/$ORG/$REPO.git $BRANCH;
"

# create pull-request
ECHO "\ncreate pull-request"
OUT=$(./nodevops hub pull-request -m "pull_request_$BRANCH" -b $BASE -h $BRANCH)
ISSUE=$(echo $OUT | awk -F "/" '{print $NF}')
RELEASE="$(git rev-parse --abbrev-ref HEAD | sed 's,/,_,g')-$(git log -n 1 --pretty=format:'%h')"
ASSERT-DOCKER $DOCKER_REGISTRY/$RELEASE
DOCKER-RM $RELEASE $DOCKER_REGISTRY/$RELEASE
RM $RELEASE

# comment pull-request
ECHO "\ncomment pull-request"
GITHUB repos/$ORG/$REPO/issues/$ISSUE/comments "{\"body\": \"/pipeline\"}"
ASSERT-DOCKER $DOCKER_REGISTRY/$RELEASE
DOCKER-RM $RELEASE $DOCKER_REGISTRY/$RELEASE
RM $RELEASE

# merge pull-request
ECHO "\nmerge pull-request"
./nodevops bash -c "
	git checkout $BASE;
	git merge $BRANCH;
	git push --set-upstream https://$GITHUB_USER:$GITHUB_TOKEN@$GITHUB_URL/$ORG/$REPO.git $BASE;
	git branch --unset-upstream $BASE
"
RELEASE="$(git rev-parse --abbrev-ref HEAD | sed 's,/,_,g')-$(git log -n 1 --pretty=format:'%h')"
ASSERT-DOCKER $DOCKER_REGISTRY/$RELEASE
