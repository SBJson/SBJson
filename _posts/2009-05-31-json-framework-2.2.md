---
layout: post
title: JSON Framework 2.2 released!
---
I am proud to present version 2.2 of <a href="http://code.google.com/p/json-framework/">JSON.framework</a>, the strict JSON parser/generator for Cocoa and the iPhone. You can get the latest version from <a href="http://code.google.com/p/json-framework/downloads/list">the download page</a>.

Here are the more significant changes from the 2.1 series:

<ul>
<li><strong>New, fresh API&mdash;particularly for errors</strong>

Extracted the SBJsonWriter and SBJsonParser classes from the SBJSON class. These present a fresh, simple API. If a method returns nil, you can now simply call a method to get an array of NSError objects containing the error trace.

The SBJSON class is now a facade, implementing its old interface by forwarding messages to instances of the new classes. Additionally, the facade also implements the new simplified interface of the SBJsonWriter and SBJsonParser classes.

The category methods on Foundation objects have also been re-implemented more efficiently in terms of the new objects. In case of error in these methods now print the full trace to the log, rather than just the top-level error.
</li>

<li><strong>Support for JSON representation of custom objects</strong>

If you implement the <code>-proxyForJson</code> method in a custom class (either directly or as category) this now enables JSON.framework to create a JSON representation for objects of that type. See the <a href="http://code.google.com/p/json-framework/source/browse/branches/2.2/Tests/ProxyTest.m">ProxyTest.m</a> file for more information on how this works.
</li>

<li><strong>Deprecated fragment-based methods</strong>

The fragment-based methods are an extension to the JSON spec that does not belong in a strict JSON parser/generator. They were originally implemented to ease testing, but the tests should rather be rewritten not to need them. For the time being they are still included, but will be removed in the 2.3.x line.
</li>

<li><strong>Updated the iPhone SDK</strong>

The iPhone SDK has had some updates to address problems some people were seeing. It has been updated to be based on iPhoneOS v2.2.1.
</li>

<li><strong>Fix crash on recursive structures</strong>

Implemented the <code>maxDepth</code> setting for writing JSON. This defaults to 512 and means the framework won't crash if its is fed a recursive (or extremely deeply nested) structure.
</li>

<li><strong>Documentation updates</strong>

Simplified the installation instructions, particularly for the iPhone.

In the API documentation classes now inherit documentation from their superclasses and the protocols they implement.
</li>

<li><strong>Miscellaneous</strong>

Fixed some warnings reported by the Clang static analyser.

Added a Changes file and updated the Credits.
</li>


</ul>
