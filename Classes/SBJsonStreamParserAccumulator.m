//
//  SBJsonStreamParserAccumulator.m
//  JSON
//
//  Created by Stig Brautaset on 08/05/2011.
//  Copyright 2011 Morgan Stanley. All rights reserved.
//

#import "SBJsonStreamParserAccumulator.h"

@implementation SBJsonStreamParserAccumulator

@synthesize value;

- (void)dealloc {
    [value release];
    [super dealloc];
}

#pragma mark SBJsonStreamParserAdapterDelegate

- (void)parser:(SBJsonStreamParser*)parser foundArray:(NSArray *)array {
	value = [array retain];
}

- (void)parser:(SBJsonStreamParser*)parser foundObject:(NSDictionary *)dict {
	value = [dict retain];
}

@end
