#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Disable interactive prompts
export GIT_TERMINAL_PROMPT=0

# Check for number of arguments
if [ $# -lt 5 ]; then
  echo 1>&2 "$0: not enough arguments"
  exit 2
elif [ $# -gt 5 ]; then
  echo 1>&2 "$0: too many arguments"
  exit 2
fi

REPO="$1"
REPO_CLONE_DIR="$2"
BRANCH="$3"
ORIGINAL_REVISION_ID="$4"
DATABASE_DIR="$(realpath ${5})"

# Clone the repository (if not already present at the given location)
if [ ! -d "$REPO_CLONE_DIR" ]; then
  git clone "$REPO" "$REPO_CLONE_DIR"
fi

# Switch to repo clone directory
pushd "$REPO_CLONE_DIR"

# Switch to (or create) the given branch
LOCAL_BRANCH_EXISTS=$(git branch --list ${BRANCH})
if [[ -z ${LOCAL_BRANCH_EXISTS} ]]; then
  git checkout -b "$BRANCH"
else
  git checkout "$BRANCH"
  # Ensure we are at the latest state
  git pull
fi

# Delete all the files in the git repository, if any
git rm -r --ignore-unmatch .

# Delete any untracked files
git clean -fdx

# Find the source location prefix (also known as the source-root).
# The src.zip contains absolute paths, so we need to determine the location of
# the source-root i.e. where the source code was checked out.
SOURCE_LOCATION_PREFIX=$(grep sourceLocationPrefix ~/codeql-home/databases/test-java/codeql-database.yml | cut -f 2 -d " " | tr -d '"')

# Copy just the source root from the source archive
unzip "$5/src.zip" "${SOURCE_LOCATION_PREFIX#/}/*" -d tmp
mv tmp${SOURCE_LOCATION_PREFIX}/* .
rmdir -p tmp${SOURCE_LOCATION_PREFIX}

# Add all the files
git add --all

# Commit the changes
git commit -m "Mirroring code for revision $ORIGINAL_REVISION_ID."

# Push the branch to github
git push -u origin "$BRANCH"