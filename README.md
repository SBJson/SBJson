SBJson (aka json-framework)
===========================

JSON (JavaScript Object Notation) is a light-weight data interchange
format that's easy to read and write for humans and computers alike.
This library implements strict JSON parsing and generation in
Objective-C.

Features
--------

* BSD license
* Super-simple high-level API:
  * Call `[str JSONValue]` on any NSString instance to parse its JSON text
  * Call `[obj JSONRepresentation]` on any NSArray or NSDictionary to return its JSON text
* Good balance between simplicity and flexibility provided by the *SBJsonParser* and *SBJsonWriter* classes
* Configurable recursion depth limit
* Garbage Collection
* Automatic Reference Counting (ARC)
* Optionally sort dictionary keys in JSON output
* Optional pretty-printing of JSON output

Links
=====

* [GitHub project page](http://github.com/stig/json-framework)
* [Online API docs](http://stig.github.com/json-framework/api/3.1)
* [Frequently Asked Questions](http://github.com/stig/json-framework/wiki/FrequentlyAskedQuestions)

