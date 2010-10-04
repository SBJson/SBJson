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

#import "SBJsonStreamWriter.h"
#import "SBJsonEventStreamWriter.h"
#import "SBProxyForJson.h"

@interface SBJsonStreamWriter ()

- (void)writeValue:(id)value;
- (void)writeDictionary:(NSDictionary*)dict;
- (void)writeArray:(NSArray*)array;

@end

@implementation SBJsonStreamWriter

@synthesize sortKeys;
@synthesize humanReadable;

#pragma mark Housekeeping

- (id)initWithStream:(NSOutputStream*)stream_ {
	self = [super init];
	if (self) {
		writer = [[SBJsonEventStreamWriter alloc] initWithStream:stream_];
		if (!writer) {
			[self release];
			return nil;
		}
	}
	return self;
}

- (void)dealloc {
	[writer release];
	[super dealloc];
}

#pragma mark Methods

- (void)write:(id)object {
	if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]]) {
		depth = 0;
		[self writeValue:object];
		return;
	}
	
	if ([object respondsToSelector:@selector(proxyForJson)]) {
		[self write:[object proxyForJson]];
		return;
	}
	
	@throw @"Not valid type for JSON";
}

- (void)writeValue:(id)o {
	if ([o isKindOfClass:[NSDictionary class]]) {
		[self writeDictionary:o];

	} else if ([o isKindOfClass:[NSArray class]]) {
		[self writeArray:o];

	} else if ([o isKindOfClass:[NSString class]]) {
		[writer writeString:o];

	} else if ([o isKindOfClass:[NSNumber class]]) {
		[writer writeNumber:o];

	} else if ([o isKindOfClass:[NSNull class]]) {
		[writer writeNull];

	} else if ([o respondsToSelector:@selector(proxyForJson)]) {
		[self writeValue:[o proxyForJson]];

	} else {
		@throw [NSString stringWithFormat:@"JSON serialisation not supported for @%", [o class]];
	}
}

- (void)writeDictionary:(NSDictionary*)dict {
	if (maxDepth && ++depth > maxDepth)
		@throw @"Nested too deep";
		
	[writer writeDictionaryStart];
	
	NSArray *keys = [dict allKeys];
	if (self.sortKeys)
		keys = [keys sortedArrayUsingSelector:@selector(compare:)];
	
	BOOL doSep = NO;
	for (id key in keys) {
		if (doSep)
			[writer writeElementSeparator];
		else
			doSep = YES;

		if (humanReadable) {
			[writer writeNewline];
			[writer writeSpaces:2 * depth];
		}
		
		if (![key isKindOfClass:[NSString class]])
			@throw @"JSON object key must be string";
		
		[writer writeDictionaryKey:key];
		[self writeValue:[dict objectForKey:key]];
	}
	
	depth--;

	if (humanReadable && [dict count]) {
		[writer writeNewline];
		[writer writeSpaces:2 * depth];
	}
	[writer writeDictionaryEnd];
	
}

- (void)writeArray:(NSArray*)array {
	if (maxDepth && ++depth > maxDepth)
		@throw @"Nested too deep";

	[writer writeArrayStart];

	BOOL doSep = NO;
	for (id value in array) {
		if (doSep)
			[writer writeElementSeparator];
		else
			doSep = YES;

		if (humanReadable) {
			[writer writeNewline];
			[writer writeSpaces:2 * depth];
		}
		
		[self writeValue:value];
	}
	
	depth--;
	
	if (humanReadable && [array count]) {
		[writer writeNewline];
		[writer writeSpaces:2 * depth];
	}
	
	[writer writeArrayEnd];
}

@end
