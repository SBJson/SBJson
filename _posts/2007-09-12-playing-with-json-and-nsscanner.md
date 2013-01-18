---
layout: post
title: Playing with JSON and NSScanner
---

I've been playing around trying to parse and generate <a href="http://json.org">JSON</a> from Objective-C the last few days. The core of the  parser takes the form of a <a href="http://svn.brautaset.org/JSON/trunk/Source/NSScanner+SBJSON.m">category on NSScanner</a>, and I'm <em>really</em> chuffed with how neat and clear the code turned out. A tip of the hat to the designers of Objective-C and NSScanner!

A <em>category</em>&mdash;though originally conceived as a way to split large classes into multiple files (at least this is my understanding)&mdash;can be used to <em>extend classes at run-time</em>. This is a feature that is most commonly associated with interpreted languages. Used soberly it can be used to great effect to add functionality to a class without having to subclass it. You can add methods, and even override existing ones, but not add any instance variables.

The <a href="http://svn.brautaset.org/JSON/trunk/">JSON Framework</a> I'm working on provides no public classes on its own. Instead it adds a method to NSString that returns an object structure representing the JSON string. To <em>emit</em> JSON for a complex structure I've added a method to NSObject that will do the right thing for nulls, booleans, numbers, arrays, dictionaries and strings.

Please be aware that the code at point is the result of just one night and 2 days of coding. <strong>There are no docs. There are no options. There are no limits, so if you feed it carefully crafted JSON you can make my parser run out of C stack space. </strong> There <em>is</em> working proof-of-concept code, copyright statements, and tests.

Update 24/9/07: I've <a href="http://blog.brautaset.org/2007/09/23/cocoa-json-framework-v01/">released</a> version 0.1 of my JSON framework now.
