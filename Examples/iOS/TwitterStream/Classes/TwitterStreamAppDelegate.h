//
//  TwitterStreamAppDelegate.h
//  TwitterStream
//
//  Created by Stig Brautaset on 05/12/2010.
//  Copyright Stig Brautaset 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TwitterStreamViewController;

@interface TwitterStreamAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TwitterStreamViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TwitterStreamViewController *viewController;

@end

