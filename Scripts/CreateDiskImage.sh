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

IPHONE_SDK=2.2.1

# Create the iPhone SDK directly in the disk image folder.
xcodebuild -target libjson -configuration Release -sdk iphoneos$IPHONE_SDK install \
    ARCHS=armv6 \
    DSTROOT=$DISK_IMAGE/SDKs/JSON/iphoneos.sdk || exit 1
sed -e "s/%PROJECT%/$PROJECT/g" \
    -e "s/%VERS%/$VERS/g" \
    -e "s/%IPHONE_SDK%/$IPHONE_SDK/g" \
    $SOURCE_ROOT/Resources/iphoneos.sdk/SDKSettings.plist > $DISK_IMAGE/SDKs/JSON/iphoneos.sdk/SDKSettings.plist || exit 1

xcodebuild -target libjson -configuration Release -sdk iphonesimulator$IPHONE_SDK install \
    ARCHS=i386 \
    DSTROOT=$DISK_IMAGE/SDKs/JSON/iphonesimulator.sdk || exit 1
sed -e "s/%PROJECT%/$PROJECT/g" \
    -e "s/%VERS%/$VERS/g" \
    -e "s/%IPHONE_SDK%/$IPHONE_SDK/g" \
    $SOURCE_ROOT/Resources/iphonesimulator.sdk/SDKSettings.plist > $DISK_IMAGE/SDKs/JSON/iphonesimulator.sdk/SDKSettings.plist || exit 1    

# Allow linking statically into normal OS X apps
xcodebuild -target libjson -configuration Release -sdk macosx10.5 install \
    DSTROOT=$DISK_IMAGE/SDKs/JSON/macosx.sdk || exit 1

# Copy the source verbatim into the disk image.
cp -p -R $SOURCE_ROOT/Source $DISK_IMAGE/$PROJECT
rm -rf $DISK_IMAGE/$PROJECT/.svn

# Create the documentation
xcodebuild -target Documentation -configuration Release install || exit 1
cp -p -R $INSTALL_DIR/Documentation/html $DISK_IMAGE/Documentation
rm -rf $DISK_IMAGE/Documentation/.svn

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

cp -p $SOURCE_ROOT/README $DISK_IMAGE
cp -p $SOURCE_ROOT/Credits.rtf $DISK_IMAGE
cp -p $SOURCE_ROOT/Install.rtf $DISK_IMAGE
cp -p $SOURCE_ROOT/Changes.rtf $DISK_IMAGE

hdiutil create -fs HFS+ -volname $VOLNAME -srcfolder $DISK_IMAGE $DISK_IMAGE_FILE
