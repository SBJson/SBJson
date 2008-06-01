#!/bin/sh

# Determine the project name and version
PROJ=$(ls -d *.xcodeproj | sed s/.xcodeproj//)
VERS=$(agvtool mvers -terse1)

DIST=${PROJ}_${VERS}
DMG=$DIST.dmg

# Remove old targets
rm -f $DMG
test -d $DIST && chmod -R +w $DIST && rm -rf $DIST

xcodebuild -configuration Release -target JSON install

mkdir $DIST
cp -p -R /tmp/Frameworks/$PROJ.framework $DIST/
cp -p -R Doxygen.docset/html $DIST/html
hdiutil create -fs HFS+ -volname $DIST -srcfolder $DIST $DMG
