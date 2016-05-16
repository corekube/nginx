#!/bin/bash

export BUILD_COMMIT=${WERCKER_GIT_COMMIT-`git rev-parse HEAD`}
export APP_NAME=${WERCKER_APPLICATION_NAME-`basename $(git rev-parse --show-toplevel)`}
export DOCKER_REPO=${DOCKER_REPO-corekube/$APP_NAME}
export IMAGE_TAG=$BUILD_COMMIT
