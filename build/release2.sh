#!/usr/bin/env sh
set -e

# git checkout master
# git merge dev

VERSION=`npx select-version-cli`

#read -p "Releasing $VERSION - are you sure? (y/n)" -n 1 -r
read -p "Releasing $VERSION - are you sure? (y/n)" REPLY
echo    # (optional) move to a new line
if test $REPLY = "y"
then
  echo "Releasing $VERSION ..."

  # build
  VERSION=$VERSION npm run dist

  # # publish theme
  # echo "Releasing theme-chalk $VERSION ..."
  # cd packages/theme-chalk
  # npm version $VERSION --message "[release] $VERSION" --allow-same-version
  # if test "$VERSION" != *beta*
  # then
  #   npm publish
  #   echo 'npm publish theme....'
  # else
  #   npm publish --tag beta
  #   echo 'npm publish theme beta....'
  # fi
  # cd ../..

  # # commit
  # git add -A
  # git commit -m "[build] $VERSION"
  # npm version $VERSION --message "[release] $VERSION" --allow-same-version

  # # publish
  # git push var master
  # git push var refs/tags/v$VERSION
  # git checkout dev
  # git rebase master
  # git push var dev

  # if test "$VERSION" != *beta*
  # then
  #   npm publish
  #   echo 'npm publish....'
  # else
  #   npm publish --tag beta
  #   echo 'npm publish beta....'
  # fi
fi
