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
rm -rf $DIST/html/org.brautaset.${PROJ}.docset


cat <<HTML > $DIST/API.html
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><head><meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<script type="text/javascript">
<!--
window.location = "html/index.html"
//-->
</script>
</head>
<body>
<p>Aw, shucks! I tried to redirect you to the <a
href="html/index.html">api documentation</a> but obviously
failed. Please find it yourself. </p>
</body>
</html>
HTML

cp -p CREDITS $DIST
cp -p README $DIST
cat <<DOCINSTALL >> $DIST/README

You can install the API documentation in this dmg by copying
the 'html' directory to a writable location on your hard-drive,
cd into the directory and type 'make install'.

DOCINSTALL

hdiutil create -fs HFS+ -volname $DIST -srcfolder $DIST $DMG
