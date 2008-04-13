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

- (void)testTrailingComma
{
    tn([@"[1,]" objectFromJSON], @"comma");
    tn([@"{\"a\":1,}" objectFromJSON], @"comma");
}

- (void)testMissingComma
{
    tn([@"[1" objectFromJSON], @"enocomma");
    tn([@"{\"a\":1" objectFromJSON], @"enocomma");
    tn([@"{\"a\":1 \"b\":2 }" objectFromJSON], @"enocomma");
}

- (void)testMissingValue
{
    tn([@"[1,," objectFromJSON], @"enovalue");

    tn([@"{\"a\":1,," objectFromJSON], @"enovalue");
    tn([@"{\"a\":1," objectFromJSON], @"enovalue");
    tn([@"{\"a\":}" objectFromJSON], @"enovalue");
    tn([@"{\"a\":" objectFromJSON], @"enovalue");
}

- (void)testMissingSeparator
{
    tn([@"{\"a\"" objectFromJSON], @"enoseparator");
}

- (void)testDictionaryFromJSON
{
    tn([@"{" objectFromJSON], @"enovalue");
    tn([@"{a" objectFromJSON], @"enovalue");
    tn([@"{null" objectFromJSON], @"enostring");
    tn([@"{false" objectFromJSON], @"enostring");
    tn([@"{true" objectFromJSON], @"enostring");
    tn([@"{{}" objectFromJSON], @"enostring");
    tn([@"{[]" objectFromJSON], @"enostring");
    tn([@"{1" objectFromJSON], @"enostring");
}

- (void)testDictionaryToJSON
{
    tn([[NSDictionary dictionaryWithObject:@"1" forKey:[NSNull null]] JSON], @"enostring");
    tn([[NSDictionary dictionaryWithObject:@"1" forKey:[NSNumber numberWithInt:1]] JSON], @"enostring");
    tn([[NSDictionary dictionaryWithObject:@"1" forKey:[NSArray array]] JSON], @"enostring");
    tn([[NSDictionary dictionaryWithObject:@"1" forKey:[NSDictionary dictionary]] JSON], @"enostring");
}

- (void)testSingleQuotedString
{
    tn([@"['1'" objectFromJSON], @"enovalue");
    tn([@"{'1'" objectFromJSON], @"enovalue");
    tn([@"{\"a\":'1'" objectFromJSON], @"enovalue");
}

- (void)testGarbage
{
    tn([@"'1'" objectFromJSON], @"enojson");
    tn([@"'hello'" objectFromJSON], @"enojson");
    tn([@"\"" objectFromJSON], @"enojson");
    tn([@"\"hello" objectFromJSON], @"enojson");
    tn([@"" objectFromJSON], @"enojson");
    tn([@"**" objectFromJSON], @"enojson");
}

- (void)testBrokenSurrogatePairs
{
//    @"\"\\uD834\\uDD1E\"" is the Unicode surrogate pairs for g-clef
    tn([@"\"\\uD834foo\"" objectFromJSON], @"no_low_surrogate_char");
    tn([@"\"\\uD834\\u001E\"" objectFromJSON], @"expected_low_surrogate");
    tn([@"\"\\uDD1E\"" objectFromJSON], @"no_high_surrogate_char");
}

- (void)testNonsupportedObject
{
    tn([[NSDate date] JSONFragment], @"unsupported");
}

- (void)testObjectFromFragment
{
    tn([@"true" objectFromJSON], @"enoobject");
    tn([@"false" objectFromJSON], @"enoobject");
    tn([@"null" objectFromJSON], @"enoobject");
    tn([@"1" objectFromJSON], @"enoobject");
    tn([@"1.0" objectFromJSON], @"enoobject");
    tn([@"\"string\"" objectFromJSON], @"enoobject");
}


@end
