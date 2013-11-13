/*
 Copyright (c) 2010, Stig Brautaset.
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

   Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

   Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

   Neither the name of the the author nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>
#import "SBJsonStreamParser.h"

typedef void (^SBValueBlock)(id);
typedef void (^SBErrorHandlerBlock)(NSError*);
typedef id (^SBProcessBlock)(id, NSString*);


/**
 SBJsonStreamParserDelegate protocol adapter

 Rather than implementing the SBJsonStreamParserDelegate protocol yourself you will
 most likely find it much more convenient to use an instance of this class and
 pass it a block instead.

 The default behaviour is that your passed-in block is only called once the entire input is parsed.

 If you set supportManyDocuments to YES and your input contains multiple (whitespace limited)
 JSON documents your block will be called for each document:

     SBJsonStreamParserAdapter *adapter = [[SBJsonStreamParserAdapter alloc] initWithBlock:^(id v) {
        NSLog(@"Found: %@", @([v isKindOfClass:[NSArray class]]));
     }
     errorHandler: ^(NSError* err) {
        NSLog(@"OOPS: %@", err);
     }];

     adapter.supportManyDocuments = YES;

     SBJsonStreamParser *parser = [[SBJsonStreamParser alloc] init];
     parser.delegate = adapter;

     // Note that this input contains multiple top-level JSON documents
     NSData *json = [@"[]{}[]{}" dataWithEncoding:NSUTF8StringEncoding];
     [parser parse:data];

 The above example will print:

 - Found: YES
 - Found: NO
 - Found: YES
 - Found: NO

 Often you won't have control over the input you're parsing, so can't make use of
 this feature. But, all is not lost: if you are parsing a long array you can get the same effect by
 setting supportPartialDocuments to YES:

     SBJsonStreamParserAdapter *adapter = [[SBJsonStreamParserAdapter alloc] initWithBlock:^(id v) {
        NSLog(@"Found: %@", @([v isKindOfClass:[NSArray class]]));
     }
     errorHandler: ^(NSError* err) {
        NSLog(@"OOPS: %@", err);
     }];
     adapter.supportPartialDocuments = YES;

     SBJsonStreamParser *parser = [[SBJsonStreamParser alloc] init];
     parser.delegate = adapter;

     // Note that this input contains A SINGLE top-level document
     NSData *json = [@"[[],{},[],{}]" dataWithEncoding:NSUTF8StringEncoding];
     [parser parse:data];

*/
@interface SBJsonStreamParserAdapter : NSObject <SBJsonStreamParserDelegate>

- (id)initWithBlock:(SBValueBlock)block errorHandler:(SBErrorHandlerBlock)eh;
- (id)initWithBlock:(SBValueBlock)block processBlock:(SBProcessBlock)processBlock errorHandler:(SBErrorHandlerBlock)eh;

/**
 Expect multiple documents separated by whitespace

 Normally the -parse: method returns SBJsonStreamParserComplete when it's found a complete JSON document.
 Attempting to parse any more data at that point is considered an error. ("Garbage after JSON".)

 If you set this property to true the parser will never return SBJsonStreamParserComplete. Rather,
 once an object is completed it will expect another object to immediately follow, separated
 only by (optional) whitespace.

 If you set this to YES the -parser:found: delegate method will be called once for each document in your input.

 */
@property(nonatomic) BOOL supportManyDocuments;


/**
 Support partial documents.

 This is useful for parsing huge JSON documents, or documents coming in over a very slow link.

 If you set this to true the outer array will be ignored and -parser:found: is called once
 for each item in it.

*/
@property(nonatomic) BOOL supportPartialDocuments;

@end
