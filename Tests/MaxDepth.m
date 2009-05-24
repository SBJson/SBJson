//
//  MaxDepth.m
//  JSON
//
//  Created by Stig Brautaset on 24/05/2009.
//  Copyright 2009 Morgan Stanley. All rights reserved.
//

#import "MaxDepth.h"
#import "JSON/JSON.h"

@implementation MaxDepth

- (void)setUp {
    json = [SBJSON new];
    json.maxDepth = 2;
}

- (void)testParseDepthOk {
    STAssertNotNil([json objectWithString:@"[[]]"], nil);
}

- (void)testParseTooDeep {
    STAssertNil([json objectWithString:@"[[[]]]"], nil);
    STAssertEquals([[json.errorTrace objectAtIndex:0] code], (NSInteger)EDEPTH, nil);
}

- (void)testWriteDepthOk {
    NSArray *a1 = [NSArray array];
    NSArray *a2 = [NSArray arrayWithObject:a1];
    STAssertNotNil([json stringWithObject:a2], nil);
}

- (void)testWriteTooDeep {
    NSArray *a1 = [NSArray array];
    NSArray *a2 = [NSArray arrayWithObject:a1];
    NSArray *a3 = [NSArray arrayWithObject:a2];
    STAssertNil([json stringWithObject:a3], nil);
    STAssertEquals([[json.errorTrace objectAtIndex:0] code], (NSInteger)EDEPTH, nil);
}

- (void)testWriteRecursion {
    // set a high limit
    json.maxDepth = 100;
    
    // create a challenge!
    NSMutableArray *a1 = [NSMutableArray array];
    NSMutableArray *a2 = [NSMutableArray arrayWithObject:a1];
    [a1 addObject:a2];

    STAssertNil([json stringWithObject:a1], nil);
    STAssertEquals([[json.errorTrace objectAtIndex:0] code], (NSInteger)EDEPTH, nil);
}

@end
