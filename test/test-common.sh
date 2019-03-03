#!/bin/bash
set -e
shopt -s expand_aliases
DIR=$(cd $(dirname $0) && pwd)

ECHO() { printf "\e[1;38m$1 \e[0m"; shift && echo $@; }
TESTING() { ECHO "\n========================================\n\tTESTING $1\n========================================\n" "$2"; }
alias TRACE='set -x'
alias TRACE-OFF='{ set +x; } 2>/dev/null'

WAIT-CURL() { while ! curl -s -f -m 0.5 $1 > /dev/null; do sleep 2; done; }

RM() { for FILE in $@; do [ -e $FILE ] && rm -rf $FILE; done || true; }
DOCKER-RM() { for DOCKER in $@; do docker kill $(DOCKER-PS $DOCKER) 2> /dev/null || true; docker rmi -f $DOCKER 2> /dev/null || true; done; }
KUBE-RM() { kubectl delete -f $1 2> /dev/null || true; }

DOCKER-INSPECT() { out=$(docker inspect $1 2> /dev/null); echo $?; }
DOCKER-PS() { docker ps | grep $1 | awk '{print $1}'; }

ASSERT-FILE() { if [ -e $1 ]; then ECHO "\n\tASSERT: file exist $1"; else ECHO "\n\tASSERT FAILED: file missing $1" && exit 1; fi; }
ASSERT-DOCKER() { while [ $(DOCKER-INSPECT $1) != "0" ]; do sleep 2; done; ECHO "\n\tASSERT: docker pushed and deployed $1"; }
ASSERT-PODS() { ITEMS=$(kubectl get pods -o wide | tail -n 1 | awk '{print $1}'); if [[ "$ITEMS" =~ "$1" ]]; then ECHO "\n\tASSERT: pod exist $1"; else ECHO "\n\tASSERT failed: pods not exist $1"; fi; }
