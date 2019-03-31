#!/usr/bin/env sh
set -e

git checkout master
git merge dev

VERSION=`npx select-version-cli`

read -p "Releasing $VERSION - are you sure? (y/n)" -n 1 -r
echo    # (optional) move to a new line
echo $REPLY
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo "Releasing $VERSION ..."

  # build
  VERSION=$VERSION npm run dist

  # # publish theme
  # echo "Releasing theme-chalk $VERSION ..."
  # cd packages/theme-chalk
  # npm version $VERSION --message "[release] $VERSION"
  # if [[ $VERSION =~ "beta" ]]
  # then
  #   npm publish --tag beta
  #   echo 'npm publish theme beta....'
  # else
  #   npm publish
  #   echo 'npm publish theme....'
  # fi
  # cd ../..

  # commit
  echo 'a'
  git add -A
  echo 'b'
  git commit -m "[build] $VERSION"
  echo 'c'
  # npm version $VERSION --message "[release] $VERSION"

  # publish
  echo 0
  git push origin master
  echo 1
  git push origin refs/tags/v$VERSION
  echo 2
  git checkout dev
  echo 3
  git rebase master 
  echo 4
  git push origin dev
  echo 5

  # if [[ $VERSION =~ "beta" ]]
  # then
  #   npm publish --tag beta
  #   echo 'npm publish beta....'
  # else
  #   npm publish
  #   echo 'npm publish....'
  # fi
fi
