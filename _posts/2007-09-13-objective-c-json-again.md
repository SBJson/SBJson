---
layout: post
title: Objective-C JSON again
---

As I mentioned in my previous post I'm currently writing an Objective-C JSON framework. Now, I've run into an issue that I'm not sure how to handle: <strong>JSON only supports strings as dictionary keys, but Objective-C supports other types as well</strong>, for example numbers. The bit I'm stuck on is this:

<blockquote>
When encoding a dictionary, should I throw an error as soon as I encounter a non-string dictionary key? Or should I try to mangle it into a string?
</blockquote>

Mangling numbers into strings will probably work reasonably well. Converting back from JSON will give you an NSString instead of an NSNumber instance back, but given that you can often treat strings as numbers this will probably work reasonably well. However. <em>However.</em> In Objective-C you can use nulls, dictionaries, or arrays as dictionary keys. (It might not necessarily be a good idea, however.) You simply cannot encode such structures into JSON and get something meaningful back.

[Teddy-bear debugging](http://www.geocities.com/softwarepeoplenet/resteddybear.html) strikes again. **By taking time to formulate my predicament as a plea for help to the metaphorical teddy-bear that is the interweb things have become clearer in my mind and I have managed to reach a decision all on my own.** I shall make my JSON library throw a hissy fit if it encounters a non-string dictionary key.
