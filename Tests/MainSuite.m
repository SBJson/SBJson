//
// Created by SuperPappi on 01/01/2013.
//
// To change the template use AppCode | Preferences | File Templates.
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

@interface MainSuite : XCTestCase
@end

@implementation MainSuite {
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

- (void)testRoundtripUnwrapped {
    [self inExtForeachInSuite:@"main"
                        inext:@"in"
                       outExt:@"unwrapped"
                        block:^(NSString *inpath, NSString *outpath) {
            NSLog(@"%@", outpath);

            NSMutableArray *output = [NSMutableArray array];
            SBJson5ValueBlock block = ^(id value, BOOL *stop) {
                                                               XCTAssertNotNil(value);
                                                               [output addObject:value];
            };

            SBJson5ErrorBlock eh = ^(NSError *error) {
                                                      XCTFail(@"%@", error);
            };

            id parser = [SBJson5Parser unwrapRootArrayParserWithBlock:block
                                                         errorHandler:eh];

            XCTAssertEqual([parser parse:slurpd(inpath)], SBJson5ParserComplete);

            NSMutableString *str = [NSMutableString string];
            for (id out in output)
                [str appendString:[self->writer stringWithObject:out]];
            XCTAssertEqualObjects(str, chomp(slurp(outpath)), @"%@",
                                  [[inpath pathComponents] lastObject]);
        }];
}

- (void)testRoundtrip {
    [self inExtForeachInSuite:@"main"
                        inext:@"in"
                       outExt:@"out"
                        block:^(NSString *inpath, NSString *outpath) {
            id parser = [SBJson5Parser parserWithBlock:^(id value, BOOL *string) {
                    XCTAssertNotNil(value);
                    NSString *output = [self->writer stringWithObject:value];
                    XCTAssertNotNil(output, @"%@", self->writer.error);
                    XCTAssertEqualObjects(output, chomp(slurp(outpath)), @"%@", [[inpath pathComponents] lastObject]);
                }
            errorHandler:^(NSError *error) {
                    XCTFail(@"%@", error);
                }];
            XCTAssertEqual([parser parse:slurpd(inpath)], SBJson5ParserComplete);
        }];
}

- (void)testParseUntilEOF {
    [self inExtForeachInSuite:@"main"
                        inext:@"in"
                       outExt:@"eof"
                        block:^(NSString *inpath, NSString *outpath) {
            id parser = [SBJson5Parser parserWithBlock:^(id value, BOOL *string) {}
            errorHandler:^(NSError *error) {
                    XCTFail(@"%@", error);
                }];
            XCTAssertEqual([parser parse:slurpd(inpath)], SBJson5ParserWaitingForData);
        }];

    XCTAssertEqual(count, (NSUInteger)3);
}

/*
  - (void)IGNOREDtestReallyBrokenUTF8 {
  [self inExtForeachInSuite:@"kuhn" inext:@"in" outExt:@"out" block:^(NSString *inpath, NSString *outpath) {
  id value = [parser objectWithData:slurpd(inpath)];
  STAssertNotNil(value, parser.error);

  NSString *output = [writer stringWithObject:value];
  STAssertNotNil(output, writer.error);
  STAssertEqualObjects(output, chomp(slurp(outpath)), nil);
  }];
  STAssertEquals(count, (NSUInteger)1, nil);
  }*/

- (void)testParseError {
    [self inExtForeachInSuite:@"main"
                        inext:@"in"
                       outExt:@"err"
                        block:^(NSString *inpath, NSString *outpath) {
            id parser = [SBJson5Parser parserWithBlock:^(id o, BOOL *string) {
                    XCTFail(@"%@ - %@", o, [[inpath pathComponents] lastObject]);
                }
            allowMultiRoot:NO
                                       unwrapRootArray:NO
                                              maxDepth:3
                                          errorHandler:^(NSError *error) {
                    XCTAssertNotNil(error, @"%@", inpath);
                    XCTAssertEqualObjects([error localizedDescription], chomp(slurp(outpath)), @"%@", [[inpath pathComponents] lastObject]);
                }];
            [parser parse:slurpd(inpath)];
        }];
}

- (void)testWriteSuccess {
    [self inExtForeachInSuite:@"main"
                        inext:@"plist"
                       outExt:@"out"
                        block:^(NSString *inpath, NSString *outpath) {
            id value = [NSArray arrayWithContentsOfFile:inpath];
            NSString *output = [self->writer stringWithObject:value];
            XCTAssertNotNil(output, @"%@", self->writer.error);
            XCTAssertEqualObjects(output, chomp(slurp(outpath)));
        }];
}

- (void)testWriteError {
    writer = [SBJson5Writer writerWithMaxDepth:4 humanReadable:NO sortKeys:NO];

    [self inExtForeachInSuite:@"main"
                        inext:@"plist"
                       outExt:@"err"
                        block:^(NSString *inpath, NSString *outpath) {
            id value = [NSArray arrayWithContentsOfFile:inpath];
            XCTAssertNil([self->writer stringWithObject:value]);
            XCTAssertEqualObjects(self->writer.error, chomp(slurp(outpath)));
        }];
}


- (void)testFormat {
    writer = [SBJson5Writer writerWithMaxDepth:32 humanReadable:YES sortKeys:YES];

    [self inExtForeachInSuite:@"format"
                        inext:@"in"
                       outExt:@"out"
                        block:^(NSString *inpath, NSString *outpath) {
            id parser = [SBJson5Parser parserWithBlock:^(id value, BOOL *string) {
                    NSString *output = [self->writer stringWithObject:value];
                    XCTAssertNotNil(output, @"%@", self->writer.error);
                    XCTAssertEqualObjects(output, chomp(slurp(outpath)));
                }
            errorHandler:^(NSError *error) {
                    XCTFail(@"%@", error);
                }];
            [parser parse:slurpd(inpath)];
        }];
}

- (void)testComparatorSort {
    writer = [SBJson5Writer writerWithMaxDepth:32
                                 humanReadable:YES
                            sortKeysComparator:^(id obj1, id obj2) {
            return [obj1 compare:obj2 options:NSCaseInsensitiveSearch|NSLiteralSearch];
        }];

    [self inExtForeachInSuite:@"comparatorsort"
                        inext:@"in"
                       outExt:@"out"
                        block:^(NSString *inpath, NSString *outpath) {
            id parser = [SBJson5Parser parserWithBlock:^(id value, BOOL *string) {
                    NSString *output = [self->writer stringWithObject:value];
                    XCTAssertNotNil(output, @"%@", self->writer.error);
                    XCTAssertEqualObjects(output, chomp(slurp(outpath)));
                }
            errorHandler:^(NSError *error) {
                    XCTFail(@"%@", error);
                }];
            [parser parse:slurpd(inpath)];
        }];
}

- (void)testScalar {
    NSDictionary *data = @{
                           @"foo"        : @"\"foo\"",
                           @""           : @"\"\"",
                           [NSNull null] : @"null",
                           @-1            : @ "-1",
                           @42           : @"42",
                           @-0.1         : @"-0.10000000000000001",
                           @(YES)        : @"true"
    };

    for (id key in data) {
        NSString *expect = [data objectForKey:key];
        XCTAssertEqualObjects([writer stringWithObject:key], expect, @"%@", key);
    }
}

@end
