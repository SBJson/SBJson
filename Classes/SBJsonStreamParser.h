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

@class SBJsonTokeniser;
@class SBJsonStreamParser;
@class SBJsonStreamParserState;

typedef enum {
	SBJsonStreamParserComplete,
	SBJsonStreamParserWaitingForData,
	SBJsonStreamParserError,
} SBJsonStreamParserStatus;


/**
 @brief SBJsonStreamParserDelegate protocol adapter
  
 @see SBJsonStreamParser
 */
@protocol SBJsonStreamParserDelegate

/**
 @brief Called if a JSON array is found
 
 This method is called if a JSON array is found.
 
 */
- (void)parser:(SBJsonStreamParser*)parser foundArray:(NSArray*)array;

/**
 @brief Called when a JSON object is found
 
 This method is called if a JSON object is found.
 */
- (void)parser:(SBJsonStreamParser*)parser foundObject:(NSDictionary*)dict;

@end

typedef enum {
	SBJsonStreamParserNone,
	SBJsonStreamParserArray,
	SBJsonStreamParserObject,
} SBJsonStreamParserType;

/**
 @brief Parse a stream of JSON data.
 
 Using this class directly you can reduce the apparent latency for each
 download/parse cycle of documents over a slow connection. You can start
 parsing *and return chunks of the parsed document* before the entire
 document is downloaded. Using this class is also useful to parse huge
 documents on disk bit by bit so you don't have to keep them all in memory. 

 The default behaviour is that the delegate only receives one call from
 either the -parser:foundArray: or -parser:foundObject: method when the
 document is fully parsed. However, if your inputs contains multiple JSON
 documents and you set the parser's -supportMultipleDocuments property to YES
 you will get one call for each full method.
 
 @code
 SBJsonStreamParser *parser = [[[SBJsonStreamParser alloc] init] autorelease];
 parser.delegate = self;
 parser.supportMultipleDocuments = YES;
 
 // Note that this input contains multiple top-level JSON documents
 NSData *json = [@"[]{}[]{}" dataWithEncoding:NSUTF8StringEncoding]; 
 [parser parse:data];
 @endcode
 
 In the above example @p self will have the following sequence of methods called on it:
 
 @li -parser:foundArray:
 @li -parser:foundObject:
 @li -parser:foundArray:
 @li -parser:foundObject:
 
 Often you won't have control over the input you're parsing, so can't make use of
 this feature. But, all is not lost: this class will let you get the same effect by 
 allowing you to skip one or more of the outer enclosing objects. Thus, the next
 example results in the same sequence of -parser:foundArray: / -parser:foundObject:
 being called on your delegate.
 
 @code
 SBJsonStreamParser *parser = [[[SBJsonStreamParser alloc] init] autorelease];
 parser.delegate = self;
 parser.levelsToSkip = 1;
 
 // Note that this input contains A SINGLE top-level document
 NSData *json = [@"[[],{},[],{}]" dataWithEncoding:NSUTF8StringEncoding]; 
 [parser parse:data];
 @endcode
 
 @see SBJsonStreamParserDelegate
 @see @ref objc2json
 
 */
@interface SBJsonStreamParser : NSObject {
@private
	SBJsonTokeniser *tokeniser;

	NSUInteger depth;
    NSMutableArray *array;
	NSMutableDictionary *dict;
	NSMutableArray *keyStack;
	NSMutableArray *stack;
	
	SBJsonStreamParserType currentType;
}

@property (nonatomic, assign) SBJsonStreamParserState *state; // Private
@property (nonatomic, readonly, retain) NSMutableArray *stateStack; // Private


/**
 @brief How many levels to skip
 
 This is useful for parsing huge JSON documents, or documents coming in over a very slow link.
 
 If you set this to N it will skip the outer N levels and call the -parser:foundArray:
 or -parser:foundObject: methods for each of the inner objects, as appropriate.
 
 @see The StreamParserIntegrationTest.m file for examples
 */
@property NSUInteger levelsToSkip;

/**
 @brief Expect multiple documents separated by whitespace

 Normally the @p -parse: method returns SBJsonStreamParserComplete when it's found a complete JSON document.
 Attempting to parse any more data at that point is considered an error. ("Garbage after JSON".)
 
 If you set this property to true the parser will never return SBJsonStreamParserComplete. Rather,
 once an object is completed it will expect another object to immediately follow, separated
 only by (optional) whitespace.

 @see The TweetStream app in the Examples
 */
@property BOOL supportMultipleDocuments;

/**
 @brief Delegate to receive messages

 The object set here receives a series of messages as the parser breaks down the JSON stream
 into valid tokens.

 @note
 Usually this should be an instance of SBJsonStreamParser, but you can
 substitute your own implementation of the SBJsonStreamParserDelegate protocol if you need to. 
 */
@property (assign) id<SBJsonStreamParserDelegate> delegate;

/**
 @brief The max parse depth
 
 If the input is nested deeper than this the parser will halt parsing and return an error.

 Defaults to 32. 
 */
@property NSUInteger maxDepth;

/// Holds the error after SBJsonStreamParserError was returned
@property (copy) NSString *error;

/**
 @brief Parse some JSON
 
 The JSON is assumed to be UTF8 encoded. This can be a full JSON document, or a part of one.

 @param data An NSData object containing the next chunk of JSON

 @return 
 @li SBJsonStreamParserComplete if a full document was found
 @li SBJsonStreamParserWaitingForData if a partial document was found and more data is required to complete it
 @li SBJsonStreamParserError if an error occured. (See the error property for details in this case.)
 
 */
- (SBJsonStreamParserStatus)parse:(NSData*)data;

@end
