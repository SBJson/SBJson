#!/bin/sh

set -x

DOCSET=$INSTALL_DIR/Docset/html

apidir=api

if ! test -f "$DOCSET/index.html" ; then
    echo "$dir does not contain index.html"
    exit 1
fi

tmp=$(basename $0)
tmpdir=$(mktemp -d "/tmp/$tmp.XXXXXX")

cp -R $DOCSET/ $tmpdir

rm -rf $tmpdir/org.brautaset.JSON.docset
rm -f $tmpdir/Makefile
rm -f $tmpdir/*.xml
rm -f $tmpdir/*.plist

branch=$(git branch | awk '$1 == "*" { print $2 }' )
git stash
git checkout gh-pages

rm -rf $apidir
mv $tmpdir $apidir

git add -A
git commit -m 'refresh api docs'
git checkout $branch
git stash pop -q

