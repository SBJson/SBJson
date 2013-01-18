---
layout: post
title: Cocoa JSON Framework v0.1
---
I'm proud to release version 0.1 of my <a href="http://code.brautaset.org/JSON/">JSON framework for Cocoa</a>! Other people have released code to work with JSON in Cocoa, but this would appear to be the first project to provide an stand-alone framework (an <a href="http://blog.brautaset.org/2007/09/22/embedding-cocoa-frameworks/">embedded</a> one at that).

From the <a href="http://code.brautaset.org/JSON/">website</a>:

<blockquote>
This framework contains a collection of categories on existing Cocoa classes that together provide full JSON support. Importing the <code>&lt;JSON/JSON.h&gt;</code> header provides the following main methods:

<pre>
-[NSArray JSONString];
-[NSDictionary JSONString];
-[NSString objectFromJSON];
</pre>

Strictly speaking JSON has to have at least one top-level container (array or object/dictionary). Nulls, numbers, booleans and strings cannot be represented in strict JSON on their own. It can be quite convenient to <strong>pretend</strong> that such JSON fragments are valid JSON and the following methods will let you do so:

<pre>
-[NSNull JSONStringFragment];
-[NSNumber JSONStringFragment];
-[NSString JSONStringFragment];
-[NSString objectFromJSONFragment];
</pre>

</blockquote>

<em>Edited for clarity after original posting.</em>

<del><strong>Updated:</strong> I've released <a href="http://skuggdev.wordpress.com/2007/10/17/cocoa-json-framework-v1/">version 0.2</a> now.</del>

<strong>I released <a href="http://skuggdev.wordpress.com/2007/10/17/cocoa-json-framework-v1/">version 1</a> a little while ago.</strong>
