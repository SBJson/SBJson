//
// Created by voshill on 16/01/2025.
//


#import "SBJson5.h"
#import <XCTest/XCTest.h>


static NSData *slurpd(NSString *path) {
    return [NSData dataWithContentsOfFile:path];
}

static NSString *slurp(NSString *path) {
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

static NSString *chomp(NSString *str) {
    return [str substringToIndex:str.length - 1];
}

@interface DecimalSuite : XCTestCase
@end

@implementation DecimalSuite {
    SBJson5Writer *writer;
    NSUInteger count;
}

- (void)setUp {
    writer = [SBJson5Writer new];
    count = 0u;
}

- (NSString*)suitePath:(NSString*)suite {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return [[[bundle resourcePath] stringByAppendingPathComponent:@"TestData"]
             stringByAppendingPathComponent:suite];
}

- (void)inExtForeachInSuite:(NSString *)suite
                      inext:(NSString *)inext
                     outExt:(NSString *)outext
                      block:(void (^)(NSString *, NSString *))block {
    NSString *root = [self suitePath:suite];
    for (NSString *fileName in [[NSFileManager defaultManager] enumeratorAtPath:root]) {
        if (![outext isEqualToString:[fileName pathExtension]])
            continue;

        NSString *outpath = [root stringByAppendingPathComponent:fileName];
        NSString *inpath = [[outpath stringByDeletingPathExtension] stringByAppendingPathExtension:inext];
        if (![[NSFileManager defaultManager] isReadableFileAtPath:inpath])
            continue;

        count++;
        block(inpath, outpath);
    }
}

- (void)testRoundtrip {
    [self inExtForeachInSuite:@"decimal"
                        inext:@"in"
                       outExt:@"out"
                        block:^(NSString *inpath, NSString *outpath) {
        id parser = [SBJson5Parser parserWithBlock:^(id value, BOOL *string) {
            XCTAssertNotNil(value);
            NSString *output = [self->writer stringWithObject:value];
            XCTAssertNotNil(output, @"%@", self->writer.error);
            XCTAssertEqualObjects(output, chomp(slurp(outpath)), @"%@", [[inpath pathComponents] lastObject]);
        } allowMultiRoot:NO unwrapRootArray:NO maxDepth:32 useNSDecimalNumber:YES errorHandler:^(NSError *error) {
            XCTFail(@"%@", error);
        }];
        XCTAssertEqual([parser parse:slurpd(inpath)], SBJson5ParserComplete);
    }];
}

- (void)testNSDecimalParsing {
    NSString *jsonString = @"[0.1, 1.2]";
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    id parser = [SBJson5Parser parserWithBlock:^(id value, BOOL *string) {
        XCTAssertNotNil(value);
        for (id item in value) {
            XCTAssertTrue([item isKindOfClass:[NSDecimalNumber class]], @"Parsed value should be of type NSDecimalNumber");
        }
    } allowMultiRoot:NO unwrapRootArray:NO maxDepth:32 useNSDecimalNumber:YES errorHandler:^(NSError *error) {
        XCTFail(@"%@", error);
    }];
    XCTAssertEqual([parser parse:jsonData], SBJson5ParserComplete);
}

- (void)testIntegerOverflowFallsThroughToDouble {
    // 20-digit number larger than ULLONG_MAX (18446744073709551615).
    // Without fix: strtoull silently saturates to ULLONG_MAX.
    // With fix: errno checked, falls through to strtod.
    NSString *json = @"[99999999999999999999]";
    id parser = [SBJson5Parser parserWithBlock:^(id value, BOOL *stop) {
        NSNumber *num = value[0];
        XCTAssertNotEqual([num unsignedLongLongValue], ULLONG_MAX);
        XCTAssertEqual([num objCType][0], 'd');
    } errorHandler:^(NSError *error) {
        XCTFail(@"%@", error);
    }];
    XCTAssertEqual([parser parse:[json dataUsingEncoding:NSUTF8StringEncoding]], SBJson5ParserComplete);
}

- (void)testNegativeIntegerOverflowFallsThroughToDouble {
    // Number that exceeds the 20-digit guard to verify negative
    // fallthrough to strtod works at all.
    NSString *json = @"[-123456789012345678901]";
    id parser = [SBJson5Parser parserWithBlock:^(id value, BOOL *stop) {
        NSNumber *num = value[0];
        XCTAssertEqual([num objCType][0], 'd');
    } errorHandler:^(NSError *error) {
        XCTFail(@"%@", error);
    }];
    XCTAssertEqual([parser parse:[json dataUsingEncoding:NSUTF8StringEncoding]], SBJson5ParserComplete);
}

- (void)testLargeIntegerWithinRangeUsesFastPath {
    // 20-digit number that fits within ULLONG_MAX range.
    NSString *json = @"[10000000000000000000]";
    id parser = [SBJson5Parser parserWithBlock:^(id value, BOOL *stop) {
        NSNumber *num = value[0];
        XCTAssertEqual([num unsignedLongLongValue], 10000000000000000000ULL);
        XCTAssertEqual([num objCType][0], 'Q');
    } errorHandler:^(NSError *error) {
        XCTFail(@"%@", error);
    }];
    XCTAssertEqual([parser parse:[json dataUsingEncoding:NSUTF8StringEncoding]], SBJson5ParserComplete);
}

- (void)testSmallIntegerStillUsesFastPath {
    NSString *json = @"[42]";
    id parser = [SBJson5Parser parserWithBlock:^(id value, BOOL *stop) {
        NSNumber *num = value[0];
        XCTAssertEqual([num longLongValue], 42);
        XCTAssertNotEqual([num objCType][0], 'd');
    } errorHandler:^(NSError *error) {
        XCTFail(@"%@", error);
    }];
    XCTAssertEqual([parser parse:[json dataUsingEncoding:NSUTF8StringEncoding]], SBJson5ParserComplete);
}

@end
