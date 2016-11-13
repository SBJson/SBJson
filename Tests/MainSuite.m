//
// Created by SuperPappi on 01/01/2013.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SBJson4.h"
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
    SBJson4Writer *writer;
    NSUInteger count;
}

- (void)setUp {
    writer = [[SBJson4Writer alloc] init];
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
        if (![inext isEqualToString:[fileName pathExtension]])
            continue;

        NSString *inpath = [root stringByAppendingPathComponent:fileName];
        NSString *outpath = [[inpath stringByDeletingPathExtension] stringByAppendingPathExtension:outext];
        if (![[NSFileManager defaultManager] isReadableFileAtPath:outpath])
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
                            SBJson4ValueBlock block = ^(id value, BOOL *stop) {
                                XCTAssertNotNil(value);
                                [output addObject:value];
                            };

                            SBJson4ErrorBlock eh = ^(NSError *error) {
                                XCTFail(@"%@", error);
                            };

                            id parser = [SBJson4Parser unwrapRootArrayParserWithBlock:block
                                                                         errorHandler:eh];

                            XCTAssertEqual([parser parse:slurpd(inpath)], SBJson4ParserComplete);

                            NSMutableString *str = [NSMutableString string];
                            for (id out in output)
                                [str appendString:[writer stringWithObject:out]];
                            XCTAssertEqualObjects(str, chomp(slurp(outpath)), @"%@",
                                                  [[inpath pathComponents] lastObject]);
        }];
}

- (void)testRoundtrip {
    [self inExtForeachInSuite:@"main"
                        inext:@"in"
                       outExt:@"out"
                        block:^(NSString *inpath, NSString *outpath) {
            id parser = [SBJson4Parser parserWithBlock:^(id value, BOOL *string) {
                    XCTAssertNotNil(value);
                    NSString *output = [writer stringWithObject:value];
                    XCTAssertNotNil(output, @"%@", writer.error);
                    XCTAssertEqualObjects(output, chomp(slurp(outpath)), @"%@", [[inpath pathComponents] lastObject]);
                }
                                        allowMultiRoot:NO
                                       unwrapRootArray:NO
                                          errorHandler:^(NSError *error) {
                    XCTFail(@"%@", error);
                }];
            [parser parse:slurpd(inpath)];
        }];
}

- (void)testParseUntilEOF {
    [self inExtForeachInSuite:@"main"
                        inext:@"in"
                       outExt:@"eof"
                        block:^(NSString *inpath, NSString *outpath) {
                            id parser = [SBJson4Parser parserWithBlock:^(id value, BOOL *string) {}
                                                        allowMultiRoot:NO
                                                       unwrapRootArray:NO
                                                          errorHandler:^(NSError *error) {
                                                              XCTFail(@"%@", error);
                                                          }];
                            XCTAssertEqual([parser parse:slurpd(inpath)], SBJson4ParserWaitingForData);
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
            id parser = [[SBJson4Parser alloc] initWithBlock:^(id o, BOOL *string) {
                XCTFail(@"%@ - %@", o, [[inpath pathComponents] lastObject]);
                }
                                                processBlock:nil
                                                   multiRoot:NO
                                             unwrapRootArray:NO
                                                    maxDepth:3
                                                errorHandler:^(NSError *error) {
                    XCTAssertNotNil(error, @"%@", inpath);
                    XCTAssertEqualObjects([error localizedDescription], chomp(slurp(outpath)), @"%@", [[inpath pathComponents]
                                                                                                          lastObject]);
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
            NSString *output = [writer stringWithObject:value];
            XCTAssertNotNil(output, @"%@", writer.error);
            XCTAssertEqualObjects(output, chomp(slurp(outpath)));
        }];
}

- (void)testWriteError {
    writer.maxDepth = 4u;

    [self inExtForeachInSuite:@"main"
                        inext:@"plist"
                       outExt:@"err"
                        block:^(NSString *inpath, NSString *outpath) {
            id value = [NSArray arrayWithContentsOfFile:inpath];
            XCTAssertNil([writer stringWithObject:value]);
            XCTAssertEqualObjects(writer.error, chomp(slurp(outpath)));
        }];
}


- (void)testFormat {
    writer.humanReadable = YES;
    writer.sortKeys = YES;

    [self inExtForeachInSuite:@"format"
                        inext:@"in"
                       outExt:@"out"
                        block:^(NSString *inpath, NSString *outpath) {
            id parser = [SBJson4Parser parserWithBlock:^(id value, BOOL *string) {
                    NSString *output = [writer stringWithObject:value];
                    XCTAssertNotNil(output, @"%@", writer.error);
                    XCTAssertEqualObjects(output, chomp(slurp(outpath)));
                }
                                        allowMultiRoot:NO
                                       unwrapRootArray:NO
                                          errorHandler:^(NSError *error) {
                    XCTFail(@"%@", error);
                }];
            [parser parse:slurpd(inpath)];
        }];
}

- (void)testComparatorSort {
    writer.humanReadable = YES;
    writer.sortKeys = YES;
    writer.sortKeysComparator = ^(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch|NSLiteralSearch];
    };

    [self inExtForeachInSuite:@"comparatorsort"
                        inext:@"in"
                       outExt:@"out"
                        block:^(NSString *inpath, NSString *outpath) {
            id parser = [SBJson4Parser parserWithBlock:^(id value, BOOL *string) {
                    NSString *output = [writer stringWithObject:value];
                    XCTAssertNotNil(output, @"%@", writer.error);
                    XCTAssertEqualObjects(output, chomp(slurp(outpath)));
                }
                                        allowMultiRoot:NO
                                       unwrapRootArray:NO
                                          errorHandler:^(NSError *error) {
                    XCTFail(@"%@", error);
                }];
            [parser parse:slurpd(inpath)];
        }];
}

@end
