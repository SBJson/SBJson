//
//  Examples.m
//  JSON
//
//  Created by Stig Brautaset on 13/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import "Tests.h"


@implementation Examples

- (id)objFromFileNamed:(NSString *)name
{
    id path = [NSString stringWithFormat:@"Tests/Examples/%@", name];
    id json = [NSString stringWithContentsOfFile:path
                                      encoding:NSASCIIStringEncoding
                                         error:nil];
    STAssertNotNil(json, @"Failed loading example from file");
    return [json objectFromJSON];
}

- (void)testRFC4627Example1
{
    id o = [self objFromFileNamed:@"rfc4627ex1.json"];
    STAssertTrue([o isKindOfClass:[NSDictionary class]], @"Expected dictionary");
    STAssertEquals([o count], (unsigned)1, @"Expected 1 top-level key");
    eq([[o valueForKeyPath:@"Image.Width"] intValue], (int)800);
    eqo([o valueForKeyPath:@"Image.Thumbnail.Url"], @"http://www.example.com/image/481989943");
    eqo([o valueForKeyPath:@"Image.Thumbnail.Width"], @"100");
}

- (void)testRFC4627Example2
{
    id o = [self objFromFileNamed:@"rfc4627ex2.json"];
    STAssertTrue([o isKindOfClass:[NSArray class]], @"Expected array");
    STAssertEquals([o count], (unsigned)2, @"Expected 2 elements");
    
    id d = [o objectAtIndex:1];
    eqo([d valueForKey:@"Longitude"], [NSNumber numberWithDouble:-122.026020]);
    
}

@end
