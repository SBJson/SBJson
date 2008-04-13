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

#define eq(x, y) STAssertEquals(x, y, nil)
#define eqo(x, y) STAssertEqualObjects(x, y, nil)
#define testInt(x, y)   eq([[json fromJSONString:x] intValue], (int)y)
#define testBool(x, y)  eq([[json fromJSONString:x] boolValue], (BOOL)y)
#define testFloat(x, y) eq([[json fromJSONString:x] floatValue], (float)y)

- (void)test00types
{
    STAssertTrue([[json fromJSONString:@"null"] isKindOfClass:[NSNull class]], nil);
    eqo([json fromJSONString:@"null"], [NSNull class]);

    eqo([json toJSONString:nil], @"null");
    eqo([json toJSONString:[NSNull null]], @"null");

    testBool(@"true", YES);
    testBool(@"false", NO);

    testInt(@"5", 5);
    testInt(@"-5", -5);
    testInt(@"5e1", 50);
    testInt(@"-333e+0", -333);
    testInt(@"2.5", 2);
    testFloat(@"2.5", 2.5);

    id nums = [self splitString:@"-4 4 0.0001 10000 -9999 99.99"];
    for (id n; n = [nums nextObject]; )
        eqo([json toJSONString:[json fromJSONString:n]], n);
}

@end
