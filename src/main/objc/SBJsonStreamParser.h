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

@class SBJsonStreamParser;
@class SBJsonStreamParserState;

typedef enum {
	SBJsonStreamParserComplete,
	SBJsonStreamParserWaitingForData,
	SBJsonStreamParserError,
} SBJsonStreamParserStatus;


/**
 Delegate for interacting directly with the stream parser

 You will most likely find it much more convenient to implement the
 SBJsonStreamParserAdapterDelegate protocol instead.
 */
@protocol SBJsonStreamParserDelegate < NSObject >

/// Called when object start is found
- (void)parserFoundObjectStart:(SBJsonStreamParser*)parser;

/// Called when object key is found
- (void)parser:(SBJsonStreamParser*)parser foundObjectKey:(NSString*)key;

/// Called when object end is found
- (void)parserFoundObjectEnd:(SBJsonStreamParser*)parser;

/// Called when array start is found
- (void)parserFoundArrayStart:(SBJsonStreamParser*)parser;

/// Called when array end is found
- (void)parserFoundArrayEnd:(SBJsonStreamParser*)parser;

/// Called when a boolean value is found
- (void)parser:(SBJsonStreamParser*)parser foundBoolean:(BOOL)x;

/// Called when a null value is found
- (void)parserFoundNull:(SBJsonStreamParser*)parser;

/// Called when a number is found
- (void)parser:(SBJsonStreamParser*)parser foundNumber:(NSNumber*)num;

/// Called when a string is found
- (void)parser:(SBJsonStreamParser*)parser foundString:(NSString*)string;

/// Called when an error occurs
- (void)parser:(SBJsonStreamParser*)parser foundError:(NSError*)err;

@optional

/// Called to determine whether to allow multiple whitespace-separated documents
- (BOOL)parserShouldSupportManyDocuments:(SBJsonStreamParser*)parser;

@end


/**
 Parse a stream of JSON data.

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

 See also SBJsonStreamParserAdapter for more information.

 */
@interface SBJsonStreamParser : NSObject

@property (nonatomic, weak) SBJsonStreamParserState *state; // Private
@property (nonatomic, readonly, strong) NSMutableArray *stateStack; // Private

/**
 Delegate to receive messages

 The object set here receives a series of messages as the parser breaks down the JSON stream
 into valid tokens.

 Usually this should be an instance of SBJsonStreamParserAdapter, but you can
 substitute your own implementation of the SBJsonStreamParserDelegate protocol if you need to.
 */
@property (nonatomic, weak) id<SBJsonStreamParserDelegate> delegate;

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
 - SBJsonStreamParserComplete if a full document was found
 - SBJsonStreamParserWaitingForData if a partial document was found and more data is required to complete it
 - SBJsonStreamParserError if an error occured.

 */
- (SBJsonStreamParserStatus)parse:(NSData*)data;

@end
