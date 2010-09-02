#!/bin/sh

set -x

DOCSET=$INSTALL_DIR/Docset/html
VERSION=$(agvtool mvers -terse1 | perl -pe 's/(\d\.\d+)(\.\d+)*/$1/')

apidir=$VERSION
latest=api

if ! test -f "$DOCSET/index.html" ; then
    echo "$dir does not contain index.html"
    exit 1
fi


status=$(git status -s)
if ! test -z $status ; then
    echo "Checkout has uncommitted changes"
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
git checkout gh-pages

rm -f $latest
rm -rf $apidir
mv $tmpdir $apidir
ln -s $apidir $latest

git add -A
git commit -m "refresh api docs for v$VERSION"
git checkout $branch

