JSON (JavaScript Object Notation) is a light-weight data interchange
format that's easy to read and write for humans and computers alike.
This library implements strict JSON parsing and generation in
Objective-C.

Features
========

* Streaming Support (see SBJsonStreamParser & SBJsonStreamWriter)
* Configurable recursion depth limit
* Automatic Reference Counting (ARC)
* Optionally sort dictionary keys in JSON output
* Optional pretty-printing of JSON output

Links
=====

* [GitHub project page](http://github.com/stig/json-framework)
* [Online API docs](http://sbjson.org/api/3.2)
* [SBJson tag on Stack Overflow](http://stackoverflow.com/questions/tagged/sbjson)


Installation
============

The simplest way to start using JSON in your application is to copy all
the source files (the contents of the `Classes` folder) into your own
Xcode project.

1. In the Finder, navigate into the `Classes` folder.
2. Select all the files and drag-and-drop them into your Xcode project.
3. Tick the **Copy items into destination group's folder** option.
4. Use `#import "SBJson.h"` in  your source files.

That should be it. Now create that Twitter client!

*If you're upgrading from a previous version, make sure you're deleting the
old SBJson classes first, moving all the files to Trash.*


Alternative Installation Instructions
=====================================

* With Xcode 4's workspaces it has become much simpler to link to dependant
projects. The examples in the distribution link to the iOS library and Mac
framework, respectively. Des Hartman wrote [a blog post with step-by-step
instructions for iOS][link-ios]. This is the recommended way if you need to
make local changes to SBJson.
* You can also install SBJson using [CocoaPods](http://cocoapods.org).

[link-ios]: http://deshartman.wordpress.com/2011/09/02/configuring-sbjson-framework-for-xcode-4-2/


License
=======

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
