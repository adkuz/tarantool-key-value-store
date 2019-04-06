#!/bin/sh


if [ "$TRAVIS_BRANCH" = "master" ]; then
    TAG="latest"
else
    TAG="$TRAVIS_BRANCH"
fi

echo "$DOCKER_PASS" | docker login -u $DOCKER_USER --password-stdin

export DOCKER_IMAGE=ax_tarantool:$TAG

docker build -f Dockerfile -t $DOCKER_USER/$DOCKER_IMAGE .
# docker build --tag=registry.heroku.com/${HEROKU_APP_NAME}/web .

docker push $DOCKER_USER/$DOCKER_IMAGE
# docker push registry.heroku.com/${HEROKU_APP_NAME}/web
