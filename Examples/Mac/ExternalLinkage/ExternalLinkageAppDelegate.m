//
//  ExternalLinkageAppDelegate.m
//  ExternalLinkage
//
//  Created by Stig Brautaset on 30/01/2011.
//  Copyright 2011 Stig Brautaset. All rights reserved.
//

#import "ExternalLinkageAppDelegate.h"
#import <JSON/JSON.h>

@implementation ExternalLinkageAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	NSLog(@"Parsed some JSON: %@", [@"[1,2,3,true,false,null]" JSONValue]);

}

@end
