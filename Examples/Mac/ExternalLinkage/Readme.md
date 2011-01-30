# Linking JSON.framework into your Mac app

This is an alternative to copying the JSON sources into your project.

1. Configure a common build location for projects. This is done in Xcode -> Preferences - > Building -> Customized location. I set mine to `~/Library/Caches/Xcode`.
1. Download [JSON.framework](http://github.com/stig/json-framework) and open it in Xcode.
1. Create a new Mac application project in Xcode.
1. Click the blue *JSON* icon at the top of the *Groups & Files* menu in the JSON project and drag it into your new project. Drop it on the  blue icon at the top of *Groups & Files* in your application.
1. Select the blue *JSON.xcodeproj* folder that just appeared and tick the box to the right of the *JSON.framework* entry in the list of targets.
1. Pick your target under the *Targets* item in the *Groups & Files* menu, right-click and click *Get Info*.
1. In the *General* tab, click the "+" sign under *Direct Dependencies*. Pick "JSON.framework" from the drop-down & click OK.

That's all the preparation. Now, to test that you've done everything correctly open your AppDelegate.m and add `#import <JSON/JSON.h>' at the top. Then add this line in the -applicationDidFinishLaunching: method:
 
> NSLog(@"Parsed some JSON: %@", [@"[1,2,3,true,false,null]" JSONValue]);

Now, build and run your application in the simulator. If you open the Console (Shift-Apple-R) then you should see output similar to:

> 2010-06-24 21:57:05.925 JsonSampleMac[22539:207] Parsed some JSON: (
>    1,
>    2,
>    3,
>    "&lt;null&gt;",
>    1,
>    0
>)

In writing up this checklist I had a lot of help from [Clint Harris's guide](http://www.clintharris.net/2009/iphone-app-shared-libraries/).

Good luck, and happy hacking!

-- Stig Brautaset