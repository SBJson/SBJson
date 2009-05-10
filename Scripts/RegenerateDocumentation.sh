#!/bin/sh
# See also http://developer.apple.com/tools/creatingdocsetswithdoxygen.html 

set -x

VERSION=$(agvtool mvers -terse1)

DOXYFILE=$DERIVED_FILES_DIR/doxygen.config
DOXYGEN=/Applications/Doxygen.app/Contents/Resources/doxygen
DOCSET=$INSTALL_DIR/Documentation

mkdir -p $DERIVED_FILES_DIR || exit 1
mkdir -p $DOCSET || exit 1

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
INPUT                  = $SOURCE_ROOT/Source
FILE_PATTERNS          = *.h *.m

HIDE_UNDOC_MEMBERS     = YES
HIDE_UNDOC_CLASSES     = YES
HIDE_UNDOC_RELATIONS   = YES
REPEAT_BRIEF           = NO

GENERATE_LATEX         = NO
GENERATE_HTML          = YES
GENERATE_DOCSET        = NO

EOF

#  Run doxygen on the updated config file.
$DOXYGEN $DOXYFILE

# Replace the old dir with the newly generated one.
rm -f $SOURCE_ROOT/documentation/*
cp -p $INSTALL_DIR/Documentation/html/* $SOURCE_ROOT/documentation
cd $SOURCE_ROOT/documentation

# Revert files that differ only in the timestamp.
svn diff *.html | diffstat | awk '$3 == "2" { print $1 }' | xargs svn revert

# Add/remove files from subversion.
svn st | awk '
    $1 == "?" { print "svn add", $2 }
    $1 == "!" { print "svn delete",  $2 }
' | sh -

svn propset svn:mime-type text/html *.html
svn propset svn:mime-type text/css *.css
svn propset svn:mime-type image/png *.png
svn propset svn:mime-type image/gif *.gif

