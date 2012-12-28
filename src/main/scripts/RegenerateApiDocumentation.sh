#!/bin/sh

VERS=3.2
OUTPUT=~/Dropbox/DocSets/SBJson

appledoc \
--project-version $VERS \
--output $OUTPUT \
src/main/resources/AppledocSettings.plist

TARGET=../json-framework-pages/api

if ! test -d $TARGET ; then
    echo "$TARGET does not exist; exiting now"
    exit
fi

cp $OUTPUT/publish/* $TARGET

VTARGET=$TARGET/$VERS
rm -rf $VTARGET
cp -r $OUTPUT/html $VTARGET


