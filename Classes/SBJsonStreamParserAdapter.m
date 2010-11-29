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

#import "SBJsonStreamParserAdapter.h"

@interface SBJsonStreamParserAdapter ()

- (void)pop;

@end



@implementation SBJsonStreamParserAdapter

@synthesize delegate;

#pragma mark Housekeeping

- (id)init {
	self = [super init];
	if (self) {
		keyStack = [NSMutableArray new];
		stack = [NSMutableArray new];
		
		type = None;
	}
	return self;
}	

- (void)dealloc {
	[top release];
	[key release];
	[keyStack release];
	[stack release];
	[array release];
	[dict release];
	[super dealloc];
}

#pragma mark Private methods

- (void)pop {
	[stack removeLastObject];
	array = nil;
	dict = nil;
	type = None;
	
	id value = [stack lastObject];
	
	if ([value isKindOfClass:[NSArray class]]) {
		array = (NSMutableArray*)value;
		type = Array;
	} else if ([value isKindOfClass:[NSDictionary class]]) {
		dict = (NSMutableDictionary*)value;
		type = Dict;
	}
}
	

#pragma mark Delegate methods

- (void)parserStartedObject:(SBJsonStreamParser*)parser {}

- (void)parser:(SBJsonStreamParser*)parser foundObjectKey:(NSString*)key {}

- (void)parserEndedObject:(SBJsonStreamParser*)parser {}

- (void)parserStartedArray:(SBJsonStreamParser*)parser {
	NSMutableArray *arr = [NSMutableArray new];
	if (!top)
		top = [arr retain];
	[stack addObject:arr];
	[arr release];
	array = arr;
	type = Array;
}

- (void)parserEndedArray:(SBJsonStreamParser*)parser {
	id value = [[stack lastObject] retain];
	NSArray *arr = array;
	[self pop];
	[delegate parser:parser foundArray:value];
	[value release];
}

- (void)parser:(SBJsonStreamParser*)parser foundBoolean:(BOOL)x {}

- (void)parserFoundNull:(SBJsonStreamParser*)parser {}

- (void)parser:(SBJsonStreamParser*)parser foundInteger:(NSInteger)num {}

- (void)parser:(SBJsonStreamParser*)parser foundDouble:(double)num {}

- (void)parser:(SBJsonStreamParser*)parser foundString:(NSString*)string {}

@end
