Super-simple installation
=========================

By *far* the simplest way to start using JSON in your iPhone, iPad, or Mac application is to simply copy all the source files (the contents of the `Classes` folder) into your own Xcode project.

1. In the Finder, open the `json-framework/Classes` folder and select all the files.
1. Drop-and-drop them on the **Classes** group in the **Groups & Files** menu of your Xcode project.
1. Tick the **Copy items into destination group's folder** option.
1. Use `#import "JSON.h"` in  your source files.

That should be it. Now create that Twitter client!

Upgrading
---------

If you're upgrading from a previous version, make sure you're deleting the old JSON classes first, moving all the files to Trash.

Trouble-shooting
----------------
Check to see if the answers to the [Frequently Asked Questions][faq] are of any help.

[faq]: http://github.com/stig/json-framework/wiki/FrequentlyAskedQuestions

Alternative installation instructions
=====================================

Copying the JSON Classes into your project isn't the *only* way to use this framework. I've created a couple of examples that link to this framework rather than copy the sources. Check them out at github:

* [Linking to JSON Framework on the iPhone, iPad & iPod Touch](http://github.com/stig/JsonSampleIPhone)
* [Linking to JSON Framework on the Mac](http://github.com/stig/JsonSampleMac)

