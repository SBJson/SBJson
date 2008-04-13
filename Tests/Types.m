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

#define eq(x, y)        STAssertEquals(x, y, nil)
#define eqo(x, y)       STAssertEqualObjects(x, y, nil)

#define testInt(x, y)   eq([[json fromJSONString:x] intValue], (int)y)
#define testBool(x, y)  eq([[json fromJSONString:x] boolValue], (BOOL)y)
#define testFloat(x, y) eq([[json fromJSONString:x] floatValue], (float)y)

- (void)test00null
{
    STAssertTrue([[json fromJSONString:@"null"] isKindOfClass:[NSNull class]], nil);
    eqo([json fromJSONString:@"null"], [NSNull null]);

    eqo([json toJSONString:nil], @"null");
    eqo([json toJSONString:[NSNull null]], @"null");
}

- (void)test01bool
{
    testBool(@"true", YES);
    testBool(@"false", NO);
}

- (void)test02numbers
{
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

- (void)test03strings
{
    /// XXX some nasty strings here.
}

- (void)test04arrays
{
    id arr = [@"fi fo fa fum" componentsSeparatedByString:@" "];
    id as = [json toJSONString:arr];
    eqo(as, @"[\"fi\",\"fo\",\"fa\",\"fum\"]");
    eqo([json fromJSONString:as], arr);
    
    arr = [arr arrayByAddingObject:[NSNumber numberWithDouble:0.01]];
    as = [json toJSONString:arr];
    eqo(as, @"[\"fi\",\"fo\",\"fa\",\"fum\", 0.01]");
    eqo([json fromJSONString:as], arr);
    
    arr = [arr arrayByAddingObject:[NSNull null]];
    as = [json toJSONString:arr];
    eqo(as, @"[\"fi\",\"fo\",\"fa\",\"fum\", 0.01, null]");
    eqo([json fromJSONString:as], arr);
}

- (void)test05dictionaries
{
    id dict = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:3], @"three",
        @"blue", @"colour",
        nil];
    id ds = [json toJSONString:dict];
    eqo(ds, @"{\"colour\":\"blue\",\"three\":3}");
    eqo([json fromJSONString:ds], dict);

    dict = [dict mutableCopy];
    [dict setObject:[NSNull null] forKey:@"null"];
    ds = [json toJSONString:dict];
    eqo(ds, @"{\"colour\":\"blue\",\"null\":null,\"three\":3}");
    eqo([json fromJSONString:ds], dict);
}

- (void)test06deeplyNested
{
    id dict = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSArray arrayWithObjects:
            [NSArray arrayWithObjects:
                [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInt:-1], @"minus", nil], nil], nil],
        @"top",
        nil];
    id ds = [json toJSONString:dict];
    eqo(ds, @"{\"top\":[[{\"minus\":-1}]]}");
    eqo([json fromJSONString:ds], dict);
}

@end
