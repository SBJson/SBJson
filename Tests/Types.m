//
//  Types.m
//  JSON
//
//  Created by Stig Brautaset on 11/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import "Types.h"
#import <JSON/JSON.h>

@implementation Types

- (void)setUp
{
    json = [JSON new];
//    [json setAllowNonCollections:YES];    // allow us to decode/encode non-hashes & arrays
}

- (void)tearDown
{
    [json release];
}

- (NSEnumerator *)splitString:(NSString *)str
{
    return [[str componentsSeparatedByString:@" "] objectEnumerator];
}

#define testInt(x, y)   STAssertEquals([[json fromJSONString:x] intValue], (int)y, nil)
#define testBool(x, y)  STAssertEquals([[json fromJSONString:x] boolValue], (BOOL)y, nil)
#define testFloat(x, y) STAssertEquals([[json fromJSONString:x] floatValue], (float)y, nil)

- (void)test00null
{
    STAssertTrue([[json fromJSONString:@"null"] isKindOfClass:[NSNull class]], nil);
}

- (void)test01bool
{
    testBool(@"true", YES);
    testBool(@"false", NO);
}

- (void)test02number
{
    testInt(@"5", 5);
    testInt(@"-5", -5);
    testInt(@"5e1", 50);
    testInt(@"-333e+0", -333);
    testInt(@"2.5", 2);
    testFloat(@"2.5", 2.5);
}


@end
