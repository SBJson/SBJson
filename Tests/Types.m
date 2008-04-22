//
//  Types.m
//  JSON
//
//  Created by Stig Brautaset on 11/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import "Tests.h"

#define testInt(x, y)   eq([[x JSONFragmentValue] intValue], (int)y)
#define testBool(x, y)  eq([[x JSONFragmentValue] boolValue], y)
#define testFloat(x, y) eq([[x JSONFragmentValue] floatValue], (float)y)

id json(NSString *path) {
    NSString *json = [NSString stringWithContentsOfFile:path
                                               encoding:NSASCIIStringEncoding
                                                  error:nil];
    assert(json);
    return [json JSONValue];
}


id plist(NSString *path) {
    NSString *plist = [NSString stringWithContentsOfFile:path
                                                encoding:NSASCIIStringEncoding
                                                   error:nil];
    assert(plist);
    return [plist propertyList];
}

@implementation Types

- (NSEnumerator *)splitString:(NSString *)str
{
    return [[str componentsSeparatedByString:@" "] objectEnumerator];
}

- (void)testNull
{
    STAssertTrue([[@"null" JSONFragmentValue] isKindOfClass:[NSNull class]], nil);
    eqo([@"null" JSONFragmentValue], [NSNull null]);

//    eqo([nil JSONFragment], @"null");
    eqo([[NSNull null] JSONFragment], @"null");
}

- (void)testBool
{
    testBool(@"true", YES);
    testBool(@"false", NO);

    id bools = [self splitString:@"false true false true"];
    for (id b; b = [bools nextObject]; ) {
        id bl = [b JSONFragmentValue];
        STAssertTrue([bl isKindOfClass:[NSNumber class]], nil);
        eqo([bl JSONFragment], b);
    }

    // Explict NSNumber initialised to boolean value
    eqo([[NSNumber numberWithBool:YES] JSONFragment], @"true");
    eqo([[NSNumber numberWithBool:NO] JSONFragment], @"false");
}

- (void)testNumbers
{
    NSArray *numbers = json(@"Tests/types/number.json");
    NSArray *expected = plist(@"Tests/types/number.plist");
    
    STAssertTrue([numbers count], @"have numbers");
    STAssertEquals([numbers count], [expected count], @"have as many as expected");
    
    for (int i = 0; i < [numbers count]; i++) {
        NSNumber *n = [numbers objectAtIndex:i];
        NSNumber *e = [expected objectAtIndex:i];
        STAssertTrue([n isKindOfClass:[NSNumber class]], nil);
        STAssertEqualsWithAccuracy([n doubleValue], [e doubleValue], 1e-6, nil);
    }
}

- (void)testStrings
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
        @" spaces  ",               @"\" spaces  \"",
        @"",                        @"\"\"",
//      @"/",                       @"\"\\/\"",
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
        eqo([key JSONFragmentValue], val);
        eqo([val JSONFragment], key);

        // Now do a double round-trip
        eqo([[val JSONFragment] JSONFragmentValue], val);
        eqo([[key JSONFragmentValue] JSONFragment], key);
    }
}

- (void)testStringsWithEscapedSlashes
{
    eqo([@"\"\\/test\\/path\"" JSONFragmentValue], @"/test/path");
    eqo([@"\"\\\\/test\\\\/path\"" JSONFragmentValue], @"\\/test\\/path");
}

- (void)testStringsWithUnicodeEscapes
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
        // e-acute and greater-than-or-equal-to
        [NSString stringWithFormat:@"%C%C", 0xe9, 0x2265],  @"\"\\u00e9\\u2265\"",
        
        // e-acute and greater-than-or-equal-to, surrounded by 42
        [NSString stringWithFormat:@"42%C42%C42", 0xe9, 0x2265],  @"\"42\\u00e942\\u226542\"",

        // e-acute with upper-case hex
        [NSString stringWithFormat:@"%C", 0xe9],  @"\"\\u00E9\"",

        // G-clef (UTF16 surrogate pair)
        [NSString stringWithFormat:@"%C", 0x1D11E],  @"\"\\uD834\\uDD1E\"",

        nil];

    NSEnumerator *enumerator = [dict keyEnumerator];
    for (NSString *key; key = [enumerator nextObject]; ) {
        NSString *val = [dict objectForKey:key];
//        NSLog(@"'%@' => '%@'", key, val);
        eqo([key JSONFragmentValue], val);
        eqo([[val JSONFragment] JSONFragmentValue], val);
    }
}

- (void)testStringsWithControlChars
{
    NSArray *array = [NSArray arrayWithObjects:
        @"\\u0000", @"\\u0001", @"\\u0002", @"\\u0003", @"\\u0004",
        @"\\u0005", @"\\u0006", @"\\u0007", @"\\b",     @"\\t",
        @"\\n",     @"\\u000b", @"\\f",     @"\\r",     @"\\u000e",
        @"\\u000f", @"\\u0010", @"\\u0011", @"\\u0012", @"\\u0013",
        @"\\u0014", @"\\u0015", @"\\u0016", @"\\u0017", @"\\u0018",
        @"\\u0019", @"\\u001a", @"\\u001b", @"\\u001c", @"\\u001d",
        @"\\u001e", @"\\u001f", @" ", nil];

    for (int i = 0; i < [array count]; i++) {
        id string = [NSString stringWithFormat:@"%C", (unichar)i];
        id fragment = [NSString stringWithFormat:@"\"%@\"", [array objectAtIndex:i]];
        eqo([string JSONFragment], fragment);
        eqo([fragment JSONFragmentValue], string);
    }
}

- (void)testArray
{
    id arr = [@"fi fo fa fum" componentsSeparatedByString:@" "];
    id as = [arr JSONRepresentation];
    eqo(as, @"[\"fi\",\"fo\",\"fa\",\"fum\"]");
    eqo([as JSONValue], arr);
    
    arr = [arr arrayByAddingObject:[NSNumber numberWithDouble:0.01]];
    as = [arr JSONRepresentation];
    eqo(as, @"[\"fi\",\"fo\",\"fa\",\"fum\",0.01]");
    eqo([as JSONValue], arr);
    
    arr = [arr arrayByAddingObject:[NSNull null]];
    as = [arr JSONRepresentation];
    eqo(as, @"[\"fi\",\"fo\",\"fa\",\"fum\",0.01,null]");
    eqo([as JSONValue], arr);
    
    arr = [NSArray arrayWithObjects:@"", [NSNull null], [NSNull null], @"1", nil];
    as = [arr JSONRepresentation];
    eqo(as, @"[\"\",null,null,\"1\"]");
    eqo([as JSONValue], arr);
}

- (void)testObject
{
    id dict = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:3], @"three",
        @"blue", @"colour",
        nil];
    id ds = [dict JSONRepresentation];
    eqo(ds, @"{\"colour\":\"blue\",\"three\":3}");
    eqo([ds JSONValue], dict);

    dict = [dict mutableCopy];
    [dict setObject:[NSNull null] forKey:@"null"];
    ds = [dict JSONRepresentation];
    eqo(ds, @"{\"colour\":\"blue\",\"null\":null,\"three\":3}");
    eqo([ds JSONValue], dict);
}

- (void)testNested
{
    id dict = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSArray arrayWithObjects:
            [NSArray arrayWithObjects:
                [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInt:-1], @"minus", nil], nil], nil],
        @"top",
        nil];
    id ds = [dict JSONRepresentation];
    eqo(ds, @"{\"top\":[[{\"minus\":-1}]]}");
    eqo([ds JSONValue], dict);
}

@end
