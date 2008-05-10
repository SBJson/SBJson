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

#define assertErrorContains(e, s) \
    (void)"dummy"
//    STAssertTrue([[[e userInfo] objectForKey:NSLocalizedDescriptionKey] hasPrefix:s], nil)

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
    NSArray *fragments = [@"'1' 'hello' \" \"hello ** " componentsSeparatedByString:@" "];
    for (int i = 0; i < [fragments count]; i++) {
        NSString *fragment = [fragments objectAtIndex:i];
        
        NSError *err = nil;
        STAssertNil([json fragmentWithString:fragment error:&err], fragment);
        STAssertNotNil(err, @"error has been set");
        assertErrorContains(err, @"Valid fragment");
    }
}

- (void)testUnescapedControlChar
{
    for (unsigned i = 0; i < 0x20; i++) {
        NSError *err = nil;
        NSString *str = [NSString stringWithFormat:@"\"%C\"", i];
        STAssertNil([json fragmentWithString:str error:&err], nil);
        STAssertNotNil(err, @"error has been set");
        assertErrorContains(err, @"Unescaped control character");
    }
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
    NSError *err = nil;
    STAssertNil([json fragmentWithString:@"+666e-1" error:&err], nil);
    STAssertNotNil(err, nil);

    // XXX: Should eventually be something like "Leading + not allowed in numbers"
    assertErrorContains(err, @"Unrecognised leading character");
}

- (void)testObjectFromFragment
{
    
    NSArray *fragments = [@"true false null 1 1.0 \"str\"" componentsSeparatedByString:@" "];
    for (int i = 0; i < [fragments count]; i++) {
        NSString *fragment = [fragments objectAtIndex:i];

        NSError *err = nil;
        STAssertNil([json objectWithString:fragment error:&err], fragment);
        STAssertNotNil(err, @"error has been set");
        assertErrorContains(err, @"Valid fragment");
    }
}

@end
