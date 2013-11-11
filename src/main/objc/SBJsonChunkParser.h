/*
 Copyright (c) 2010-2013, Stig Brautaset.
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
 Parse one or more chunks of JSON data.

 Using this class directly you can reduce the apparent latency for each
 download/parse cycle of documents over a slow connection. You can start
 parsing *and return chunks of the parsed document* before the entire
 document is downloaded.

 Using this class is also useful to parse huge documents on disk
 bit by bit so you don't have to keep them all in memory.

 JSON is mapped to Objective-C types in the following way:

 - null    -> NSNull
 - string  -> NSString
 - array   -> NSMutableArray
 - object  -> NSMutableDictionary
 - true    -> NSNumber's -numberWithBool:YES
 - false   -> NSNumber's -numberWithBool:NO
 - number -> NSNumber

 Since Objective-C doesn't have a dedicated class for boolean values,
 these turns into NSNumber instances. However, since these are
 initialised with the -initWithBool: method they round-trip back to JSON
 properly. In other words, they won't silently suddenly become 0 or 1;
 they'll be represented as 'true' and 'false' again.

 Integers are parsed into either a `long long` or `unsigned long long`
 type if they fit, else a `double` is used. All real & exponential numbers
 are represented using a `double`. Previous versions of this library used
 an NSDecimalNumber in some cases, but this is no longer the case.

 The default behaviour is that your passed-in block is only called once the entire input is parsed.
 If you set supportManyDocuments to YES and your input contains multiple (whitespace limited)
 JSON documents your block will be called for each document:

     SBJsonChunkParser *parser = [[SBJsonChunkParser alloc] initWithBlock:^(id v) {
        NSLog(@"Found: %@", @([v isKindOfClass:[NSArray class]]));
     } errorHandler: ^(NSError* err) {
        NSLog(@"OOPS: %@", err);
     }];

     parser.supportManyDocuments = YES;

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

     SBJsonChunkParser *parser = [[SBJsonChunkParser alloc] initWithBlock:^(id v) {
        NSLog(@"Found: %@", @([v isKindOfClass:[NSArray class]]));
     } errorHandler: ^(NSError* err) {
        NSLog(@"OOPS: %@", err);
     }];
     parser.supportPartialDocuments = YES;

     // Note that this input contains A SINGLE top-level document
     NSData *json = [@"[[],{},[],{}]" dataWithEncoding:NSUTF8StringEncoding];
     [parser parse:data];

*/
@interface SBJsonChunkParser : NSObject

- (id)initWithBlock:(SBValueBlock)block errorHandler:(SBErrorHandlerBlock)eh;
- (id)initWithBlock:(SBValueBlock)block processBlock:(SBProcessBlock)processBlock errorHandler:(SBErrorHandlerBlock)eh;

/**
 Expect multiple documents separated by whitespace

 Normally the -parse: method returns SBJsonParserComplete when it's found a complete JSON document.
 Attempting to parse any more data at that point is considered an error. ("Garbage after JSON".)

 If you set this property to true the parser will never return SBJsonParserComplete. Rather,
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

/**
 The max parse depth

 If the input is nested deeper than this the parser will halt parsing and return an error.

 Defaults to 32.
 */
@property(nonatomic) NSUInteger maxDepth;

/**
 Parse some JSON

 The JSON is assumed to be UTF8 encoded. This can be a full JSON document, or a part of one.

 @param data An NSData object containing the next chunk of JSON

 @return
 - SBJsonParserComplete if a full document was found
 - SBJsonParserWaitingForData if a partial document was found and more data is required to complete it
 - SBJsonParserError if an error occured.

 */
- (SBJsonParserStatus)parse:(NSData*)data;

@end
