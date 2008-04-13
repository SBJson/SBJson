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

//    eqo([nil JSONString], @"null");
    eqo([[NSNull null] JSONString], @"null");
}

- (void)test01bool
{
    testBool(@"true", YES);
    testBool(@"false", NO);

    id bools = [self splitString:@"false true false true"];
    for (id b; b = [bools nextObject]; ) {
        id bl = [json fromJSONString:b];
        STAssertTrue([bl isKindOfClass:[NSNumber class]], nil);
/* not yet...
        eqo([bl JSONString], b);
*/
    }
}

- (void)test02numbers
{
    testInt(@"5", 5);
    testInt(@"-5", -5);
    testInt(@"5e1", 50);
    testInt(@"-333e+0", -333);
    testInt(@"2.5", 2);
    testFloat(@"2.5", 2.5);
    testFloat(@"-333e+0", -333);
    testFloat(@"-333e+3", -333000);
    testFloat(@"+666e-1", 66.6);

    id nums = [self splitString:@"-4 4 0.0001 10000 -9999 99.99 98877665544332211009988776655443322110"];
    for (id n; n = [nums nextObject]; ) {
        id num = [json fromJSONString:n];
        STAssertTrue([num isKindOfClass:[NSNumber class]], nil);
        eqo([num JSONString], n);
    }
}

- (void)test03strings
{
    id dict = [NSDictionary dictionaryWithObjectsAndKeys:
        @"\"foo\"",                         @"foo",
        @"\"foo\\\"bar\"",                  @"foo\"bar",
        @"\"foo\\\\bar\"",                  @"foo\\bar",
        @"\"quote\\\" again\"",             @"quote\" again",
        @"\"quote\\\"\"",                   @"quote\"",
        @"\" spaces  \"",                   @" spaces  ",

/* These never worked...
        @"\"\\ttabs\\t\\t\"",               @"\ttabs\t\t",
        @"\"\\\\ \\\" \\\\ \\\"\"",         @"\\ \" \\ \"",
        @"\"\\\n\"",                        @"\n",
*/
        nil];
    
    NSEnumerator *enumerator = [dict keyEnumerator];
    for (NSString *key; key = [enumerator nextObject]; ) {
        NSString *val = [dict objectForKey:key];
//        NSLog(@"'%@' => '%@'", key, val);
//        eqo([json fromJSONString:val], key);
        eqo([key JSONString], val);
        
//        eqo([json fromJSONString:[s JSONString]], s);
    }
}

- (void)test04arrays
{
    id arr = [@"fi fo fa fum" componentsSeparatedByString:@" "];
    id as = [arr JSONString];
    eqo(as, @"[\"fi\",\"fo\",\"fa\",\"fum\"]");
    eqo([json fromJSONString:as], arr);
    
    arr = [arr arrayByAddingObject:[NSNumber numberWithDouble:0.01]];
    as = [arr JSONString];
    eqo(as, @"[\"fi\",\"fo\",\"fa\",\"fum\",0.01]");
    eqo([json fromJSONString:as], arr);
    
    arr = [arr arrayByAddingObject:[NSNull null]];
    as = [arr JSONString];
    eqo(as, @"[\"fi\",\"fo\",\"fa\",\"fum\",0.01,null]");
    eqo([json fromJSONString:as], arr);
}

- (void)test05dictionaries
{
    id dict = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:3], @"three",
        @"blue", @"colour",
        nil];
    id ds = [dict JSONString];
    eqo(ds, @"{\"colour\":\"blue\",\"three\":3}");
    eqo([json fromJSONString:ds], dict);

    dict = [dict mutableCopy];
    [dict setObject:[NSNull null] forKey:@"null"];
    ds = [dict JSONString];
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
    id ds = [dict JSONString];
    eqo(ds, @"{\"top\":[[{\"minus\":-1}]]}");
    eqo([json fromJSONString:ds], dict);
}

@end
