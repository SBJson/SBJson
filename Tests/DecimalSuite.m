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

@end
