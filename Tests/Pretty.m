//
//  Pretty.m
//  JSON
//
//  Created by Stig Brautaset on 26/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import "Tests.h"

#define dict(k1,v1) [NSDictionary dictionaryWithObject:v1 forKey:k1]
#define dict2(k1,v1,k2,v2) [NSDictionary dictionaryWithObjectsAndKeys: v1, k1, v2, k2, nil]

#define num(num) [NSNumber numberWithInt:num]

@implementation Pretty

- (void)setUp
{
    simple = dict2( @"a", num(1), @"b", num(2) );
    nested = dict2(
                @"a", dict2( @"x", num(1), @"xx", num(11)),
                @"b", dict2( @"y", num(2), @"yy", num(22))
    );

    simplea = [NSArray arrayWithObjects: @"testing", num(1), num(2), num(3), nil];
    nesteda = [NSArray arrayWithObjects: num(1), [NSArray arrayWithObjects:num(11), num(22), nil], nil];
}

- (void)testFalseArgs
{
    NSString *ss = @"{\"a\":1,\"b\":2}";
    NSString *sn = @"{\"a\":{\"x\":1,\"xx\":11},\"b\":{\"y\":2,\"yy\":22}}";
    NSArray *opts = [@"SpaceBefore SpaceAfter Indent Pretty" componentsSeparatedByString:@" "];
    for (int i = 0; i < [opts count]; i++) {
        NSDictionary *args = dict([opts objectAtIndex:i], num(0));
        eqo([simple JSONRepresentationWithOptions:args], ss);
        eqo([nested JSONRepresentationWithOptions:args], sn);
        
        eqo([simplea JSONRepresentationWithOptions:args], @"[\"testing\",1,2,3]");
        eqo([nesteda JSONRepresentationWithOptions:args], @"[1,[11,22]]");
    }
}

- (void)testSpaceBefore
{
    id args = dict(@"SpaceBefore", num(1));
    eqo([simple JSONRepresentationWithOptions:args], @"{\"a\" :1,\"b\" :2}");
    eqo([nested JSONRepresentationWithOptions:args],
        @"{\"a\" :{\"x\" :1,\"xx\" :11},\"b\" :{\"y\" :2,\"yy\" :22}}");

    eqo([simplea JSONRepresentationWithOptions:args], @"[\"testing\",1,2,3]");
    eqo([nesteda JSONRepresentationWithOptions:args], @"[1,[11,22]]");
}

- (void)testSpaceAfter
{
    id args = dict(@"SpaceAfter", num(1));
    eqo([simple JSONRepresentationWithOptions:args], @"{\"a\": 1, \"b\": 2}");
    eqo([nested JSONRepresentationWithOptions:args],
        @"{\"a\": {\"x\": 1, \"xx\": 11}, \"b\": {\"y\": 2, \"yy\": 22}}");

    eqo([simplea JSONRepresentationWithOptions:args], @"[\"testing\", 1, 2, 3]");
    eqo([nesteda JSONRepresentationWithOptions:args], @"[1, [11, 22]]");
}

- (void)testIndent
{
    id args = dict(@"Indent", num(1));
    eqo([simple JSONRepresentationWithOptions:args], @"{\n  \"a\":1,\n  \"b\":2\n}");
    eqo([nested JSONRepresentationWithOptions:args],
        @"{\n  \"a\":{\n    \"x\":1,\n    \"xx\":11\n  },\n  \"b\":{\n    \"y\":2,\n    \"yy\":22\n  }\n}");

    eqo([simplea JSONRepresentationWithOptions:args], @"[\n  \"testing\",\n  1,\n  2,\n  3\n]");
    eqo([nesteda JSONRepresentationWithOptions:args], @"[\n  1,\n  [\n    11,\n    22\n  ]\n]");
}

- (void)testPretty
{
    id args = dict(@"Pretty", num(1));
    eqo([simple JSONRepresentationWithOptions:args], @"{\n  \"a\" : 1,\n  \"b\" : 2\n}");
    eqo([nested JSONRepresentationWithOptions:args],
        @"{\n  \"a\" : {\n    \"x\" : 1,\n    \"xx\" : 11\n  },\n  \"b\" : {\n    \"y\" : 2,\n    \"yy\" : 22\n  }\n}");

    eqo([simplea JSONRepresentationWithOptions:args], @"[\n  \"testing\",\n  1,\n  2,\n  3\n]");
    eqo([nesteda JSONRepresentationWithOptions:args], @"[\n  1,\n  [\n    11,\n    22\n  ]\n]");
}


@end
