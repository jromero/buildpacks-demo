#!/bin/bash
DIR=$(cd $(dirname $0) && pwd)

asciinema rec --overwrite -t "pack demo" -i 5 -c "${DIR}/pack-java.sh" "${DIR}/pack-java.cast"
