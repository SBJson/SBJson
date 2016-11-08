//
// Created by SuperPappi on 09/01/2013.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "SBJson5.h"
#import <XCTest/XCTest.h>


static NSData *data(NSString *str) {
    return [str dataUsingEncoding:NSUTF8StringEncoding];
}

static NSString *str(char *b, NSUInteger l) {
    return [[NSString alloc] initWithBytes:b length:l encoding:NSUTF8StringEncoding];
}

@interface JsonStreamTokeniserTest : XCTestCase
@end

@implementation JsonStreamTokeniserTest {
    SBJson5StreamTokeniser *tokeniser;
    char *bytes;
    NSUInteger length;
}

- (void)setUp {
    tokeniser = [[SBJson5StreamTokeniser alloc] init];
}

- (void)testBasics {
    [tokeniser appendData:data(@"[true,false,null]")];

    XCTAssertEqual([tokeniser getToken:&bytes length:&length], sbjson5_token_array_open, @"%@", tokeniser.error);

    XCTAssertEqual([tokeniser getToken:&bytes length:&length], sbjson5_token_bool, @"%@", tokeniser.error);
    XCTAssertTrue(!strncmp(bytes, "true", 4));

    XCTAssertEqual([tokeniser getToken:&bytes length:&length], sbjson5_token_value_sep, @"%@", tokeniser.error);
    
    XCTAssertEqual([tokeniser getToken:&bytes length:&length], sbjson5_token_bool, @"%@", tokeniser.error);
    XCTAssertTrue(!strncmp(bytes, "false", 5));

    XCTAssertEqual([tokeniser getToken:&bytes length:&length], sbjson5_token_value_sep, @"%@", tokeniser.error);

    XCTAssertEqual([tokeniser getToken:&bytes length:&length], sbjson5_token_null, @"%@", tokeniser.error);
    XCTAssertTrue(!strncmp(bytes, "null", 4));

    XCTAssertEqual([tokeniser getToken:&bytes length:&length], sbjson5_token_array_close, @"%@", tokeniser.error);

    XCTAssertEqual([tokeniser getToken:&bytes length:&length], sbjson5_token_eof, @"%@", tokeniser.error);
}

- (void)testNumber {
    [tokeniser appendData:data(@"123 45.6 7.8e9 ")];

    XCTAssertEqual([tokeniser getToken:&bytes length:&length], sbjson5_token_integer, @"%@", tokeniser.error);
    XCTAssertEqualObjects(str(bytes, length), @"123");

    XCTAssertEqual([tokeniser getToken:&bytes length:&length], sbjson5_token_real, @"%@", tokeniser.error);
    XCTAssertEqualObjects(str(bytes, length), @"45.6");

    XCTAssertEqual([tokeniser getToken:&bytes length:&length], sbjson5_token_real, @"%@", tokeniser.error);
    XCTAssertEqualObjects(str(bytes, length), @"7.8e9");

    XCTAssertEqual([tokeniser getToken:&bytes length:&length], sbjson5_token_eof, @"%@", tokeniser.error);
}

- (void)testString {
    [tokeniser appendData:data(@"\"foo\" \"bar\"")];
    XCTAssertEqual([tokeniser getToken:&bytes length:&length], sbjson5_token_string, @"%@", tokeniser.error);
    XCTAssertEqualObjects(str(bytes, length), @"foo");

    XCTAssertEqual([tokeniser getToken:&bytes length:&length], sbjson5_token_string, @"%@", tokeniser.error);
    XCTAssertEqualObjects(str(bytes, length), @"bar");
}

- (void)testEncoded {
    [tokeniser appendData:data(@"\"\\u1234\\u5678\" \"\\n\\r\\b\\t\\f\"")];
    XCTAssertEqual([tokeniser getToken:&bytes length:&length], sbjson5_token_encoded, @"%@", tokeniser.error);
    XCTAssertEqualObjects(str(bytes, length), @"\\u1234\\u5678");

    XCTAssertEqual([tokeniser getToken:&bytes length:&length], sbjson5_token_encoded, @"%@", tokeniser.error);
    XCTAssertEqualObjects(str(bytes, length), @"\\n\\r\\b\\t\\f");

}

@end

