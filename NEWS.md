4.0.0-alpha (November 9th, 2013)
================================

I'm delighted to announce SBJson 4.0.0-ALPHA. Notable changes since 3.2.0:

* [#160](https://github.com/stig/json-framework/issues/160) & [#162](https://github.com/stig/json-framework/issues/162) - Remove category &  `...error:(NSError**)error` methods.
* [#171](https://github.com/stig/json-framework/pull/171) - Support full range of `unsigned long long` as proper integer type.
* [#128](https://github.com/stig/json-framework/issues/128) - Support full range of `double`. This also removes NSDecimalNumber support.
* [#180](https://github.com/stig/json-framework/pull/180) - Add @rpath support to SBJson.framework build settings.
* [#182](https://github.com/stig/json-framework/pull/182) - Add option to process values as they’re parsed.

The main reason for a major version change is the removal of the some methods, to allow focus on streaming as explained in [this blog post](http://superloopy.io/articles/2013/what-now-for-sbjson.html). The change to support the full range of `double` was also significant enough that it might have warranted a major version release on its own.

Several community members have contributed to this release.

3.2.0 (January 19th, 2013)
==========================

Version 3.2.0 was released, with no changes since rc1.

3.2.0-rc1 (January 4th, 2013)
=============================

**Deprecations**

* Deprecated the `JSONValue` and `JSONRepresentation` category methods.
* Deprecated several methods that return an error through an `NSError**` argument.

These will be removed in the next major version release.

**Changes**

* Absorb LICENSE and INSTALL files into README.
* Remove the Xcode Workspace from the top-level source checkout; the less
  clutter the better and this doesn't seem to serve any function.
* Change to use AppleDoc for creating API documentation. This results in
  output looking more consistent with Apple's documentation.

**Bugfixes**

* Replace use of INFINITY with HUGE_VAL where used as double (reported by
Antoine Cœur)
* Correctly parse -0.0 as a JSON number (Cary Yang)

3.1.1 (August 4th, 2012)
========================

Bugfix release. This release is special in that it mainly contains code by other people. Thanks guys!

* Fix bug that could result in a long long overflow (Ole André Vadla Ravnås)
* Make SINGLETON thread safe (Alen Zhou)
* Updated .gitattributes to say that tests are binary files (Phill Baker)
* Fix string formatter warning in new XCode (Andy Brett)
* Fix issue that could lead to "bad access" or zombie errors (jonkean)
* Update links to API docs


3.1 (March 26th, 2012)
=====================

Automatic Reference Counting
----------------------------

3.1 requires Xcode 4.2 to build, because previous versions did
not have ARC support. If you can't use Xcode 4.2, or for some reason
can't use ARC, you need to stick with version 3.0.

To make this move simpler I decided to move to 64-bit only & remove
instance variables for properties.

Miscellaneous
-------------

* Added an optional comparator that is used when sorting keys.
* Be more memory-efficient when parsing long strings containing escaped characters.
* Add a Workspace that includes the sample projects, for ease of browsing.
* Report error for numbers with exponents outside range of -128 to 127.


3.0 (June 18th, 2011)
=====================

JSON Stream Support
-------------------

We now support parsing of documents split into several NSData chunks,
like those returned by *NSURLConnection*. This means you can start
parsing a JSON document before it is fully downloaded. Depending how you
configure the delegates you can chose to have the entire document
delivered to your process when it's finished parsing, or delivered
bit-by-bit as records on a particular level finishes downloading. For
more details see *SBJsonStreamParser* and *SBJsonStreamParserAdapter* in
the [API docs][api].

There is also support for *writing to* JSON streams. This means you can
write huge JSON documents to disk, or an HTTP destination, without
having to hold the entire structure in memory. You can use this to
generate a stream of tick data for a stock trading simulation, for
example. For more information see *SBJsonStreamWriter* in the [API
docs][api].

Parse and write UTF8-encoded NSData
-----------------------------------

The internals of *SBJsonParser* and *SBJsonWriter* have been rewritten
to be NSData based. It is no longer necessary to convert data returned
by NSURLConnection into an NSString before feeding it to the parser. The
old NSString-oriented API methods still exists, but now converts their
inputs to NSData objects and delegates to the new methods.

Project renamed to SBJson
-------------------------

The project was renamed to avoid clashing with Apple's private
JSON.framework. (And to make it easier to Google for.)

* If you copy the classes into your project then all you need to update
is to change the header inclusion from `#import "JSON.h"` to `#import
"SBJson.h"`.
* If you link to the library rather than copy the classes you have to
change the library you link to. On the Mac `JSON.framework` became
`SBJson.framework`. On iOS `libjson.a` became `libsbjson-ios.a`. In both
cases you now have to `#import <SBJson/SBJson.h>` in your code.

API documentation integrated with Xcode
---------------------------------------

The *InstallDocumentation.sh* script allows you to generate [API
documentation][api] from the source and install it into Xcode, so it's
always at your fingertips. (This script requires [Doxygen][] to be
installed.) After running the script from the top-level directory, open
Xcode's documentation window and search for SBJson. (You might have to
close and re-open Xcode for the changes to take effect.)

[api]: http://stig.github.com/json-framework/api/3.0/
[Doxygen]: http://doxygen.org

Example Projects
----------------

These can be found in the Examples folder in the distribution.

* TweetStream: An exampleshowing how to use the new streaming
functionality to interact with Twitter's multi-document streams. This
also shows how to link to the iOS static lib rather than having to copy
the classes into your project.
* DisplayPretty: A small Mac example project showing how to link to an
external JSON framework rather than copying the sources into your
project. This is a fully functional (though simplistic) application that
takes JSON input from a text field and presents it nicely formatted into
another text field.
