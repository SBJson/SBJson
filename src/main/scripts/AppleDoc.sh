#!/bin/sh

VERS=3.2
OUTPUT=~/Dropbox/DocSets/SBJson

appledoc \
--project-name "SBJson" \
--project-version $VERS \
--project-company "Stig Brautaset" \
--company-id "org.brautaset" \
--docset-atom-filename "SBJson.atom" \
--docset-feed-url "http://sbjson.org/api/%DOCSETATOMFILENAME" \
--docset-package-url "http://sbjson.org/api/%DOCSETPACKAGEFILENAME" \
--output $OUTPUT \
--publish-docset \
--logformat xcode \
--keep-undocumented-objects \
--keep-undocumented-members \
--keep-intermediate-files \
--no-repeat-first-par \
--no-warn-invalid-crossref \
--ignore "*.m" \
--index-desc "README.md" \
Classes

TARGET=../json-framework-pages/api
cp $OUTPUT/publish/* $TARGET

VTARGET=$TARGET/$VERS
rm -rf $VTARGET
cp -r $OUTPUT/html $VTARGET


