SBJson (aka json-framework)
===========================

JSON (JavaScript Object Notation) is a light-weight data interchange
format that's easy to read and write for humans and computers alike.
This framework implements a strict JSON parser and generator in
Objective-C.

Features
--------

* BSD license.
* Super-simple high-level API:
  * Calling `-JSONValue` on any NSString instance parses the JSON text in that string.
  * Calling `-JSONRepresentation` on any NSArray or NSDictionary returns an NSString with the JSON representation of the object.
* Object-oriented API providing a good balance between simplicity and flexibility. Check out:
  * `SBJsonParser`
  * `SBJsonWriter`
* Streaming JSON support. You can start parsing a JSON document--*and return parsed chunks of it to your program*--before it has finished downloading from the server. Check out:
  * `SBJsonStreamParser`
  * `SBJsonStreamWriter`
* Works with/without garbage collection.
* Pretty-printing of JSON output.
* Sorted dictionary keys in JSON output.
* Configurable recursion depth limit for added security.

Simple Installation
===================

The simplest way to start using JSON in your application is to simply
copy all the source files (the contents of the `Classes` folder) into
your own Xcode project.

1. In the Finder, navigate to the `$PATH_TO_SBJSON/Classes` folder and select all the files.
1. Drop-and-drop them into your Xcode project.
1. Tick the **Copy items into destination group's folder** option.
1. Use `#import "SBJson.h"` in  your source files. (or simply include the particular classes you wish to use.)

That should be it. Now create that Twitter client!

Upgrading
---------

If you're upgrading from a previous version, make sure you're deleting the old SBJson classes first, moving all the files to Trash.

Install API documentation into Xcode
====================================

From the top-level project directory, run the `./InstallDocumentation.sh` program. This compiles the documentation and installs it so it integrates with Xcode. Now open Xcode documentation and search for SBJson. You should see a lot of the classes. (Generating the documentation requires [Doxygen](http://doxygen.org) to be installed.)


Alternative installation instructions
=====================================

Copying the SBJson classes into your project isn't the only way to use this framework. (Though it is the simplest.) I've created a couple of examples that link to this framework rather than copy the sources. Check them out at github:

* [Linking to JSON Framework on iOS](http://github.com/stig/JsonSampleIPhone)
* [Linking to JSON Framework on the Mac](http://github.com/stig/JsonSampleMac)


Links
-----

* [GitHub project page](http://github.com/stig/json-framework).
* [Example Projects](http://github.com/stig/json-framework-examples).
* [Online API docs](http://stig.github.com/json-framework/api).
* [Frequently Asked Questions](http://github.com/stig/json-framework/wiki/FrequentlyAskedQuestions)
