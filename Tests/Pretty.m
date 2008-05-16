//
//  Pretty.m
//  JSON
//
//  Created by Stig Brautaset on 26/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import "Tests.h"

@implementation Pretty

- (void)setUp {
    NSString *input = [NSString stringWithContentsOfFile:@"Tests/format/input.json"
                                                encoding:NSASCIIStringEncoding
                                                   error:nil];
    json = [input JSONValue];
}

- (void)testFormatting {
    NSArray *formats = [@"HumanReadable MultiLine Pretty" componentsSeparatedByString:@" "];
    id fmt, fmtenum = [formats objectEnumerator];
    
    while (fmt = [fmtenum nextObject]) {
        NSDictionary *args = [NSDictionary dictionaryWithObject:@"1" forKey:fmt];
        NSString *got = [json JSONRepresentationWithOptions:args];

        NSString *file = [NSString stringWithFormat:@"Tests/format/HumanReadable.json", fmt];
        NSString *expected = [NSString stringWithContentsOfFile:file
                                                       encoding:NSASCIIStringEncoding
                                                          error:nil];

        // chop off the newline
        expected = [expected substringToIndex:[expected length]-1];

        STAssertEqualObjects(got, expected, fmt);
    }
}

@end
