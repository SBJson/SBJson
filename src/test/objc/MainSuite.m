//
// Created by SuperPappi on 01/01/2013.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SBJson.h"

static NSData *slurpd(NSString *path) {
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
    NSUInteger count;
}

- (void)setUp {
    parser = [[SBJsonParser alloc] init];    
    writer = [[SBJsonWriter alloc] init];
    count = 0u;
}

- (NSString*)suitePath:(NSString*)suite {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return [[bundle resourcePath] stringByAppendingPathComponent:suite];
}

- (void)inExtForeachInSuite:(NSString *)suite inext:(NSString *)inext outExt:(NSString *)outext block:(void (^)(NSString *, NSString *))block {
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

- (void)testRoundtrip {
    [self inExtForeachInSuite:@"main" inext:@"in" outExt:@"out" block:^(NSString *inpath, NSString *outpath) {
        id value = [parser objectWithData:slurpd(inpath)];
        STAssertNotNil(value, parser.error);

        NSString *output = [writer stringWithObject:value];
        STAssertNotNil(output, writer.error);
        STAssertEqualObjects(output, chomp(slurp(outpath)), [[inpath pathComponents] lastObject]);
    }];
    
    STAssertEquals(count, (NSUInteger)37, nil);
}

- (void)IGNOREDtestReallyBrokenUTF8 {
    [self inExtForeachInSuite:@"kuhn" inext:@"in" outExt:@"out" block:^(NSString *inpath, NSString *outpath) {
        id value = [parser objectWithData:slurpd(inpath)];
        STAssertNotNil(value, parser.error);

        NSString *output = [writer stringWithObject:value];
        STAssertNotNil(output, writer.error);
        STAssertEqualObjects(output, chomp(slurp(outpath)), nil);
    }];

    STAssertEquals(count, (NSUInteger)1, nil);
}


- (void)testParseError {
    parser.maxDepth = 3u;

    [self inExtForeachInSuite:@"main" inext:@"in" outExt:@"err" block:^(NSString *inpath, NSString *outpath) {
        STAssertNil([parser objectWithData:slurpd(inpath)], nil);
        STAssertEqualObjects(parser.error, chomp(slurp(outpath)), [[inpath pathComponents] lastObject]);
    }];
    
    STAssertEquals(count, (NSUInteger)35, nil);

}

- (void)testWriteSuccess {
    [self inExtForeachInSuite:@"main" inext:@"plist" outExt:@"out" block:^(NSString *inpath, NSString *outpath) {
        id value = [NSArray arrayWithContentsOfFile:inpath];
        NSString *output = [writer stringWithObject:value];
        STAssertNotNil(output, writer.error);
        STAssertEqualObjects(output, chomp(slurp(outpath)), nil);
    }];
    
    STAssertEquals(count, (NSUInteger)2, nil);

}

- (void)testWriteError {
    writer.maxDepth = 4u;

    [self inExtForeachInSuite:@"main" inext:@"plist" outExt:@"err" block:^(NSString *inpath, NSString *outpath) {
        id value = [NSArray arrayWithContentsOfFile:inpath];
        STAssertNil([writer stringWithObject:value], nil);
        STAssertEqualObjects(writer.error, chomp(slurp(outpath)), nil);
    }];
    
    STAssertEquals(count, (NSUInteger)5, nil);
}


- (void)testFormat {
    writer.humanReadable = YES;
    writer.sortKeys = YES;
    
    [self inExtForeachInSuite:@"format" inext:@"in" outExt:@"out" block:^(NSString *inpath, NSString *outpath) {
        id value = [parser objectWithData:slurpd(inpath)];
        STAssertNotNil(value, parser.error);

        NSString *name = [[inpath pathComponents] lastObject];
        
        NSString *output = [writer stringWithObject:value];
        STAssertNotNil(output, @"%@: %@", name, writer.error);
        STAssertEqualObjects(output, chomp(slurp(outpath)), name);
    }];
    
    STAssertEquals(count, (NSUInteger)8, nil);
}

- (void)testComparatorSort {
    writer.humanReadable = YES;
    writer.sortKeys = YES;
	writer.sortKeysComparator = ^(id obj1, id obj2) {
		return [obj1 compare:obj2 options:NSCaseInsensitiveSearch|NSLiteralSearch];
	};

    [self inExtForeachInSuite:@"comparatorsort" inext:@"in" outExt:@"out" block:^(NSString *inpath, NSString *outpath) {
        id value = [parser objectWithData:slurpd(inpath)];
        STAssertNotNil(value, parser.error);
        
        NSString *output = [writer stringWithObject:value];
        STAssertNotNil(output, writer.error);
        STAssertEqualObjects(output, chomp(slurp(outpath)), nil);
    }];
    
    STAssertEquals(count, (NSUInteger)3, nil);
}

@end