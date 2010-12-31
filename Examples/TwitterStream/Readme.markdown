# Twitter Sample

This is an example of how to use json-framework to interact with [Twitter's streaming API](http://dev.twitter.com/pages/streaming_api).

Additionally, this shows how you can use external linking to link to a checkout of json-framework in a different directory, rather than copying the sources into your project.

1. Download [JSON.framework](http://github.com/stig/json-framework) and open it in Xcode.
1. Create a new iPhone application project in Xcode.
1. Click the blue *JSON* icon at the top of the *Groups & Files* menu in the JSON project and drag it into your new project. Drop it on the  blue icon at the top of *Groups & Files* in your application.
1. Select the blue *JSON.xcodeproj* folder that just appeared and tick the box to the right of the *libjson.a* entry in the list of targets.
1. Pick your target under the *Targets* item in the *Groups & Files* menu, right-click and click *Get Info*.
1. In the *General* tab, click the "+" sign under *Direct Dependencies*. Pick "libjson.a" from the drop-down & click OK.
1. In the *Build* tab find *Header Search Paths* and add `/tmp/JSON.dst/usr/local/include` to it.
1. Also in the *Build* tab, find *Other Linker Flags* and add `-all_load`. (This might not be necessary if you use the classes directly, rather than the category methods on NSString / NSDictionary / NSArray.)


You can move both projects, as long as they always stay in the same place *relative to each other*.

In writing up this checklist I had a lot of help from [Clint Harris's guide](http://www.clintharris.net/2009/iphone-app-shared-libraries/). I also had help from [Ullrich Schäfer](http://github.com/nxtbgthng/json-framework/commit/84952bf7ab87f448e0554115dc5f0a2250d97bbc#comments) to figure out the necessary steps.

Good luck, and happy hacking!

-- Stig Brautaset