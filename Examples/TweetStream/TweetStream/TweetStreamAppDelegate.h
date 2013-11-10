//
//  TweetStreamAppDelegate.h
//  TweetStream
//
//  Created by Stig Brautaset on 24/05/2011.
//  Copyright 2011 Stig Brautaset. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TweetStreamViewController;

@interface TweetStreamAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, weak) IBOutlet UIWindow *window;

@property (nonatomic, weak) IBOutlet TweetStreamViewController *viewController;

@end
