//
//  Types.m
//  JSON
//
//  Created by Stig Brautaset on 11/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import "Tests.h"

#define eq(x, y)        STAssertEquals(x, y, nil)
#define eqo(x, y)       STAssertEqualObjects(x, y, nil)

#define testInt(x, y)   eq([[x objectFromJSON] intValue], (int)y)
#define testBool(x, y)  eq([[x objectFromJSON] boolValue], (BOOL)y)
#define testFloat(x, y) eq([[x objectFromJSON] floatValue], (float)y)

@implementation Types

- (NSEnumerator *)splitString:(NSString *)str
{
    return [[str componentsSeparatedByString:@" "] objectEnumerator];
}

- (void)test00null
{
    STAssertTrue([[@"null" objectFromJSON] isKindOfClass:[NSNull class]], nil);
    eqo([@"null" objectFromJSON], [NSNull null]);

//    eqo([nil JSONString], @"null");
    eqo([[NSNull null] JSONString], @"null");
}

- (void)test01bool
{
    testBool(@"true", YES);
    testBool(@"false", NO);

    id bools = [self splitString:@"false true false true"];
    for (id b; b = [bools nextObject]; ) {
        id bl = [b objectFromJSON];
        STAssertTrue([bl isKindOfClass:[NSNumber class]], nil);
        eqo([bl JSONString], b);
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
        id num = [n objectFromJSON];
        STAssertTrue([num isKindOfClass:[NSNumber class]], nil);
        eqo([num JSONString], n);
    }
}

- (void)test03strings
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
        @"",                        @"\"\"",
        @" spaces  ",               @"\" spaces  \"",
        @"\\ \" \\ \"",             @"\"\\\\ \\\" \\\\ \\\"\"",
        @"\b",                      @"\"\\b\"",
        @"\f",                      @"\"\\f\"",
        @"\n",                      @"\"\\n\"",
        @"\r",                      @"\"\\r\"",
        @"\r\n",                    @"\"\\r\\n\"",
        @"\t",                      @"\"\\t\"",
        @"\ttabs\t\t",              @"\"\\ttabs\\t\\t\"",
        @"foo",                     @"\"foo\"",
        @"foo\"",                   @"\"foo\\\"\"",
        @"foo\"\"bar",              @"\"foo\\\"\\\"bar\"",
        @"foo\"bar",                @"\"foo\\\"bar\"",
        @"foo\\",                   @"\"foo\\\\\"",
        @"foo\\\\bar",              @"\"foo\\\\\\\\bar\"",
        @"foo\\bar",                @"\"foo\\\\bar\"",
        @"foobar",                  @"\"foobar\"",
        @"with internal   spaces",  @"\"with internal   spaces\"",
        nil];

    NSEnumerator *enumerator = [dict keyEnumerator];
    for (NSString *key; key = [enumerator nextObject]; ) {
        NSString *val = [dict objectForKey:key];
        // NSLog(@"'%@' => '%@'", key, val);

        // Simple round trip
        eqo([key objectFromJSON], val);
        eqo([val JSONString], key);

        // Now do a double round-trip
        eqo([[val JSONString] objectFromJSON], val);
        eqo([[key objectFromJSON] JSONString], key);
    }
}

- (void)test04arrays
{
    id arr = [@"fi fo fa fum" componentsSeparatedByString:@" "];
    id as = [arr JSONString];
    eqo(as, @"[\"fi\",\"fo\",\"fa\",\"fum\"]");
    eqo([as objectFromJSON], arr);
    
    arr = [arr arrayByAddingObject:[NSNumber numberWithDouble:0.01]];
    as = [arr JSONString];
    eqo(as, @"[\"fi\",\"fo\",\"fa\",\"fum\",0.01]");
    eqo([as objectFromJSON], arr);
    
    arr = [arr arrayByAddingObject:[NSNull null]];
    as = [arr JSONString];
    eqo(as, @"[\"fi\",\"fo\",\"fa\",\"fum\",0.01,null]");
    eqo([as objectFromJSON], arr);
    
    arr = [NSArray arrayWithObjects:@"", [NSNull null], [NSNull null], @"1", nil];
    as = [arr JSONString];
    eqo(as, @"[\"\",null,null,\"1\"]");
    eqo([as objectFromJSON], arr);
}

- (void)test05dictionaries
{
    id dict = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:3], @"three",
        @"blue", @"colour",
        nil];
    id ds = [dict JSONString];
    eqo(ds, @"{\"colour\":\"blue\",\"three\":3}");
    eqo([ds objectFromJSON], dict);

    dict = [dict mutableCopy];
    [dict setObject:[NSNull null] forKey:@"null"];
    ds = [dict JSONString];
    eqo(ds, @"{\"colour\":\"blue\",\"null\":null,\"three\":3}");
    eqo([ds objectFromJSON], dict);
}

- (void)test06nested
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
    eqo([ds objectFromJSON], dict);
}

@end
