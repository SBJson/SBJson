#!/bin/sh
# See also http://developer.apple.com/tools/creatingdocsetswithdoxygen.html 

set -x

VERSION=$(agvtool mvers -terse1)

DOXYFILE=$DERIVED_FILES_DIR/doxygen.config
DOXYGEN=/Applications/Doxygen.app/Contents/Resources/doxygen
DOCSET=$INSTALL_DIR/Docset

rm -rf $DOCSET
mkdir -p $DOCSET || exit 1
mkdir -p $DERIVED_FILES_DIR || exit 1

if ! test -x $DOXYGEN ; then
	echo "*** Install Doxygen to get documentation generated for you automatically ***"
	exit 1
fi

# Create a doxygen configuration file with only the settings we care about
$DOXYGEN -g - > $DOXYFILE

cat <<EOF >> $DOXYFILE

PROJECT_NAME           = $FULL_PRODUCT_NAME
PROJECT_NUMBER         = $VERSION
OUTPUT_DIRECTORY       = $DOCSET
INPUT                  = $SOURCE_ROOT/Classes
FILE_PATTERNS          = *.h *.m

HIDE_UNDOC_MEMBERS     = YES
HIDE_UNDOC_CLASSES     = YES
HIDE_UNDOC_RELATIONS   = YES
REPEAT_BRIEF           = NO
CASE_SENSE_NAMES       = YES
INLINE_INHERITED_MEMB  = YES
SHOW_FILES             = NO
SHOW_INCLUDE_FILES     = NO
GENERATE_LATEX         = NO
SEARCHENGINE           = NO
GENERATE_HTML          = YES
GENERATE_DOCSET        = YES
DOCSET_FEEDNAME        = "$PROJECT.framework API Documentation"
DOCSET_BUNDLE_ID       = org.brautaset.$PROJECT

EOF

#  Run doxygen on the updated config file.
#  doxygen creates a Makefile that does most of the heavy lifting.
$DOXYGEN $DOXYFILE

#  make will invoke docsetutil. Take a look at the Makefile to see how this is done.
make -C $DOCSET/html install

#  Construct a temporary applescript file to tell Xcode to load a docset.
rm -f $TEMP_DIR/loadDocSet.scpt

cat <<EOF > $TEMP_DIR/loadDocSet.scpt
tell application "Xcode"
	load documentation set with path "/Users/$USER/Library/Developer/Shared/Documentation/DocSets/org.brautaset.${PROJECT}.docset/"
end tell
EOF

# Run the load-docset applescript command.
osascript $TEMP_DIR/loadDocSet.scpt
