---
title: SBJson for Objective-C
layout: default
---

JSON (JavaScript Object Notation) is a light-weight data interchange format
that's easy to read and write for humans and computers. This library implements
chunk-based JSON parsing and generation in Objective-C.

SBJson's number one feature is chunk-based operation. Feed the parser one or
more chunks of UTF8-encoded data and it will call a block you provide with each
root-level document or array. Or, optionally, for each top-level entry in each
root-level array. See more in the [Version 4 API
docs](http://sbjson.org/api/4.0/Classes/SBJson4Parser.html).

Other features:

* Configurable recursion limit. For safety SBJson defaults to a max nesting
  level of 32 for all input. This can be configured if necessary.
* The writer can optionally sort dictionary keys so output is consistent across writes.
* The writer can optionally create human-readable (indented) output.

# API Documentation

* [Version 4.0.0-alpha](api/4.0/) (Alpha)
* [Version 3.2](api/3.2/) (Stable)
* [Version 3.1](api/3.1/) (Legacy *Please upgrade if you use this!*)
* [Version 3.0](api/3.0/) (Legacy *Please upgrade if you use this!*)

# Source

The source code is available on GitHub. You can:

* [Browse the source](http://github.com/stig/json-framework).
* [Download a tagged release](https://github.com/stig/json-framework/releases).
* Fork it: <pre>
$ git clone git://github.com/stig/json-framework
</pre>

# Support

* Check [StackOverflow questions tagged with SBJson](http://stackoverflow.com/questions/tagged/sbjson) if you have questions about how to use the library. I eventually read all questions with this tag.
* Use the [issue tracker](http://github.com/stig/json-framework/issues) if you have found a bug.

Please *do not* use my personal email address for support requests.

# License

Copyright (C) 2007-2013 Stig Brautaset. All rights reserved.

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
