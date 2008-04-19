//
//  Tests.h
//  JSON
//
//  Created by Stig Brautaset on 11/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <JSON/JSON.h>

#define eq(x, y)        STAssertEquals(x, y, nil)
#define eqo(x, y)       STAssertEqualObjects(x, y, nil)

@interface Types : SenTestCase
@end

@interface Errors : SenTestCase
@end

@interface Examples : SenTestCase
@end

@interface Pretty : SenTestCase {
    NSArray *json;
}
@end
