# SBJson 5

Chunk-based JSON parsing and generation in Objective-C.

[![CircleCI](https://circleci.com/gh/SBJson/SBJson.svg?style=svg)](https://circleci.com/gh/SBJson/SBJson)
[![Project Status: Inactive - The project has reached a stable, usable state but is no longer being actively developed; support/maintenance will be provided as time allows.](http://www.repostatus.org/badges/0.1.0/inactive.svg)](http://www.repostatus.org/#inactive)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Overview

SBJson's number one feature is stream/chunk-based operation. Feed the parser one or
more chunks of UTF8-encoded data and it will call a block you provide with each
root-level document or array. Or, optionally, for each top-level entry in each
root-level array.

With this you can reduce the apparent latency for each
download/parse cycle of documents over a slow connection. You can start
parsing *and return chunks of the parsed document* before the full document
has downloaded. You can also parse massive documents bit by bit so you
don't have to keep them all in memory.

SBJson maps JSON types to Objective-C types in the following way:

| JSON Type | Objective-C Type                |
|-----------|---------------------------------|
| null      | NSNull                          |
| string    | NSString                        |
| array     | NSMutableArray                  |
| object    | NSMutableDictionary             |
| true      | -[NSNumber numberWithBool: YES] |
| false     | -[NSNumber numberWithBool: NO]  |
| number    | NSNumber                        |

- Booleans roundtrip properly even though Objective-C doesn't have a
  dedicated class for boolean values.
- Integers use either `long long` or `unsigned long long` if they fit,
  to avoid rounding errors.  For all other numbers we use the `double`
  type, with all the potential rounding errors that entails.

## "Plain" Chunk Based Parsing

First define a simple block & an error handler. (These are just minimal
examples. You should strive to do something better that makes sense in your
application!)

```objc
SBJson5ValueBlock block = ^(id v, BOOL *stop) {
    BOOL isArray = [v isKindOfClass:[NSArray class]];
    NSLog(@"Found: %@", isArray ? @"Array" : @"Object");
};

SBJson5ErrorBlock eh = ^(NSError* err) {
    NSLog(@"OOPS: %@", err);
    exit(1);
};
```

Then create a parser and add data to it:

```objc
id parser = [SBJson5Parser parserWithBlock:block
                              errorHandler:eh];

id data = [@"[true," dataWithEncoding:NSUTF8StringEncoding];
[parser parse:data]; // returns SBJson5ParserWaitingForData

// block is not called yet...

// ok, now we add another value and close the array

data = [@"false]" dataWithEncoding:NSUTF8StringEncoding];
[parser parse:data]; // returns SBJson5ParserComplete

// the above -parse: method calls your block before returning.
```

Alright! Now let's look at something slightly more interesting.

## Handling multiple documents

This is useful for something like Twitter's feed, which gives you one JSON
document per line. Here is an example of parsing many consequtive JSON
documents, where your block will be called once for each document:

```objc
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

## Unwrapping a gigantic top-level array

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

## Other features

* For safety there is a max nesting level for all input. This defaults to 32,
  but is configurable.
* The writer can sort dictionary keys so output is consistent across writes.
* The writer can create human-readable output, with newlines and indents.
* You can install SBJson v3, v4 and v5 side-by-side in the same application.
  (This is possible because all classes & public symbols contains the major
  version number.)

## A word of warning

Stream based parsing does mean that you lose some of the correctness
verification you would have with a parser that considered the entire input
before returning an answer. It is technically possible to have some parts of a
document returned *as if they were correct* but then encounter an error in a
later part of the document. You should keep this in mind when considering
whether it would suit your application.

# Fuzzing

I've run [AFL++][] on the sbjson binary for over 24 hours, with no crashes
found. (I cannot reproduce the hangs reported when attempting to parse them
manually.)

[AFL++]: https://aflplus.plus

To reproduce, make sure you have Nix installed, then:

```bash
git checkout fuzz
nix-shell --command ./fuzz.sh
```

The `shell.nix` builds AFL++ 4.34c from source, configured to use
POSIX shared memory (`shm_open` + `mmap`) so it runs on macOS without
the System V IPC issues the packaged version has. The `fuzz.sh` script
builds an instrumented sbjson binary and starts afl-fuzz seeded with
the jsonchecker test data.

Here's the output after about 24 hours of fuzzing:

```
american fuzzy lop ++4.34c {default} (/tmp/sbjson-afl/sbjson) [explore]
┌─ process timing ────────────────────────────────────┬─ overall results ────┐
│        run time : 1 days, 0 hrs, 26 min, 51 sec     │  cycles done : 57    │
│   last new find : 0 days, 0 hrs, 30 min, 9 sec      │ corpus count : 1089  │
│last saved crash : none seen yet                     │saved crashes : 0     │
│ last saved hang : none seen yet                     │  saved hangs : 0     │
├─ cycle progress ─────────────────────┬─ map coverage┴──────────────────────┤
│  now processing : 1055.224 (96.9%)   │    map density : 8.85% / 76.96%     │
│  runs timed out : 0 (0.00%)          │ count coverage : 4.76 bits/tuple    │
├─ stage progress ─────────────────────┼─ findings in depth ─────────────────┤
│  now trying : havoc                  │ favored items : 113 (10.38%)        │
│ stage execs : 102/300 (34.00%)       │  new edges on : 31 (2.85%)          │
│ total execs : 14.1M                  │ total crashes : 0 (0 saved)         │
│  exec speed : 236.0/sec              │  total tmouts : 3449 (0 saved)      │
├─ fuzzing strategy yields ────────────┴─────────────┬─ item geometry ───────┤
│   bit flips : 2/10.5k, 2/10.5k, 0/10.5k            │    levels : 38        │
│  byte flips : 0/1315, 0/1314, 0/1312               │   pending : 0         │
│ arithmetics : 4/92.0k, 0/183k, 0/183k              │  pend fav : 0         │
│  known ints : 0/11.8k, 0/49.9k, 0/73.5k            │ own finds : 1052      │
│  dictionary : 0/0, 0/0, 0/0, 0/0                   │  imported : 0         │
│havoc/splice : 237/12.4M, 0/0                       │ stability : 100.00%   │
│py/custom/rq : unused, unused, unused, unused       ├───────────────────────┤
│    trim/eff : 4.22%/397k, 99.92%                   │             [cpu: 23%]│
└─ strategy: exploit ────────── state: in progress ──┘
```

# API Documentation

Please see the [API Documentation](http://cocoadocs.org/docsets/SBJson) for
more details.


# Installation

## CocoaPods

The preferred way to use SBJson is by using
[CocoaPods](http://cocoapods.org/?q=sbjson). In your Podfile use:

    pod 'SBJson', '~> 5.0.4'

## Carthage

SBJson is compatible with _Carthage_. Follow the [Getting Started Guide for iOS](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos).

	github "SBJson/SBJson" == 5.0.4

## Bundle the source files

An alternative that I no longer recommend is to copy all the source files (the
contents of the `Classes` folder) into your own Xcode project.

# Examples

* https://github.com/SBJson/ChunkedDelivery - a toy example showing how one can
  use `NSURLSessionDataDelegate` to do chunked delivery.
* https://github.com/SBJson/DisplayPretty - a very brief example using SBJson 4
  to reflow JSON on OS X.

# Support

* Review (or create) StackOverflow questions [tagged with
  `SBJson`](http://stackoverflow.com/questions/tagged/sbjson) if you
  have questions about how to use the library.
* Use the [issue tracker](http://github.com/SBJson/SBJson/issues) if you
  have found a bug.
* I regret I'm only able to support the current major release.

## Philosophy on backwards compatibility

SBJson practice [Semantic Versioning](https://semver.org/), which
means we do not break the API in major releases. If something requires
a backwards-incompatible change, we release a new major version.
(Hence why a library of less than 1k lines has more major versions
than Emacs.)

I also try support a gradual migration from one major version to the
other by allowing the last three major versions to co-exist in the
same app without conflicts. The way to do this is putting the major
version number in all the library's symbols and file names. So if v6
ever comes out, the `SBJson5Parser` class would become
`SBJson6Parser`, etc.

# License

BSD. See [LICENSE](LICENSE) for details.
