//
//  SBJsonStreamWriterAccumulator.m
//  JSON
//
//  Created by Stig Brautaset on 10/05/2011.
//  Copyright 2011 Morgan Stanley. All rights reserved.
//

#import "SBJsonStreamWriterAccumulator.h"


@implementation SBJsonStreamWriterAccumulator

@synthesize data;

- (id)init {
    self = [super init];
    if (self) {
        data = [[NSMutableData alloc] initWithCapacity:8096u];
    }
    return self;
}

- (void)dealloc {
    [data release];
    [super dealloc];
}

#pragma SBJsonStreamWriterDelegate

- (void)writer:(SBJsonStreamWriter *)writer appendBytes:(const void *)bytes length:(NSUInteger)length {
    [data appendBytes:bytes length:length];
}

@end
