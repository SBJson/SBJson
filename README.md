SBJson 5
========

JSON (JavaScript Object Notation) is a light-weight data interchange format
that's easy to read and write for humans and computers alike. This library
implements chunk-based JSON parsing and generation in Objective-C.

[![Build Status](https://travis-ci.org/stig/json-framework.png?branch=master)](https://travis-ci.org/stig/json-framework)

[![codecov.io](http://codecov.io/github/stig/json-framework/coverage.svg?branch=master)](http://codecov.io/github/stig/json-framework?branch=master)

[![Project Status: Inactive - The project has reached a stable, usable state but is no longer being actively developed; support/maintenance will be provided as time allows.](http://www.repostatus.org/badges/0.1.0/inactive.svg)](http://www.repostatus.org/#inactive)

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Overview
========

SBJson's number one feature is chunk-based operation. Feed the parser one or
more chunks of UTF8-encoded data and it will call a block you provide with each
root-level document or array. Or, optionally, for each top-level entry in each
root-level array. 

With chunk-based parsing you can reduce the apparent latency for each
download/parse cycle of documents over a slow connection. You can start
parsing *and return chunks of the parsed document* before the entire document
is even downloaded. You can also parse massive documents bit by bit so you
don't have to keep them all in memory.

JSON is mapped to Objective-C types in the following way:

| JSON Type | Objective-C Type                |
|-----------|---------------------------------|
| null      | NSNull                          |
| string    | NSString                        |
| array     | NSMutableArray                  |
| object    | NSMutableDictionary             |
| true      | -[NSNumber numberWithBool: YES] |
| false     | -[NSNumber numberWithBool: NO]  |
| number    | NSNumber                        |

Since Objective-C doesn't have a dedicated class for boolean values, these
turns into NSNumber instances. However, because they are initialised with the
-initWithBool: method they round-trip back to JSON true and false properly.
Integers are parsed into either a `long long` or `unsigned long long` type if
they fit, else a `double` is used.

Support for multiple documents
------------------------------

The default behaviour is that your passed-in block is only called once a
complete token has been parsed. If you set supportManyDocuments to YES and
your input contains multiple (whitespace limited) JSON documents your block
will be called for each document:

```objc
SBJson5ValueBlock block = ^(id v, BOOL *stop) {
    BOOL isArray = [v isKindOfClass:[NSArray class]];
    NSLog(@"Found: %@", isArray ? @"Array" : @"Object");
};

SBJson5ErrorBlock eh = ^(NSError* err) {
    NSLog(@"OOPS: %@", err);
};

id parser = [SBJson5Parser multiRootParserWithBlock:block
                                       errorHandler:eh];

// Note that this input contains multiple top-level JSON documents
id data = [@"[]{}" dataWithEncoding:NSUTF8StringEncoding];
[parser parse:data];
[parser parse:data];
```

The above example will print:

```
Found: Array
Found: Object
Found: Array
Found: Object
```

Unwrapping a top-level array
----------------------------

Often you won't have control over the input you're parsing, so can't use a
multiRootParser. But, all is not lost: if you are parsing a long array you can
get the same effect by using an unwrapRootArrayParser:

```objc
id parser = [SBJson5Parser unwrapRootArrayParserWithBlock:block
                                                 errorHandler:eh];

// Note that this input contains A SINGLE top-level document
id data = [@"[[],{},[],{}]" dataWithEncoding:NSUTF8StringEncoding];
[parser parse:data];
```

Other features
--------------

* For safety there is a max nesting level of 32 for all input. This is
  configurable.
* The writer can sort dictionary keys so output is consistent across writes.
* The writer can create human-readable output, with newlines and indents.
* You can install SBJson v3, v4 and v5 side-by-side in the same application.
  (This is possible because all classes & public symbols contains the major
  version number.)

A gentle warning
----------------

Stream based parsing does mean that you lose some of the correctness
verification you would have with a parser that considered the entire input
before returning an answer. It is technically possible to have some parts of a
document returned *as if they were correct* but then encounter an error in a
later part of the document. You should keep this in mind when considering
whether it would suit your application.

API Documentation
=================

Please see the [API Documentation](http://cocoadocs.org/docsets/SBJson) for
more details.


Installation
============

CocoaPods
---------

The preferred way to use SBJson is by using
[CocoaPods](http://cocoapods.org/?q=sbjson). In your Podfile use:

    pod 'SBJson5', '~> 5.0.0'

Carthage
--------

SBJson is compatible with _Carthage_. Follow the [Getting Started Guide for iOS](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos).

	github "stig/json-framework" == 5.0.0

Bundle the source files
-----------------------

An alternative that I no longer recommend is to copy all the source files (the
contents of the `Classes` folder) into your own Xcode project.

Examples
========

* https://github.com/stig/ChunkedDelivery - a toy example showing how one can
  use `NSURLSessionDataDelegate` to do chunked delivery.
* https://github.com/stig/DisplayPretty - a very brief example using SBJson 4
  to reflow JSON on OS X.

Support
=======

* Check StackOverflow questions
  [tagged with SBJson](http://stackoverflow.com/questions/tagged/sbjson) if
  you have questions about how to use the library. I try to read all questions
  with this tag.
* Use the [issue tracker](http://github.com/stig/json-framework/issues) if you
  have found a bug.

License
=======

BSD. See [LICENSE](LICENSE) for details.
