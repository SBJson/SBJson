# 4.0.5 (November 15, 2016)

Fixes an embarrassing bug in the unwrapRootArrayParser that made the parser
ignore any output after an array entry at depth 1. (I.e. a direct child of the
root array.)

*This fix exists in the v4.0.5 tag, and the v4.0.x branch, but not on master as
that has moved on too much.*

# 4.0.4: No Crashes On Invalid UTF-8 Found 

(November 3rd, 2016)

Oh, er, well, this is a bit embarrassing. It turns out my tests were
insufficently devious, and did not guard against invalid UTF-8 encodings. I
thought I could punt on UTF-8 validation and rely on `[NSString
initWithBytes:length:encoding]` to do it, but then Nicolas Seriot reported
otherwise ([issue #219][issue-219]). The upshoot of this is that this version
won't crash on a whole range invalid UTF-8 byte sequences where previous
versions crashed did:

* Flat-out illegal UTF-8 byte values
* Missing continuation bytes
* Unexpected continuation bytes
* Overlong encodings
* Invalid Unicode code points

After 9 years of calling SBJson a strict JSON parser I've finally implemented
UTF-8 validation. Thank you for the learning opportunity Nicolas!

[issue-219]: https://github.com/SBJson/SBJson/issues/219

Also in this release:

* Recreate the project file and targets using Xcode 8.
* Re-organising the frankly bonkers repo layout to hopefully make it easier
  for casual contributors to find their way around.
* Fix the Travis build; this had broken due to bit rot.

4.0.3 (July 7th, 2016)
======================

* [`207dfa3`](https://github.com/SBJson/SBJson/commit/207dfa39913644629407028b27386905e39c1698) Adjust Travis CI configuration (#1)
* [`191b0ad`](https://github.com/SBJson/SBJson/commit/191b0ad920e2f3e72d806b6dcbd32664c26ea5d3) Rename Carthage Mac target
* [`23e47df`](https://github.com/SBJson/SBJson/commit/23e47df2f4f9b95758e910bd2b83abe91551071b) Update README.md
* [`ed536b5`](https://github.com/SBJson/SBJson/commit/ed536b56b72c6af27ae339f4bbcc721f47764b33) Add Carthage iOS target
* [`d53dfe4`](https://github.com/SBJson/SBJson/commit/d53dfe4242febb8f8e3d18b6401ef283587bcb90) Add repo status to README
* [`4ca1d84`](https://github.com/SBJson/SBJson/commit/4ca1d8488576fed943d842c91a69bb4520f2070a) Replace deprecated method with alternative
* [`d088bd1`](https://github.com/SBJson/SBJson/commit/d088bd155f26bd875bfd2236ccc6f08f8960e439) Add codecov badge to README
* [`4e7df93`](https://github.com/SBJson/SBJson/commit/4e7df93c0226fb0afb2702669103f94c3a6cc438) Make variable private
* [`2983d71`](https://github.com/SBJson/SBJson/commit/2983d71f82282af64a9e08c3356c200d388d6f76) Attempt at adding code test coverage metrics
* [`959f5bd`](https://github.com/SBJson/SBJson/commit/959f5bd8e08739571913fa25ef0a3b3617e109c8) Make link (hopefully) to LICENCE
* [`52ab522`](https://github.com/SBJson/SBJson/commit/52ab522ab8f6c5365e67f2c9066534eae8e3777d) Add a top-level heading to README
* [`abe079d`](https://github.com/SBJson/SBJson/commit/abe079d50e3045ee4c2729a2ee9461f6d901a2ab) Update to-date on license
* [`bff9599`](https://github.com/SBJson/SBJson/commit/bff9599770e825d8923bd0e732cd8df68aafc4a3) Remove prefix headers
* [`2fbe784`](https://github.com/SBJson/SBJson/commit/2fbe7843fe6f921bcf1b91c6db5873b6e909e814) Use Xcodebuild rather than xctool
* [`5f63aa0`](https://github.com/SBJson/SBJson/commit/5f63aa035acd3efa6a8e6f2f5251a5816b39516e) Add Gitter URL to README

4.0.2 (June 24th, 2015)
=======================

A few patches to address warnings submitted by various people.

* [`a34295f`](https://github.com/SBJson/SBJson/commit/a34295f7ff0f26b6fa4c337edeab3581915bd41b) Merge pull request #201 from isimpson/patch-1
* [`6069c12`](https://github.com/SBJson/SBJson/commit/6069c1266fc37823540577b565f0dc47b51782f4) Fix semantic issue Xcode warning
* [`ceaa84a`](https://github.com/SBJson/SBJson/commit/ceaa84a3d4b23fbb8ca3451dbb494601e8df3e26) Update travis-ci to use a build matrix rather than explicit script
* [`647ff7e`](https://github.com/SBJson/SBJson/commit/647ff7e355c3cab39ad6555a50a5299085e6006d) Add semicolons after block - fixes #198
* [`34b2d47`](https://github.com/SBJson/SBJson/commit/34b2d47d138195ca5c560dcafecb33cafb9b4100) Update README.md
* [`f4933c9`](https://github.com/SBJson/SBJson/commit/f4933c9190d0f7a5bbc4850a15ac3c802cc14df0) Merge pull request #194 from karelia/master
* [`beed41a`](https://github.com/SBJson/SBJson/commit/beed41a78921a6ece7fcfa4f642224d8c6269917) Return NULL for invalid chars
* [`64ea007`](https://github.com/SBJson/SBJson/commit/64ea007c331318f726d9a32cc807e7838e2e0cf6) Readme update
* [`e628af0`](https://github.com/SBJson/SBJson/commit/e628af028549bd11bc3b538392c8fb45e181912b) Slightly saner error handling (thanks AppCode!)
* [`852f607`](https://github.com/SBJson/SBJson/commit/852f60714804224cee7d6e5e70f5c4c3d0ef9330) Inline method (thanks AppCode!)
* [`20a2ece`](https://github.com/SBJson/SBJson/commit/20a2ecea8deede68d2bebcdfcc49e6b8d9047f14) Add cast to correct unmatched type issue (thanks AppCode!)
* [`18cbb6c`](https://github.com/SBJson/SBJson/commit/18cbb6cb5b690130a79ffc4c9ba36cd3b38ac2cb) Fix typos in comments and variable names (thanks AppCode!)
* [`a90dddf`](https://github.com/SBJson/SBJson/commit/a90dddf634c45840e97f924b578fb43fcfcf3659) Killed 58 lines of unreachable code (thanks AppCode!)
* [`024672c`](https://github.com/SBJson/SBJson/commit/024672c52c9dcac656f3762fa87a27fc8ac57c3e) Simplify expression as suggested by AppCode
* [`f999088`](https://github.com/SBJson/SBJson/commit/f99908817d0a4b4828606cc0cf43f6a24b6547bc) Remove broken example (twitter no longer support basic auth)
* [`dba2719`](https://github.com/SBJson/SBJson/commit/dba2719a1a60f1aabf93811baff426a9bce552ba) Create a new (external) DisplayPretty project and link to it rather than embed it
* [`f7ee521`](https://github.com/SBJson/SBJson/commit/f7ee521bb2db5d77ff41e2db44113c04acde9130) fixup! Extract LICENSE from README again (I changed my mind...)
* [`59d3810`](https://github.com/SBJson/SBJson/commit/59d38108e0856d364956274adb8c81a62563464d) Extract LICENSE from README again (I changed my mind...)

4.0.1 (April 17th, 2014)
========================

Change installation instructions to recommend use of CocoaPods.

Started using http://travis-ci.org to ensure builds are good. This now runs tests for both iOS and OSX build of the library.

Fix method names in API documentation examples.

Modernise and tidy up a bit by:
- Convert tests to use XCTest rather than OCUnit.
- Remove unnecessary schemes.
- Turn on analyze for tests too.
- Enable modules & drop explicit dependency on Foundation.
- Make precompiled headers use Foundation/Foundation.h rather than UIKit / Cocoa headers.
- Upgrade to latest Xcode5.1 recommended settings.
- Remove annoying (but harmless) warning about ARC retain cycle in tests.

Full list of commits:

* [`6e28701`](https://github.com/SBJson/SBJson/commit/6e287015c1f8a5d1dbb052ef9d7abef0339b3cf5) Run tests for both iOS and OSX
* [`b93a64b`](https://github.com/SBJson/SBJson/commit/b93a64bc723453534bb3ba891476739791dacf61) Turn on analyze for tests too
* [`816cca4`](https://github.com/SBJson/SBJson/commit/816cca44834e8ab6cf275a8779ac6330502c6cdd) Convert OCUnit to XCTest
* [`0546997`](https://github.com/SBJson/SBJson/commit/0546997fe2d03f8c3a8c51cca879c66a7338e7f7) Remove unnecessary schemes
* [`eca32c2`](https://github.com/SBJson/SBJson/commit/eca32c2b89fda7b6e7d8920952842ff81836638a) Enable Modules
* [`91be3a7`](https://github.com/SBJson/SBJson/commit/91be3a760bb19aedc40408817909137121a4ba8b) Upgrade to latest Xcode settings
* [`f17611c`](https://github.com/SBJson/SBJson/commit/f17611c31eb8ea14d7d1df215814bec87d2abed0) README updates
* [`1b60dd1`](https://github.com/SBJson/SBJson/commit/1b60dd11c1215b608f9731ede6669edba40844e0) Make Podfile documentation a bit clearer
* [`79c814b`](https://github.com/SBJson/SBJson/commit/79c814b733e18cc53064a1ef10252c8ab9086b31) Update copyright year
* [`e1c770c`](https://github.com/SBJson/SBJson/commit/e1c770c3e1ae9c944b67fb2a3a1fe906c84dbf88) Update README
* [`0a60393`](https://github.com/SBJson/SBJson/commit/0a60393fab7f83d1a8be1eed777881e848431dca) Remove annoying (but harmless) warning about ARC retain cycle in tests
* [`d23adbc`](https://github.com/SBJson/SBJson/commit/d23adbcd84811688d07911ec75fe70f07168322a) Update README.md
* [`259fa96`](https://github.com/SBJson/SBJson/commit/259fa964c5c87a2ed923c7945576cec1dc237a0f) Build-status information from Travis
* [`8651019`](https://github.com/SBJson/SBJson/commit/8651019efac64adeaeabcb9b96e46906d382edff) Add shared Xcode schemes for Travis
* [`f0f1d61`](https://github.com/SBJson/SBJson/commit/f0f1d61f95ad61427c9e2768aa7c02ea8a4f1ddb) Add .travis.yml to integrate with travis-ci.org
* [`fb05d7d`](https://github.com/SBJson/SBJson/commit/fb05d7dc4dc8eb74e19b1d0bde9298b4857a2b50) Clarify example in documentation
* [`928a69d`](https://github.com/SBJson/SBJson/commit/928a69d6c2222b1f8f976242720cba2551d3b5f4) Fix documentation

4.0.0 (December 16th, 2013)
===========================

No changes since RC1.

4.0.0-rc1 (December 4th, 2013)
==============================

Notable changes since alpha3:

* [`b7bf069`](https://github.com/SBJson/SBJson/commit/b7bf069e9ddc8eec4feab51fc6c6e5ead367a5ae) Add newline at end of file. Fixes #188.

4.0.0-alpha3 (November 17th, 2013)
==================================

Notable changes since 4.0.0-alpha2:

* [`f7ef205`](https://github.com/SBJson/SBJson/commit/f7ef2055e7dbd0e6399f6d0e1f56b8c1666d1ba8) Add documentation for more convenience constructors
* [`49bcff0`](https://github.com/SBJson/SBJson/commit/49bcff013f06f32662f295b5101c3623cd1bfaa9) Rename classes, constants & enums to add major version number (4)
* [`fda671c`](https://github.com/SBJson/SBJson/commit/fda671c9b20e9e2e316585f0d592b9a787f9deaf) Remove old SBJsonParser and rename SBJsonChunkParser to SBJsonParser
* [`c053beb`](https://github.com/SBJson/SBJson/commit/c053beb35378819b04e982a217149857d0ef9f52) Changed secondary init method to be a class method instead
* [`faaa654`](https://github.com/SBJson/SBJson/commit/faaa65484b0db1e9d6f5e43132ec19637b50dbae) Remove parser as argument to all its delegate methods
* [`e8a1444`](https://github.com/SBJson/SBJson/commit/e8a14447fb5892e2a67983c25a3da0ec91c0c1a4) Move max-depth error handling from stream parser to chunk-parser
* [`4ef698e`](https://github.com/SBJson/SBJson/commit/4ef698ec25be25f45de03769c1b0d36327bcf30a) Make SBJsonChunkParser "immutable" by removing properties
* [`d6342f6`](https://github.com/SBJson/SBJson/commit/d6342f687df42245a298d08bc2a459ce707ba57a) Use the ChunkParser in the DisplayPretty example

4.0.0-alpha2 (November 13th, 2013)
==================================

Notable changes since 4.0.0-alpha:

* [`d13a5a8`](https://github.com/SBJson/SBJson/commit/d13a5a8f2e60545b06dc038051cab0bd89d43b35) Support stopping parsing after a certain number of partial documents
* [`cbdd83c`](https://github.com/SBJson/SBJson/commit/cbdd83cc0de6a4e99ff84079d83b9c14c448db70) Replace SBJsonStreamParserAdapter with SBJsonChunkParser
* [`a52fefa`](https://github.com/SBJson/SBJson/commit/a52fefa1aaf190f8088e257164e8db7deaa3eb73) Update DisplayPretty example to use ARC
* [`9bedeec`](https://github.com/SBJson/SBJson/commit/9bedeecb1bf504e3384af6660316461095b9a272) Turn on most sensible warnings
* [`641f506`](https://github.com/SBJson/SBJson/commit/641f5064c92973111980586147827aaaca721302) Move properties to be nonatomic, and remove explicit @synthesize declarations
* [`b41acb1`](https://github.com/SBJson/SBJson/commit/b41acb10e3f7371a5b2e1c2d2e31d919910122d6) Use weak rather than unsafe_unretained (no longer support iOS < 5)
* [`c3f7db0`](https://github.com/SBJson/SBJson/commit/c3f7db04d438e17d41277c6da90de2e8b0777a3c) Make the "skip outer array" option of the stream parser easier to understand.
* [`f342770`](https://github.com/SBJson/SBJson/commit/f342770a02f2585cd34c1b6943ca45b6ed622710) Move multi-document support chosing to the parser delegate, so decision can be done in the adapter
* [`28a7c73`](https://github.com/SBJson/SBJson/commit/28a7c736042d5efa03d6948028c68c56392e4945) Update documentation to remove reference to -autorelease method
* [`ab11d2b`](https://github.com/SBJson/SBJson/commit/ab11d2b657798251ba4e0b3605ce0747152eed16) Remove the silly parser/writer Accumulators
* [`b02a095`](https://github.com/SBJson/SBJson/commit/b02a095175b38002e128b611c24ffa8e8720ecdb) Avoid warning for Mac OS X build


4.0.0-alpha (November 9th, 2013)
================================

I'm delighted to announce SBJson 4.0.0-ALPHA. Notable changes since 3.2.0:

* [#160](https://github.com/SBJson/SBJson/issues/160) & [#162](https://github.com/SBJson/SBJson/issues/162) - Remove category &  `...error:(NSError**)error` methods.
* [#171](https://github.com/SBJson/SBJson/pull/171) - Support full range of `unsigned long long` as proper integer type.
* [#128](https://github.com/SBJson/SBJson/issues/128) - Support full range of `double`. This also removes NSDecimalNumber support.
* [#180](https://github.com/SBJson/SBJson/pull/180) - Add @rpath support to SBJson.framework build settings.
* [#182](https://github.com/SBJson/SBJson/pull/182) - Add option to process values as they’re parsed.

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
