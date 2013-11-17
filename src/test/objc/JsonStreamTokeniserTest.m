//
// Created by SuperPappi on 09/01/2013.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "SBJson4.h"

static NSData *data(NSString *str) {
    return [str dataUsingEncoding:NSUTF8StringEncoding];
}

static NSString *str(char *b, NSUInteger l) {
    return [[NSString alloc] initWithBytes:b length:l encoding:NSUTF8StringEncoding];
}

@interface JsonStreamTokeniserTest : SenTestCase
@end

@implementation JsonStreamTokeniserTest {
    SBJson4StreamTokeniser *tokeniser;
    char *bytes;
    NSUInteger length;
}

- (void)setUp {
    tokeniser = [[SBJson4StreamTokeniser alloc] init];
}

- (void)testBasics {
    [tokeniser appendData:data(@"[true,false,null]")];

    STAssertEquals([tokeniser getToken:&bytes length:&length], sbjson4_token_array_open, tokeniser.error);

    STAssertEquals([tokeniser getToken:&bytes length:&length], sbjson4_token_bool, tokeniser.error);
    STAssertTrue(!strncmp(bytes, "true", 4), nil);

    STAssertEquals([tokeniser getToken:&bytes length:&length], sbjson4_token_value_sep, tokeniser.error);

    STAssertEquals([tokeniser getToken:&bytes length:&length], sbjson4_token_bool, tokeniser.error);
    STAssertTrue(!strncmp(bytes, "false", 5), nil);

    STAssertEquals([tokeniser getToken:&bytes length:&length], sbjson4_token_value_sep, tokeniser.error);

    STAssertEquals([tokeniser getToken:&bytes length:&length], sbjson4_token_null, tokeniser.error);
    STAssertTrue(!strncmp(bytes, "null", 4), nil);

    STAssertEquals([tokeniser getToken:&bytes length:&length], sbjson4_token_array_close, tokeniser.error);

    STAssertEquals([tokeniser getToken:&bytes length:&length], sbjson4_token_eof, tokeniser.error);
}

- (void)testNumber {
    [tokeniser appendData:data(@"123 45.6 7.8e9 ")];

    STAssertEquals([tokeniser getToken:&bytes length:&length], sbjson4_token_integer, tokeniser.error);
    STAssertEqualObjects(str(bytes, length), @"123", nil);

    STAssertEquals([tokeniser getToken:&bytes length:&length], sbjson4_token_real, tokeniser.error);
    STAssertEqualObjects(str(bytes, length), @"45.6", nil);

    STAssertEquals([tokeniser getToken:&bytes length:&length], sbjson4_token_real, tokeniser.error);
    STAssertEqualObjects(str(bytes, length), @"7.8e9", nil);

    STAssertEquals([tokeniser getToken:&bytes length:&length], sbjson4_token_eof, tokeniser.error);
}

- (void)testString {
    [tokeniser appendData:data(@"\"foo\" \"bar\"")];
    STAssertEquals([tokeniser getToken:&bytes length:&length], sbjson4_token_string, tokeniser.error);
    STAssertEqualObjects(str(bytes, length), @"foo", nil);

    STAssertEquals([tokeniser getToken:&bytes length:&length], sbjson4_token_string, tokeniser.error);
    STAssertEqualObjects(str(bytes, length), @"bar", nil);
}

- (void)testEncoded {
    [tokeniser appendData:data(@"\"\\u1234\\u5678\" \"\\n\\r\\b\\t\\f\"")];
    STAssertEquals([tokeniser getToken:&bytes length:&length], sbjson4_token_encoded, tokeniser.error);
    STAssertEqualObjects(str(bytes, length), @"\\u1234\\u5678", nil);

    STAssertEquals([tokeniser getToken:&bytes length:&length], sbjson4_token_encoded, tokeniser.error);
    STAssertEqualObjects(str(bytes, length), @"\\n\\r\\b\\t\\f", nil);

}

@end

