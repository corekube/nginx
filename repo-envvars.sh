#!/bin/bash

# default values are intended for local usage rather than ci/cd env
export BUILD_COMMIT=${WERCKER_GIT_COMMIT-`git rev-parse HEAD`}
export BUILD_BRANCH=${WERCKER_GIT_BRANCH-`git rev-parse --abbrev-ref HEAD`}
export APP_NAME=${WERCKER_APPLICATION_NAME-`basename $(git rev-parse --show-toplevel)`}
export DOCKER_REPO=${DOCKER_REPO-corekube/$APP_NAME}
export IMAGE_TAG=${BUILD_BRANCH}-$BUILD_COMMIT
