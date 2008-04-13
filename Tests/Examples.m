//
//  Examples.m
//  JSON
//
//  Created by Stig Brautaset on 13/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

// The rfc4627a and rfc4627b are examples are from RFC4627, the JSON RFC.
//
// The other examples are from http://www.json.org/example.html .

#import "Tests.h"

#define verifyExample(x) \
    do {\
        id expected = [self plistExample:x]; \
        eqo([self jsonExample:x], expected); \
        eqo([[expected JSONRepresentation] JSONValue], expected); \
    } while (0)

@implementation Examples

- (NSString *)exampleFromFile:(NSString *)name
{
    id path = [@"Tests/Examples" stringByAppendingPathComponent:name];
    id string = [NSString stringWithContentsOfFile:path 
                                          encoding:NSASCIIStringEncoding
                                             error:nil];
    STAssertNotNil(string, @"Failed loading string from file: %@", path);
    return string;
}

- (id)plistExample:(NSString *)path
{
    return [[self exampleFromFile: [path stringByAppendingString:@".plist"]] propertyList];
}

- (id)jsonExample:(NSString *)path
{
    return [[self exampleFromFile: [path stringByAppendingString:@".json"]] JSONValue];
}

- (void)testRFC4627a
{
    verifyExample(@"rfc4627a");
}

- (void)testRFC4627b
{
    verifyExample(@"rfc4627b");
}

- (void)testExample1
{
    verifyExample(@"ex1");
}

- (void)testExample2
{
    verifyExample(@"ex2");
}

- (void)testExample3
{
    verifyExample(@"ex3");
}

- (void)testExample4
{
    verifyExample(@"ex4");
}

- (void)testExample5
{
    // The fifth example on json.org/example.html cannot be
    // represented as a property list. Or something. I believe the
    // embedded nulls are the culprits.
    STAssertNotNil([self jsonExample:@"ex5"], nil);
}

- (void)testJSONCheckerFail
{
    id opts = [NSDictionary dictionaryWithObject:@"19" forKey:@"MaxDepth"];
    id o;
    for (int i = 1; i < 34; i++) {
        NSString *name = [NSString stringWithFormat:@"JSONChecker/fail%u.json", i];
        NSString *json = [self exampleFromFile:name];
        STAssertThrows(o = [json JSONValueWithOptions:opts], @"test %@ (%@) returned: %@", name, json, o);
    }
}

- (void)testJSONCheckerPass
{
    for (int i = 1; i < 4; i++) {
        NSString *name = [NSString stringWithFormat:@"JSONChecker/pass%u.json", i];
        NSString *json = [self exampleFromFile:name];
        STAssertNotNil([json JSONValue], @"test %@ (%@) passed ", name, json);
    }
}

@end
