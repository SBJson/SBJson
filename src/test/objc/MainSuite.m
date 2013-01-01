//
// Created by SuperPappi on 01/01/2013.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SBJson.h"

static NSString *slurpd(NSString *path) {
    return [NSData dataWithContentsOfFile:path];
}

static NSString *slurp(NSString *path) {
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

static NSString *chomp(NSString *str) {
    return [str substringToIndex:str.length - 1];
}

@interface MainSuite : SenTestCase
@end

@implementation MainSuite {
    SBJsonParser *parser;
    SBJsonWriter *writer;
}

- (void)setUp {
    parser = [[SBJsonParser alloc] init];
    parser.maxDepth = 3u;
    
    writer = [[SBJsonWriter alloc] init];
    writer.maxDepth = 4u;
    writer.sortKeys = YES;
}

- (void)foreachInput:(NSString *)inext output:(NSString *)outext block:(void (^)(NSString*, NSString*))block {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *root = [[bundle resourcePath] stringByAppendingPathComponent:@"main"];

    for (NSString *fileName in [[NSFileManager defaultManager] enumeratorAtPath:root]) {
        if (![inext isEqualToString:[fileName pathExtension]])
            continue;

        NSString *inpath = [root stringByAppendingPathComponent:fileName];
        NSString *outpath = [[inpath stringByDeletingPathExtension] stringByAppendingPathExtension:outext];
        if (![[NSFileManager defaultManager] isReadableFileAtPath:outpath])
            continue;

        NSLog(@"Running test named: %@", [fileName stringByDeletingPathExtension]);
        block(inpath, outpath);
    }

}

- (void)testRoundtrip {
    [self foreachInput:@"in" output:@"out" block:^(NSString *inpath, NSString *outpath) {
        id value = [parser objectWithData:slurpd(inpath)];
        STAssertNotNil(value, parser.error);

        NSString *output = [writer stringWithObject:value];
        STAssertNotNil(output, writer.error);
        STAssertEqualObjects(output, chomp(slurp(outpath)), nil);
    }];
}

- (void)testParseError {
    [self foreachInput:@"in" output:@"err" block:^(NSString *inpath, NSString *outpath) {
        STAssertNil([parser objectWithData:slurpd(inpath)], nil);
        STAssertEqualObjects(parser.error, chomp(slurp(outpath)), nil);
    }];
}

- (void)testWriteSuccess {
    [self foreachInput:@"plist" output:@"out" block:^(NSString *inpath, NSString *outpath) {
        id value = [NSArray arrayWithContentsOfFile:inpath];
        NSString *output = [writer stringWithObject:value];
        STAssertNotNil(output, outpath);
        STAssertEqualObjects(output, chomp(slurp(outpath)), nil);
    }];
}

- (void)testWriteError {
    [self foreachInput:@"plist" output:@"err" block:^(NSString *inpath, NSString *outpath) {
        id value = [NSArray arrayWithContentsOfFile:inpath];
        STAssertNil([writer stringWithObject:value], nil);
        STAssertEqualObjects(writer.error, chomp(slurp(outpath)), nil);
    }];
}

@end