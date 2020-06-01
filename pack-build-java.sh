#!/bin/bash
DIR=$(cd $(dirname $0) && pwd)

# include the magic
. "$DIR/demo-magic.sh"
PROMPT_TIMEOUT=0
TYPE_SPEED=15

echo "> cleaning docker system..."
docker rm -f $(docker ps -aq) &>/dev/null; docker system prune --all -f && docker volume prune -f

# hide the evidence
clear

# setup a temp-dir
tmp_dir=$(mktemp -d -t demo-XXXXXXXXXX)

pushd $tmp_dir > /dev/null

p "# let's download some samples"
pe "git clone git@github.com:buildpacks/samples.git"
pe "cd samples"

p "# what's in samples?"
pe "ls -l -d */"
wait

pe "ls -l apps/"
wait

pe "ls -al apps/java-maven"
wait

p "# what builder should we use?"
pe "pack suggest-builders"
wait

pe "pack set-default-builder gcr.io/paketo-buildpacks/builder:base"
wait

echo "# Alternatively: 'pack build <image-name> --builder <builder> ...'"
wait

p "# building the app"
pe "pack build my-java-app --path apps/java-maven"
wait
pe "docker images"
wait

p "# run the app"
pe "docker run -d -p 8080:8080 my-java-app"
sleep 3
wait
pe "browsh --time-limit 5 http://localhost:8080"
pe "docker ps | grep my-java-app"
DOCKER_CONTAINER=$(docker ps | grep my-java-app | cut -d ' ' -f1)
pe "docker stop ${DOCKER_CONTAINER}"

p "# Let's edit the app slightly"
cmd

p "# build it again (rebuild)"
pe "pack build my-java-app --path apps/java-maven"

p "# run it again"
pe "docker run -d -p 8080:8080 my-java-app"
sleep 3
wait
pe "browsh --time-limit 5 http://localhost:8080"
pe "docker ps | grep my-java-app"
DOCKER_CONTAINER=$(docker ps | grep my-java-app | cut -d ' ' -f1)
pe "docker stop ${DOCKER_CONTAINER}"
wait

p "# let's rebase"
pe "pack inspect-image my-java-app"
wait
pe "docker images"
wait

pe "pack rebase my-java-app --run-image gcr.io/paketo-buildpacks/run:0.0.17-base-cnb"
wait

pe "pack inspect-image my-java-app"
wait
pe "docker images"
wait

p "# run the app (one last time)"
pe "docker run -d -p 8080:8080 my-java-app"
sleep 3
wait
pe "browsh --time-limit 5 http://localhost:8080"
pe "docker ps | grep my-java-app"
DOCKER_CONTAINER=$(docker ps | grep my-java-app | cut -d ' ' -f1)
pe "docker stop ${DOCKER_CONTAINER}"

popd > /dev/null

# cleanup
rm -rf $tmp_dir
