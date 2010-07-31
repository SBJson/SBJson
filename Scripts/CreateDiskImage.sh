#!/bin/sh

set -x

# Determine the project name and version
VERS=$(agvtool mvers -terse1)

# Derived names
VOLNAME=${PROJECT}_${VERS}
DISK_IMAGE=$BUILD_DIR/$VOLNAME
DISK_IMAGE_FILE=$INSTALL_DIR/$VOLNAME.dmg

# Remove old targets
rm -f $DISK_IMAGE_FILE
test -d $DISK_IMAGE && chmod -R +w $DISK_IMAGE && rm -rf $DISK_IMAGE
mkdir -p $DISK_IMAGE

# Copy the source verbatim into the disk image.
cp -p -R $SOURCE_ROOT/Classes $DISK_IMAGE/$PROJECT

DOCDIR=$DISK_IMAGE/Documentation

cp -p -R $INSTALL_DIR/Docset/html/ $DOCDIR
rm -rf $DOCDIR/org.brautaset.JSON.docset
rm -f $DOCDIR/Makefile
rm -f $DOCDIR/*.xml
rm -f $DOCDIR/*.plist

cat <<HTML > $DISK_IMAGE/Documentation.html
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><head><meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<script type="text/javascript">
<!--
window.location = "Documentation/index.html"
//-->
</script>
</head>
<body>
<p>Aw, shucks! I tried to redirect you to the <a href="Documentaton/index.html">api documentation</a> but obviously failed. Please find it yourself. </p>
</body>
</html>
HTML

for f in $SOURCE_ROOT/*.md ; do
    dst=$(basename $f)
    ~/Dropbox/Scripts/Markdown.pl $f > $DISK_IMAGE/${dst%.md}.html
done

hdiutil create -fs HFS+ -volname $VOLNAME -srcfolder $DISK_IMAGE $DISK_IMAGE_FILE
