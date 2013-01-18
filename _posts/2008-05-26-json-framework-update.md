---
layout: post
title: JSON Framework Update
---

<img src="http://skuggdev.files.wordpress.com/2008/05/istock-000004319108xsmall.jpg" alt="iStock_000004319108XSmall.jpg" border="0" width="300" align="left" />

<em>Is this thing on?</em>

This blog's been quiet for a while, but I'm still here&mdash;I've not fallen off the Earth. I've been busy at work, but also working on version 2 of my <a href="http://code.google.com/p/json-framework/">JSON framework</a>. The move to Google Code have turned out well. The issue tracker (although it's only me who have used it yet, and I haven't really used it in anger) has been helpful and it's been nice to have a wiki to do a quick edit of content.

It's also been great to see the <a href="http://groups.google.com/group/json-framework">mailing list</a> becoming a great resource. There's a couple of guys out there that are doing (hopefully!) interesting stuff with this framework on the iPhone. This platform has some quirks, such as not supporting frameworks, that makes development there a little different.

The reason I'm bumping the major version number is that there are fairly major changes happening in the framework. The existing API looks the same on the surface, but will now simply return nil on failure rather than throw an exception. This to adhere to the Cocoa guidelines of only throwing exceptions on programmer errors. (Although most JSON is probably produced by programmers, I don't think we can extend that to argue that parse errors are covered by this.)

The other major change is that I've exposed a lower-level API that lets you return an error via a parameter. The errors returned are more accurate than the exceptions that used to be thrown. The existing high-level API is now defined in terms of this new API. Since the existing interface did not allow any errors to be returned, if an error occurs it will be logged to the console and nil is returned.

I'll be releasing the new version of the library in not too long. (I need to improve the documentation slightly.) However, if you're not afraid of a few rough edges, why not download it, give it a spin, come over to the mailing list and give us your feedback?
