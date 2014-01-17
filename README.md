JSON (JavaScript Object Notation) is a light-weight data interchange format
that's easy to read and write for humans and computers alike. This library
implements chunk-based JSON parsing and generation in Objective-C.

[![Build Status](https://travis-ci.org/stig/json-framework.png?branch=master)](https://travis-ci.org/stig/json-framework)

Features
========

SBJson's number one feature is chunk-based operation. Feed the parser one or
more chunks of UTF8-encoded data and it will call a block you provide with each
root-level document or array. Or, optionally, for each top-level entry in each
root-level array. See more in the [Version 4 API
docs](http://cocoadocs.org/docsets/SBJson/4.0.0/Classes/SBJson4Parser.html).

Other features:

* Configurable recursion limit. For safety SBJson defaults to a max nesting
  level of 32 for all input. This can be configured if necessary.
* The writer can optionally sort dictionary keys so output is consistent across writes.
* The writer can optionally create human-readable (indented) output.

API Documentation
=================

Please see the [API Documentation](http://cocoadocs.org/docsets/SBJson) for more details.

Installation
============

The preferred way to use SBJson is by using
[CocoaPods](http://cocoapods.org/?q=sbjson). In your Podfile use:

    pod 'SBJson', '~> 4.0.0'

If you depend on a third-party library that requires an earlier version of
SBJson---or want to install both version 3 and 4 in the same app to do a gradual
transition---you can instead use:

    pod 'SBJson4', '~> 4.0.0'

An alternative that I no longer recommend is to copy all the source files (the
contents of the `src/main/objc` folder) into your own Xcode project.

Support
=======

* Check [StackOverflow questions tagged with SBJson](http://stackoverflow.com/questions/tagged/sbjson) if you have questions about how to use the library. I eventually read all questions with this tag.
* Use the [issue tracker](http://github.com/stig/json-framework/issues) if you have found a bug.

License
=======

Copyright (C) 2007-2014 Stig Brautaset. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.
* Neither the name of the author nor the names of its contributors may be used
  to endorse or promote products derived from this software without specific
  prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
