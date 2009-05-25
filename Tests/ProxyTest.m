//
//  Proxy.m
//  JSON
//
//  Created by Stig Brautaset on 25/05/2009.
//  Copyright 2009 Stig Brautaset. All rights reserved.
//

#import "ProxyTest.h"
#import "JSON.h"

@interface True : NSObject
@end

@implementation True
- (id)jsonRepresentationProxy {
    return [NSNumber numberWithBool:YES];
}
@end

@interface False : NSObject
@end

@implementation False
- (id)jsonRepresentationProxy {
    return [NSNumber numberWithBool:NO];
}
@end

@interface Bool : NSObject
@end

@implementation Bool
- (id)jsonRepresentationProxy {
    return [NSArray arrayWithObjects:[True new], [False new], nil];
}
@end

@implementation NSDate (Private)
- (id)jsonRepresentationProxy {
    return [self description];
}
@end



@implementation ProxyTest

- (void)setUp {
    writer = [SBJsonWriter new];
}

- (void)testUnsupportedWithoutProxy {
    STAssertNil([writer stringWithObject:[NSArray arrayWithObject:[NSObject new]]], nil);
    STAssertEquals([[writer.errorTrace objectAtIndex:0] code], (NSInteger)EUNSUPPORTED, nil);
}

- (void)testUnsupportedWithProxy {
    STAssertEqualObjects([writer stringWithObject:[NSArray arrayWithObject:[True new]]], @"[true]", nil);
}

- (void)testUnsupportedWithNestedProxy {
    STAssertEqualObjects([writer stringWithObject:[NSArray arrayWithObject:[Bool new]]], @"[[true,false]]", nil);
}

- (void)testUnsupportedWithProxyAsCategory {
    STAssertNotNil([writer stringWithObject:[NSArray arrayWithObject:[NSDate date]]], nil);
}

@end
