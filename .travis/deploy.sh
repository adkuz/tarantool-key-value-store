#!/bin/sh

if [ "$TRAVIS_BRANCH" = "master" ]; then
    TAG="latest"
else
    TAG="$TRAVIS_BRANCH"
fi

echo "$DOCKER_PASS" | docker login -u $DOCKER_USER --password-stdin
docker build -f Dockerfile -t $(echo $TRAVIS_REPO_SLUG:$TAG | awk '{print tolower($0)}') .
docker push $(echo $TRAVIS_REPO_SLUG:$TAG | awk '{print tolower($0)}')
