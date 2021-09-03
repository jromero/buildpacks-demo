#!/usr/bin/env bash
# set -x

DEMO_IMAGE_NAME=petclinic-demo
DEMO_CONTAINER_NAME=$DEMO_IMAGE_NAME

function reset() {
    docker stop ${DEMO_CONTAINER_NAME} 2>/dev/null
    docker rm ${DEMO_CONTAINER_NAME} 2>/dev/null
    docker rmi ${DEMO_IMAGE_NAME} 2>/dev/null
    # TODO: clear dependencies
}

reset
clear

TMPDIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'tempdir')
pushd $TMPDIR >/dev/null
# load some magic
curl -sSL https://raw.githubusercontent.com/paxtonhare/demo-magic/master/demo-magic.sh >demo-magic.sh
. demo-magic.sh

PROMPT_TIMEOUT=1

pe "git clone https://github.com/spring-projects/spring-petclinic.git"

pei "cd spring-petclinic"

pe "pack config default-builder cnbs/sample-builder:bionic"

pe "pack build ${DEMO_IMAGE_NAME}"

pe "docker run -d -p 8080:8080 --rm --name ${DEMO_CONTAINER_NAME} ${DEMO_IMAGE_NAME}"

pe 'open "http://localhost:8080"'

pe "docker stop ${DEMO_CONTAINER_NAME}"

pe "cat src/main/resources/messages/messages.properties"

pe 'sed -i.bak "/welcome=/ s/=.*/=Welcome Back!/" src/main/resources/messages/messages.properties'

pe "pack build ${DEMO_IMAGE_NAME}"

pe "docker run -d -p 8080:8080 --rm --name ${DEMO_CONTAINER_NAME} ${DEMO_IMAGE_NAME}"

pe 'open "http://localhost:8080"'

pei "docker stop ${DEMO_CONTAINER_NAME}"

popd >/dev/null
