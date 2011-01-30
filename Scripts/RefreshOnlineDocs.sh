#!/bin/sh

set -x

DOCSET=$INSTALL_DIR/Docset/html
VERSION=$(agvtool mvers -terse1 | perl -pe 's/(\d\.\d+)(\.\d+)*/$1/')

if ! test -f "$DOCSET/index.html" ; then
    echo "$dir does not contain index.html"
    exit 1
fi

DIR=/tmp/json-framework-$$
git clone --branch gh-pages git@github.com:stig/json-framework.git $DIR

cd $DIR

rm -rf $VERSION
cp -R $DOCSET/ $VERSION

rm -rf $VERSION/org.brautaset.JSON.docset
rm -f $VERSION/Makefile
rm -f $VERSION/*.xml
rm -f $VERSION/*.plist

rm -f api
ln -s $VERSION api

open $VERSION/index.html