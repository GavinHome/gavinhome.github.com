#!/usr/bin/env sh
set -e

# git checkout master
# git merge dev

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
  npm version $VERSION --message "[release] $VERSION"
  node ./build/bin/version.js

  # commit
  git add -A
  git commit -m "[build] $VERSION"
  npm version $VERSION --message "[release] $VERSION"
  echo $VERSION

  # publish
  git push origin master
  git push origin refs/tags/v$VERSION
  git checkout dev
  git rebase master 
  git push origin dev

  # if [[ $VERSION =~ "beta" ]]
  # then
  #   npm publish --tag beta
  #   echo 'npm publish beta....'
  # else  
  #   npm publish
  #   echo 'npm publish....'
  # fi
fi
