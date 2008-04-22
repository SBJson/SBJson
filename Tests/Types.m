//
//  Types.m
//  JSON
//
//  Created by Stig Brautaset on 11/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import "Tests.h"

NSString *file(NSString *path) {
    NSString *content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSASCIIStringEncoding
                                                     error:nil];
    assert(content);
    return [content substringToIndex:[content length]-1];
}

@implementation Types

- (void)testNull
{
    NSString *json = @"[null,null]";
    NSArray *nulls = [NSArray arrayWithObjects:[NSNull null], [NSNull null], nil];
    
    STAssertEqualObjects([json JSONValue], nulls, nil);
    STAssertEqualObjects([nulls JSONRepresentation], json, nil);
}

- (void)testBool
{
    NSString *json = @"[true,false]";
    NSArray *bools = [NSArray arrayWithObjects:[NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO], nil];
  
    STAssertEqualObjects([json JSONValue], bools, nil);
    STAssertEqualObjects([bools JSONRepresentation], json, nil);
}

- (void)testNumbers
{
    NSArray *numbers = [file(@"Tests/types/number.json") JSONValue];
    NSArray *expected = [file(@"Tests/types/number.plist") propertyList];
    
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
    NSString *json = file(@"Tests/types/array.json");
    NSArray *expected = [file(@"Tests/types/array.plist") propertyList];
    STAssertEqualObjects([json JSONValue], expected, nil);
    STAssertEqualObjects([expected JSONRepresentation], json, nil);
}

- (void)testObject
{
    NSString *json = file(@"Tests/types/object.json");
    NSArray *expected = [file(@"Tests/types/object.plist") propertyList];
    STAssertEqualObjects([json JSONValue], expected, nil);
    STAssertEqualObjects([expected JSONRepresentation], json, nil);
}

@end
