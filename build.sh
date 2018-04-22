#!/bin/sh
set -e
cd $(dirname $0)

S6_RELEASE=v1.21.4.0

case $( uname -m ) in
armv7l)
  REPO="angelnu/ttrss-arm"
  S6_RELEASE=https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-arm.tar.gz
  ;;
x86_64)
  REPO="angelnu/ttrss-amd64"
  S6_RELEASE=https://github.com/just-containers/s6-overlay/releases/download/$S6_RELEASE/s6-overlay-amd64.tar.gz
  ;;
*)
  echo "Unknown arch $( uname -p )"
  exit 1
  ;;
esac

docker build -t $REPO --build-arg S6_RELEASE=$S6_RELEASE .
docker push $REPO
