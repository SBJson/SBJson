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

typedef void (^SBItemBlock)(id, BOOL*);
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

 The default behaviour is that your passed-in block is only called once the
 entire input is parsed. If you set supportManyDocuments to YES and your input
 contains multiple (whitespace limited) JSON documents your block will be called
 for each document:

    SBItemBlock block = ^(id v, BOOL *stop) {
        NSLog(@"Found: %@", @([v isKindOfClass:[NSArray class]]));
    };
    SBErrorHandlerBlock eh = ^(NSError* err) {
        NSLog(@"OOPS: %@", err);
     }

     id parser = [SBJsonParser parserWithBlock:block
                                 manyDocuments:YES
                                rootArrayItems:NO
                                  errorHandler:eh];

     // Note that this input contains multiple top-level JSON documents
     NSData *json = [@"[]{}[]{}" dataWithEncoding:NSUTF8StringEncoding];
     [parser parse:data];

 The above example will print:

 - Found: YES
 - Found: NO
 - Found: YES
 - Found: NO

 Often you won't have control over the input you're parsing, so can't make use
 of this feature. But, all is not lost: if you are parsing a long array you can
 get the same effect by setting  rootArrayItems to YES:

     id parser = [SBJsonParser parserWithBlock:block
                                 manyDocuments:NO
                                rootArrayItems:YES
                                  errorHandler:eh];

     // Note that this input contains A SINGLE top-level document
     NSData *json = [@"[[],{},[],{}]" dataWithEncoding:NSUTF8StringEncoding];
     [parser parse:data];

 @note Stream based parsing does mean that you lose some of the correctness
 verification you would have with a parser that considered the entire input
 before returning an answer. It is technically possible to have some parts
 of a document returned *as if they were correct* but then encounter an error
 in a later part of the document. You should keep this in mind when
 considering whether it would suit your application.


*/
@interface SBJsonParser : NSObject

/**
 Create a JSON Parser.

 @param block Called for each element. Set *stop to `YES` if you have seen
 enough and would like to skip the rest of the elements.

 @param allowMultiRoot Indicate that you are expecting multiple whitespace-separated
 JSON documents, similar to what Twitter uses.

 @param unwrapRootArray If set the parser will pretend an root array does not exist
 and the enumerator block will be called once for each item in it. This option
 does nothing if the the JSON has an object at its root.

 @param eh Called if the parser encounters an error.

 */
+ (id)parserWithBlock:(SBItemBlock)block
       allowMultiRoot:(BOOL)allowMultiRoot
      unwrapRootArray:(BOOL)unwrapRootArray
         errorHandler:(SBErrorHandlerBlock)eh;


+ (id)multiRootParserWithBlock:(SBItemBlock)block
                  errorHandler:(SBErrorHandlerBlock)eh;

+ (id)unwrapRootArrayParserWithBlock:(SBItemBlock)block
                        errorHandler:(SBErrorHandlerBlock)eh;

/**
 Create a JSON Parser.

 @param block Called for each element. Set *stop to `YES` if you have seen
 enough and would like to skip the rest of the elements.

 @param processBlock A block that allows you to process individual values before being
 returned.

 @param manyDocs Indicate that you are expecting multiple whitespace-separated
 JSON documents, similar to what Twitter uses.

 @param rootArrayItems If set the parser will pretend an root array does not exist
 and the enumerator block will be called once for each item in it. This option
 does nothing if the the JSON has an object at its root.

 @param maxDepth The max recursion depth of the parser. Defaults to 32.

 @param eh Called if the parser encounters an error.

 */
- (id)initWithBlock:(SBItemBlock)block
       processBlock:(SBProcessBlock)processBlock
      manyDocuments:(BOOL)manyDocs
     rootArrayItems:(BOOL)rootArrayItems
           maxDepth:(NSUInteger)maxDepth
       errorHandler:(SBErrorHandlerBlock)eh;

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
