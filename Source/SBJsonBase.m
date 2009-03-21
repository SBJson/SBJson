//
//  SBJsonBase.m
//  JSON
//
//  Created by Stig Brautaset on 18/03/2009.
//  Copyright 2009 Stig Brautaset. All rights reserved.
//

#import "SBJsonBase.h"
NSString * SBJSONErrorDomain = @"org.brautaset.JSON.ErrorDomain";


@implementation SBJsonBase

@synthesize errorTrace;

- (void)addErrorWithCode:(NSUInteger)code description:(NSString*)str {
    if (!errorTrace)
        errorTrace = [NSMutableArray new];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:str forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:SBJSONErrorDomain code:code userInfo:userInfo];

    [self willChangeValueForKey:@"errorTrace"];
    [errorTrace addObject:error];
    [self didChangeValueForKey:@"errorTrace"];
}

- (void)clearErrorTrace {
    [self willChangeValueForKey:@"errorTrace"];
    errorTrace = nil;
    [self didChangeValueForKey:@"errorTrace"];
}

@end
