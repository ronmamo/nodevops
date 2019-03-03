#!/bin/bash
set -e

. ./test-common.sh

export USE_CACHES=true
export NO_PROMPT=true
../build.sh

GITEA() { curl -s -X POST $GITEA_HOST_URL/api/v1/$1 -H "Authorization: token $GITHUB_TOKEN" -H "accept: application/json" -H "Content-Type: application/json" -d "$2" > /dev/null; }

cleanup() { 
	{
		TRACE-OFF
		RM $RELEASE
		docker-compose rm -sf registry gitea || true
		DOCKER-RM $RELEASE $DOCKER_REGISTRY/$RELEASE './app' nodevops-webhook
		./nodevops cicd stop || true
		DOCKER-RM nodevops-webhook
	} > /dev/null
}

trap cleanup EXIT

# start local
TESTING "gitea"
cd $DIR
docker-compose rm -sf registry > /dev/null
docker-compose up -d registry
WAIT-CURL localhost:5000
docker-compose rm -sf gitea > /dev/null
docker-compose up -d gitea
WAIT-CURL localhost:3000
curl -s -X POST localhost:3000/install -d 'db_type=SQLite3&db_host=localhost%3A3306&db_user=root&db_passwd=&db_name=gitea&ssl_mode=disable&db_path=%2Fdata%2Fgitea%2Fgitea.db&app_name=Gitea%3A+Git+with+a+cup+of+tea&repo_root_path=%2Fdata%2Fgit%2Frepositories&lfs_root_path=%2Fdata%2Fgit%2Flfs&run_user=git&domain=localhost&ssh_port=22&http_port=3000&app_url=http%3A%2F%2Flocalhost%3A3000%2F&log_root_path=%2Fdata%2Fgitea%2Flog&smtp_host=&smtp_from=&smtp_user=&smtp_passwd=&enable_federated_avatar=on&enable_open_id_sign_in=on&enable_open_id_sign_up=on&default_allow_create_organization=on&default_enable_timetracking=on&no_reply_address=noreply.example.org&admin_name=nodevops&admin_passwd=password&admin_confirm_passwd=password&admin_email=nodevops%40example.org' > /dev/null

export GITHUB_URL=host.docker.internal:3000
export GITHUB_API=$GITHUB_URL/api/v1
export GITHUB_USER=nodevops
GITHUB_EMAIL="nodevops@what.ever"
GITEA_HOST_URL=localhost:3000
export GITHUB_TOKEN=$(curl -s -u nodevops:password $GITEA_HOST_URL/api/v1/users/nodevops/tokens -d 'name=token1' | jq -r .sha1)
export WEBHOOK_SECRET=blablabla
echo "GITHUB_TOKEN: $GITHUB_TOKEN"
ORG=nodevops
REPO=test1
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
BASE="master-$TIMESTAMP"
BRANCH="develop-$TIMESTAMP"

# create repo
GITEA user/repos "{\"name\": \"$REPO\", \"auto_init\": true, \"readme\": \"Default\"}"

# init
cd $DIR/examples/getting-started
ARTIFACT=getting-started
RM nodevops .git tmp

# git clone
git clone http://$GITEA_HOST_URL/$ORG/$REPO.git tmp
mv tmp/.git/ .
rm -rf tmp

export BUILD_TYPE="go docker"
export PUSH_TYPE=docker
export DEPLOY_TYPE=docker
export OPS_TYPE=gitea
export DOCKER_REGISTRY=localhost:5000

TRACE
docker run -it --rm -v $PWD:/workspace nodevops/agent init
./nodevops init $ARTIFACT go docker github
./nodevops cicd start $ARTIFACT
TRACE-OFF

while [ "$(curl -s http://localhost:3001 2> /dev/null)" != "Bad request" ]; do sleep 2; done
docker logs -f $(docker ps | grep webhook | awk '{print $1}') &

# create webhook
GITEA repos/$ORG/$REPO/hooks "{\"active\": true, \"events\":[\"create\",\"delete\",\"fork\",\"push\",\"issues\",\"issue_comment\",\"pull_request\",\"repository\",\"release\"], \"type\": \"gitea\", \"config\": { \"url\": \"http://host.docker.internal:3001\", \"content_type\": \"json\", \"secret\": \"$WEBHOOK_SECRET\"}}" 

# git push to branches
./nodevops bash -c "
	git checkout -b $BASE;
	git add nodevops;
	git -c user.name=$GITHUB_USER -c user.email=$GITHUB_EMAIL commit -m'commit base';
	git push --set-upstream http://$GITHUB_USER:$GITHUB_TOKEN@$GITHUB_URL/$ORG/$REPO.git $BASE;
"

./nodevops bash -c "
	git checkout -b $BRANCH;
	git add . ;
	git -c user.name=$GITHUB_USER -c user.email=$GITHUB_EMAIL commit -m'commit branch';
	git push --set-upstream http://$GITHUB_USER:$GITHUB_TOKEN@$GITHUB_URL/$ORG/$REPO.git $BRANCH;
"

# create pull-request
ECHO "\ncreate pull-request"
GITEA repos/$ORG/$REPO/pulls "{\"assignee\": \"nodevops\", \"assignees\": [\"\"], \"base\": \"$BASE\", \"body\": \"body\", \"head\": \"$BRANCH\", \"labels\": [0], \"milestone\": 0, \"title\": \"pull request 1\"}"
ISSUE=1
RELEASE="$(git rev-parse --abbrev-ref HEAD | sed 's,/,_,g')-$(git log -n 1 --pretty=format:'%h')"
ASSERT-DOCKER $DOCKER_REGISTRY/$RELEASE
DOCKER-RM $RELEASE $DOCKER_REGISTRY/$RELEASE

# comment pull-request
ECHO "\ncomment pull-request"
GITEA repos/$ORG/$REPO/issues/$ISSUE/comments "{\"body\": \"comment\"}"
ASSERT-DOCKER $DOCKER_REGISTRY/$RELEASE
DOCKER-RM $RELEASE $DOCKER_REGISTRY/$RELEASE

# merge pull-request
ECHO "\nmerge pull-request"
GITEA repos/$ORG/$REPO/pulls/$ISSUE/merge '{ "merge_title_field": "merge pr #1", "do": "merge" }' 
RELEASE="$(git rev-parse --abbrev-ref HEAD | sed 's,/,_,g')-$(git log -n 1 --pretty=format:'%h')"
ASSERT-DOCKER $DOCKER_REGISTRY/$RELEASE
