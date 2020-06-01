#!/bin/bash
DIR=$(cd $(dirname $0) && pwd)

asciinema play -i 3 $DIR/pack-java.cast
