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

#if !__has_feature(objc_arc)
#error "This source file must be compiled with ARC enabled!"
#endif

#import "SBJsonChunkParser.h"

@interface SBJsonChunkParser () <SBJsonStreamParserDelegate>

- (void)pop;
- (void)parser:(SBJsonStreamParser *)parser found:(id)obj;

@end

typedef enum {
    SBJsonChunkNone,
    SBJsonChunkArray,
    SBJsonChunkObject,
} SBJsonChunkType;

@implementation SBJsonChunkParser {
    SBJsonStreamParser *_parser;
    NSUInteger depth;
    NSMutableArray *array;
    NSMutableDictionary *dict;
    NSMutableArray *keyStack;
    NSMutableArray *stack;
    NSMutableArray *path;
    SBProcessBlock processBlock;
    SBErrorHandlerBlock errorHandler;
    SBEnumeratorBlock valueBlock;
    SBJsonChunkType currentType;
}

#pragma mark Housekeeping

- (id)init {
    @throw @"Use -initWithBlock:errorHandler: instead";
}

- (id)initWithBlock:(SBEnumeratorBlock)block errorHandler:(SBErrorHandlerBlock)eh {
    return [self initWithBlock:block processBlock:nil errorHandler:eh];
}

- (id)initWithBlock:(SBEnumeratorBlock)block processBlock:(SBProcessBlock)initialProcessBlock errorHandler:(SBErrorHandlerBlock)eh {
	self = [super init];
	if (self) {
        _parser = [[SBJsonStreamParser alloc] init];
        _parser.delegate = self;

        valueBlock = block;
		keyStack = [[NSMutableArray alloc] initWithCapacity:32];
		stack = [[NSMutableArray alloc] initWithCapacity:32];
        if (initialProcessBlock)
            path = [[NSMutableArray alloc] initWithCapacity:32];
        processBlock = initialProcessBlock;
        errorHandler = eh ? eh : ^(NSError*err) { NSLog(@"%@", err); };
		currentType = SBJsonChunkNone;
	}
	return self;
}


#pragma mark Private methods

- (void)pop {
	[stack removeLastObject];
	array = nil;
	dict = nil;
	currentType = SBJsonChunkNone;
	
	id value = [stack lastObject];
	
	if ([value isKindOfClass:[NSArray class]]) {
		array = value;
		currentType = SBJsonChunkArray;
	} else if ([value isKindOfClass:[NSDictionary class]]) {
		dict = value;
		currentType = SBJsonChunkObject;
	}
}

- (void)parser:(SBJsonStreamParser *)parser found:(id)obj {
    [self parser:parser found:obj isValue:NO];
}

- (void)parser:(SBJsonStreamParser *)parser found:(id)obj isValue:(BOOL)isValue {
	NSParameterAssert(obj);
	
    if(processBlock&&path) {
        if(isValue) {
            obj = processBlock(obj,[NSString stringWithFormat:@"%@.%@",[self pathString],[keyStack lastObject]]);
        }
        else {
            [path removeLastObject];
        }
    }

	switch (currentType) {
		case SBJsonChunkArray:
			[array addObject:obj];
			break;

		case SBJsonChunkObject:
			NSParameterAssert(keyStack.count);
			[dict setObject:obj forKey:[keyStack lastObject]];
			[keyStack removeLastObject];
			break;

		case SBJsonChunkNone: {
            __block BOOL stop = NO;
            valueBlock(obj, &stop);
            if (stop) [_parser stop];
        }
			break;

		default:
			break;
	}
}


#pragma mark Delegate methods

- (void)parserFoundObjectStart:(SBJsonStreamParser *)parser {
    ++depth;
    if(path) [self addToPath];
    dict = [NSMutableDictionary new];
	[stack addObject:dict];
    currentType = SBJsonChunkObject;
}

- (void)parser:(SBJsonStreamParser *)parser foundObjectKey:(NSString*)key_ {
    [keyStack addObject:key_];
}

- (void)parserFoundObjectEnd:(SBJsonStreamParser *)parser {
    depth--;
	id value = dict;
	[self pop];
    [self parser:parser found:value];
}

- (void)parserFoundArrayStart:(SBJsonStreamParser *)parser {
    depth++;
    if (depth > 1 || !self.supportPartialDocuments) {
        if(path)
            [self addToPath];
		array = [NSMutableArray new];
		[stack addObject:array];
		currentType = SBJsonChunkArray;
    }
}

- (void)parserFoundArrayEnd:(SBJsonStreamParser *)parser {
    depth--;
    if (depth > 1 || !self.supportPartialDocuments) {
		id value = array;
		[self pop];
		[self parser:parser found:value];
    }
}

- (void)parser:(SBJsonStreamParser *)parser foundBoolean:(BOOL)x {
	[self parser:parser found:[NSNumber numberWithBool:x] isValue:YES];
}

- (void)parserFoundNull:(SBJsonStreamParser *)parser {
    [self parser:parser found:[NSNull null] isValue:YES];
}

- (void)parser:(SBJsonStreamParser *)parser foundNumber:(NSNumber*)num {
    [self parser:parser found:num isValue:YES];
}

- (void)parser:(SBJsonStreamParser *)parser foundString:(NSString*)string {
    [self parser:parser found:string isValue:YES];
}

- (void)parser:(SBJsonStreamParser *)parser foundError:(NSError *)err {
    errorHandler(err);
}

- (void)addToPath {
    if([path count]==0)
        [path addObject:@"$"];
    else if([[stack lastObject] isKindOfClass:[NSArray class]])
        [path addObject:@([[stack lastObject] count])];
    else
        [path addObject:[keyStack lastObject]];
}

- (NSString *)pathString {
    NSMutableString *pathString = [NSMutableString stringWithString:@"$"];
    for(NSUInteger i=1;i<[path count];i++) {
        if([[path objectAtIndex:i] isKindOfClass:[NSNumber class]])
            [pathString appendString:[NSString stringWithFormat:@"[%@]",[path objectAtIndex:i]]];
        else
            [pathString appendString:[NSString stringWithFormat:@".%@",[path objectAtIndex:i]]];
    }
    return pathString;
}

- (BOOL)parserShouldSupportManyDocuments:(SBJsonStreamParser *)parser {
    return self.supportManyDocuments;
}

- (SBJsonParserStatus)parse:(NSData *)data {
    return [_parser parse:data];
}

- (void)setMaxDepth:(NSUInteger)maxDepth {
    _parser.maxDepth = maxDepth;
}

- (NSUInteger)maxDepth {
    return _parser.maxDepth;
}


@end
