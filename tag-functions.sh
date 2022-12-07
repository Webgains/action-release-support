#!/bin/bash

# Check whether the tag already exists in the submodule
function tag_exists() {
  git fetch --all --tags
  TAG="${tag_name}_${version}"
  if [ "$(git tag -l "$TAG")" ]
  then
    echo "Tag exists"
    return 0
  fi

  echo "Tag does not exist"
  return 1
}

# Tag the submodule and push those tags
function tag_submodule_and_push_tags() {
  echo "Tagging submodule"
  git tag -m "${project_name} Release ${version}" "${tag_name}_${version}"
  git push --tags
}

echo I am running! 

if ! tag_exists; then tag_submodule_and_push_tags; fi