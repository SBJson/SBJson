#!/bin/sh

set -x

DOCSET=$INSTALL_DIR/Docset/html

apidir=~/Dropbox/Public/json-framework/api

if ! test -f "$DOCSET/index.html" ; then
    echo "$dir does not contain index.html"
    exit 1
fi

if ! test -f "$apidir/index.html" ; then
    echo "$apidir does not contain index.html"
    exit 1
fi

tmp=$(basename $0)
tmpdir=$(mktemp -d "/tmp/$tmp.XXXXXX")

cp -R $DOCSET/ $tmpdir

rm -rf $tmpdir/org.brautaset.JSON.docset
rm -f $tmpdir/Makefile
rm -f $tmpdir/*.xml
rm -f $tmpdir/*.plist

rm -rf $apidir
mv $tmpdir $apidir