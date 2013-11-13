//
//  DisplayPrettyController.m
//  DisplayPretty
//
//  Created by Stig Brautaset on 25/05/2011.
//  Copyright 2011 Stig Brautaset. All rights reserved.
//

#import "DisplayPrettyController.h"
#import <SBJson/SBJson.h>

@implementation DisplayPrettyController {
    SBJsonWriter *writer;
    
    IBOutlet NSTextField *_source;
    IBOutlet NSTextField *_formatted;
}

- (id)init
{
    self = [super init];
    if (self) {
        writer = [[SBJsonWriter alloc] init];
        writer.humanReadable = YES;
        writer.sortKeys = YES;
    }    
    return self;
}


- (IBAction)formatText:(id)sender {
    id parser = [[SBJsonChunkParser alloc] initWithBlock:^(id o, BOOL *stop) {
        _formatted.stringValue = [writer stringWithObject:o];
    } errorHandler:^(NSError*err) {
        _formatted.stringValue = [err localizedDescription];
    }];
    
    [parser parse:[_source.stringValue dataUsingEncoding:NSUTF8StringEncoding]];    
}

@end
