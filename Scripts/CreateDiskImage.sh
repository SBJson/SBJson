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

# Create the Embedded framework and copy it to the disk image.
xcodebuild -target JSON -configuration Release install || exit 1
cp -p -R $INSTALL_DIR/../Frameworks/$PROJECT.framework $DISK_IMAGE

# Copy the source verbatim into the disk image.
cp -p -R $SOURCE_ROOT/Source $DISK_IMAGE/$PROJECT

# Create the documentation
xcodebuild -target Documentation -configuration Release install || exit 1
cp -p -R $INSTALL_DIR/Docset/html $DISK_IMAGE/Documentation
rm -f $DISK_IMAGE/Documentation/Makefile
rm -f $DISK_IMAGE/Documentation/Info.plist
rm -f $DISK_IMAGE/Documentation/Nodes.xml
rm -f $DISK_IMAGE/Documentation/Tokens.xml
rm -rf $DISK_IMAGE/Documentation/org.brautaset.$PROJECT.docset

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
<p>Aw, shucks! I tried to redirect you to the <a
href="Documentaton/html/index.html">api documentation</a> but obviously
failed. Please find it yourself. </p>
</body>
</html>
HTML

cp -p $SOURCE_ROOT/README $DISK_IMAGE
cp -p $SOURCE_ROOT/Credits.rtf $DISK_IMAGE
cp -p $SOURCE_ROOT/Install.rtf $DISK_IMAGE

hdiutil create -fs HFS+ -volname $VOLNAME -srcfolder $DISK_IMAGE $DISK_IMAGE_FILE