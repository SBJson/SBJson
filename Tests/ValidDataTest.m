//
//  ValidTest.m
//  JSON
//
//  Created by Stig Brautaset on 02/05/2011.
//  Copyright 2011 Stig Brautaset. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <JSON/JSON.h>

@interface ValidDataTest : SenTestCase {
@private
    NSUInteger count;
    SBJsonParser * parser;
    SBJsonWriter * writer;
}

@end

@implementation ValidDataTest

- (void)setUp {
    count = 0;
    parser = [[SBJsonParser alloc] init];
    writer = [[SBJsonWriter alloc] init];
}

- (void)tearDown {
    [parser release];
    [writer release];
}

- (void)foreachFilePrefixedBy:(NSString*)prefix inSuite:(NSString*)suite apply:(void(^)(NSString*))block {
    NSString *file;
    NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:suite];
    while ((file = [enumerator nextObject])) {
        if (![file hasPrefix:prefix])
            continue;
        
        NSString *path = [suite stringByAppendingPathComponent:file];        
        if ([[NSFileManager defaultManager] isReadableFileAtPath:path]) {
            block(path);
            count++;
        }
    }
}

- (void)foreachTestInSuite:(NSString*)suite apply:(void(^)(NSString*, NSString*))block {
    NSString *file;
    NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:suite];
    while ((file = [enumerator nextObject])) {
        NSString *path = [suite stringByAppendingPathComponent:file];
        NSString *inpath = [path stringByAppendingPathComponent:@"input"];
        
        if ([[NSFileManager defaultManager] isReadableFileAtPath:inpath]) {
            NSString *outpath = [path stringByAppendingPathComponent:@"output"];
            STAssertTrue([[NSFileManager defaultManager] isReadableFileAtPath:outpath], nil);
            block(inpath, outpath);
            count++;
        }
    }
}

- (void)testJsonCheckerPass {
    [self foreachFilePrefixedBy:@"pass" inSuite:@"Tests/Data/jsonchecker" apply:^(NSString* path) {
        NSError *error = nil;
        NSString *input = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        STAssertNotNil(input, @"%@ - %@", path, error);
        
        id object = [parser objectWithString:input];
        STAssertNotNil(object, path);
        STAssertNil(parser.error, path);
        
    }];
    STAssertEquals(count, (NSUInteger)3, nil);
}


- (void)testJsonCheckerFail {
    parser.maxDepth = 19;
    
    [self foreachFilePrefixedBy:@"fail" inSuite:@"Tests/Data/jsonchecker" apply:^(NSString* path) {
        NSError *error = nil;
        NSString *input = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        STAssertNotNil(input, @"%@ - %@", path, error);
        
        STAssertNil([parser objectWithString:input], @"%@ - %@", input, path);
        STAssertNotNil(parser.error, path);
    }];
    
    STAssertEquals(count, (NSUInteger)33, nil);
}

- (void)testPrettyString {
    writer.humanReadable = YES;
    writer.sortKeys = YES;
    
    [self foreachTestInSuite:@"Tests/Data/format" apply:^(NSString *inpath, NSString *outpath) {
        NSError *error = nil;
        NSString *input = [NSString stringWithContentsOfFile:inpath encoding:NSUTF8StringEncoding error:&error];
        STAssertNotNil(input, @"%@ - %@", inpath, error);
        
        NSString *output = [NSString stringWithContentsOfFile:outpath encoding:NSUTF8StringEncoding error:&error];
        STAssertNotNil(output, @"%@ - %@", outpath, error);
        
        id object = [parser objectWithString:input];
        STAssertNotNil(object, nil);
        
        NSString *json = [writer stringWithObject:object];
        STAssertNotNil(json, nil);
        
        json = [json stringByAppendingString:@"\n"];
        STAssertEqualObjects(json, output, nil);
    }];
    
    STAssertEquals(count, (NSUInteger)8, nil);
}

- (void)testPrettyData {
    writer.humanReadable = YES;
    writer.sortKeys = YES;
    
    [self foreachTestInSuite:@"Tests/Data/format" apply:^(NSString *inpath, NSString *outpath) {
        NSError *error = nil;
        NSData *input = [NSData dataWithContentsOfFile:inpath];
        STAssertNotNil(input, @"%@ - %@", inpath, error);
        
        id object = [parser objectWithData:input];
        STAssertNotNil(object, nil);
        
        NSData *json = [writer dataWithObject:object];
        STAssertNotNil(json, nil);
        
        NSData *output = [NSData dataWithContentsOfFile:outpath];
        STAssertNotNil(output, @"%@ - %@", outpath, error);
        
        output = [NSData dataWithBytes:output.bytes length:output.length-1];
        STAssertEqualObjects(json, output, nil);
    }];
    
    STAssertEquals(count, (NSUInteger)8, nil);
}


- (void)testString {
    [self foreachTestInSuite:@"Tests/Data/valid" apply:^(NSString *inpath, NSString *outpath) {
        NSError *error = nil;
        NSString *input = [NSString stringWithContentsOfFile:inpath encoding:NSUTF8StringEncoding error:&error];
        STAssertNotNil(input, @"%@ - %@", inpath, error);
        
        NSString *output = [NSString stringWithContentsOfFile:outpath encoding:NSUTF8StringEncoding error:&error];
        STAssertNotNil(output, @"%@ - %@", outpath, error);
        
        id object = [parser objectWithString:input];
        STAssertNotNil(object, nil);
        
        NSString *json = [writer stringWithObject:object];
        STAssertNotNil(json, nil);

        json = [json stringByAppendingString:@"\n"];
        STAssertEqualObjects(json, output, nil);
    }];
    
    STAssertEquals(count, (NSUInteger)14, nil);
}


- (void)testData {
    [self foreachTestInSuite:@"Tests/Data/valid" apply:^(NSString *inpath, NSString *outpath) {
        NSError *error = nil;
        NSData *input = [NSData dataWithContentsOfFile:inpath];
        STAssertNotNil(input, @"%@ - %@", inpath, error);

        id object = [parser objectWithData:input];
        STAssertNotNil(object, nil);
        
        NSData *json = [writer dataWithObject:object];
        STAssertNotNil(json, nil);
        
        NSData *output = [NSData dataWithContentsOfFile:outpath];
        STAssertNotNil(output, @"%@ - %@", outpath, error);

        output = [NSData dataWithBytes:output.bytes length:output.length-1];
        STAssertEqualObjects(json, output, nil);
    }];
    
    STAssertEquals(count, (NSUInteger)14, nil);
}


- (void)testCategory {
    [self foreachTestInSuite:@"Tests/Data/valid" apply:^(NSString *inpath, NSString *outpath) {
        NSError *error = nil;
        NSString *input = [NSString stringWithContentsOfFile:inpath encoding:NSUTF8StringEncoding error:&error];
        STAssertNotNil(input, @"%@ - %@", inpath, error);
        
        NSString *output = [NSString stringWithContentsOfFile:outpath encoding:NSUTF8StringEncoding error:&error];
        STAssertNotNil(output, @"%@ - %@", outpath, error);
        
        id object = [input JSONValue];
        STAssertNotNil(object, nil);
        
        NSString *json = [object JSONRepresentation];
        STAssertNotNil(json, nil);
        
        json = [json stringByAppendingString:@"\n"];
        STAssertEqualObjects(json, output, nil);
    }];
    
    STAssertEquals(count, (NSUInteger)14, nil);
}

@end
