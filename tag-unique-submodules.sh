##!/bin/bash

# Describe the parameters required by this script
while getopts p:v:t: flag
do
    case "${flag}" in
        p) project_name=${OPTARG};;
        v) version=${OPTARG};;
        t) tag_name=${OPTARG};;
        *) echo "Invalid flag supplied"; exit 1;
    esac
done

export project_name
export version
export tag_name

# Check whether any identical submodules point at different git hashes. If they do, we need to
# stop the process early otherwise the git tags won't work correctly.
function identical_submodules_point_at_same_hash() {
  submodule_status=$(git submodule status)

  # Count the unique submodules in use
  unique_submodules=$(echo "$submodule_status" | awk '{ print $2 }' | awk -F/ '{ print $NF }' | uniq -c | wc -l | xargs)

  # Count the unique submodule hashes
  unique_hashes=$(echo "$submodule_status" | awk '{ print $1 }' | uniq -c | wc -l | xargs)

  echo "There is ${unique_submodules} unique submodule(s) and ${unique_hashes} unique hash(es)"

  # If the amount of unique hashes is different to the amount of unique submodules then it means at least one
  # of the identical submodules has a different hash
  if [[ $unique_submodules -eq $unique_hashes ]]
  then
    return 0
  fi

  return 1
}

export -f identical_submodules_point_at_same_hash

if ! identical_submodules_point_at_same_hash
then
  echo "Identical submodules are not pointing at the same git hash"
  exit 1
fi

git submodule foreach "
  git fetch --all --tags
  TAG=\${tag_name}_\${version};
  TAG_EXISTS=\$(git tag -l \$TAG)
  if [ -z \"\${TAG_EXISTS}\" ];
    then echo Tag does not exist;
         echo Tagging submodule;
         git tag -m \"\${project_name} Release \${version}\" \${tag_name}_\${version};
         git push --tags;
    else echo Tag exists;
  fi;
"