//
//  ExternalLinkageAppDelegate.h
//  ExternalLinkage
//
//  Created by Stig Brautaset on 30/01/2011.
//  Copyright 2011 Stig Brautaset. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ExternalLinkageAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
