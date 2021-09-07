#!/usr/bin/env bash
# set -x

DIR=$(cd $(dirname $0) && pwd)

asciinema rec --overwrite -t "pack build" -i 5 -c "${DIR}/pack-build.sh" "${DIR}/pack-build.cast"
