//
//  Errors.m
//  JSON
//
//  Created by Stig Brautaset on 13/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import "Tests.h"

// The ST guys sure like typing. Personally, I don't.
#define tn(expr, name) \
    STAssertThrowsSpecificNamed(expr, NSException, name, @"ieee!")

@implementation Errors

- (void)setUp {
    json = [SBJSON new];
}

- (void)tearDown {
    [json release];
}

#pragma mark Generator

- (void)testUnsupportedObject
{
    NSError *error = nil;
    STAssertNil([json stringWithJSON:[NSDate date] error:&error], nil);
    STAssertNotNil(error, nil);
}

- (void)testNonStringDictionaryKey
{
    NSArray *keys = [NSArray arrayWithObjects:[NSNull null],
                     [NSNumber numberWithInt:1],
                     [NSArray array],
                     [NSDictionary dictionary],
                     nil];
    
    for (int i = 0; i < [keys count]; i++) {
        NSError *error = nil;
        NSDictionary *object = [NSDictionary dictionaryWithObject:@"1" forKey:[keys objectAtIndex:i]];
        STAssertNil([json stringWithJSON:object error:&error], nil);
        STAssertNotNil(error, nil);
    }
}

#pragma mark Scanner

- (void)testTrailingComma
{
    tn([@"[1,]" JSONValue], @"enovalue");
    tn([@"{\"a\":1,}" JSONValue], @"enostring");
}

- (void)testMissingComma
{
    tn([@"[1" JSONValue], @"enocomma");
    tn([@"{\"a\":1" JSONValue], @"enocomma");
    tn([@"{\"a\":1 \"b\":2 }" JSONValue], @"enocomma");
}

- (void)testMissingValue
{
    tn([@"[1,," JSONValue], @"enovalue");

    tn([@"{\"a\":1,," JSONValue], @"enostring");
    tn([@"{\"a\":1," JSONValue], @"enostring");
    tn([@"{\"a\":}" JSONValue], @"enovalue");
    tn([@"{\"a\":" JSONValue], @"enovalue");
}

- (void)testMissingSeparator
{
    tn([@"{\"a\"" JSONValue], @"enocolon");
}

- (void)testDictionaryFromJSON
{
    tn([@"{" JSONValue], @"enostring");
    tn([@"{a" JSONValue], @"enostring");
    tn([@"{null" JSONValue], @"enostring");
    tn([@"{false" JSONValue], @"enostring");
    tn([@"{true" JSONValue], @"enostring");
    tn([@"{{}" JSONValue], @"enostring");
    tn([@"{[]" JSONValue], @"enostring");
    tn([@"{1" JSONValue], @"enostring");
}

- (void)testSingleQuotedString
{
    tn([@"['1'" JSONValue], @"enovalue");
    tn([@"{'1'" JSONValue], @"enostring");
    tn([@"{\"a\":'1'" JSONValue], @"enovalue");
}

- (void)testGarbage
{
    tn([@"'1'" JSONValue], @"enojson");
    tn([@"'hello'" JSONValue], @"enojson");
    tn([@"\"" JSONValue], @"enojson");
    tn([@"\"hello" JSONValue], @"enojson");
    tn([@"" JSONValue], @"enojson");
    tn([@"**" JSONValue], @"enojson");
}

- (void)testUnescapedControlChar
{
    for (unsigned i = 0; i < 0x20; i++)
        tn(([[NSString stringWithFormat:@"\"%C\"", i] JSONFragmentValue]), @"estring");
}

- (void)testBrokenSurrogatePairs
{
//    @"\"\\uD834\\uDD1E\"" is the Unicode surrogate pairs for g-clef
    tn([@"\"\\uD834foo\"" JSONFragmentValue], @"no_low_surrogate_char");
    tn([@"\"\\uD834\\u001E\"" JSONFragmentValue], @"expected_low_surrogate");
    tn([@"\"\\uDD1E\"" JSONFragmentValue], @"no_high_surrogate_char");
}

- (void)testIllegalNumber
{
    tn([@"+666e-1" JSONValue], @"enojson");
}

- (void)testObjectFromFragment
{
    tn([@"true" JSONValue], @"enojson");
    tn([@"false" JSONValue], @"enojson");
    tn([@"null" JSONValue], @"enojson");
    tn([@"1" JSONValue], @"enojson");
    tn([@"1.0" JSONValue], @"enojson");
    tn([@"\"string\"" JSONValue], @"enojson");
}


@end
