#!/usr/bin/env sh
set -e

git checkout master
git merge dev

VERSION=`npx select-version-cli`

#read -p "Releasing $VERSION - are you sure? (y/n)" -n 1 -r
read -p "Releasing $VERSION - are you sure? (y/n)" REPLY
echo    # (optional) move to a new line
if test $REPLY = "y"
then
  echo "Releasing $VERSION ..."

  # build
  VERSION=$VERSION npm run dist

  # version
  node ./build/bin/version.js $VERSION

  # commit
  git add -A
  git commit -m "[build] $VERSION"
  npm version $VERSION --message "[release] $VERSION" --allow-same-version

  # publish
  git push origin master
  git push origin refs/tags/v$VERSION
  git checkout dev
  git rebase master
  git push origin dev
fi
