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

#import "StreamParserDelegate.h"


@implementation StreamParserDelegate

@synthesize string;

- (id)init {
	self = [super init];
	if (self) {
		string = [NSMutableString new];
	}
	return self;
}

- (void)dealloc {
	[string release];
	[super dealloc];
}

- (void)parserStartedObject:(SBJsonStreamParser*)parser {
	[string appendFormat:@"{%u ", parser.depth];
}

- (void)parser:(SBJsonStreamParser*)parser foundObjectKey:(NSString*)key {
	[string appendFormat:@"%@=", key];
}

- (void)parserEndedObject:(SBJsonStreamParser*)parser {
	[string appendFormat:@"%u} ", parser.depth];
}

- (void)parserStartedArray:(SBJsonStreamParser*)parser {
	[string appendFormat:@"(%u ", parser.depth];
}

- (void)parserEndedArray:(SBJsonStreamParser*)parser {
	[string appendFormat:@"%u) ", parser.depth];
}

- (void)parserFoundNull:(SBJsonStreamParser*)parser {
	[string appendString:@"nil "];
}

- (void)parser:(SBJsonStreamParser*)parser foundBoolean:(BOOL)x {
	[string appendString:x ? @"YES " : @"NO "];
}

- (void)parser:(SBJsonStreamParser*)parser foundInteger:(NSInteger)i {
	[string appendFormat:@"%d ", i];
}

- (void)parser:(SBJsonStreamParser*)parser foundDouble:(double)d {
	[string appendFormat:@"%g ", d];
}

- (void)parser:(SBJsonStreamParser*)parser foundString:(NSString*)s {
	[string appendFormat:@"'%@' ", s];
}


@end
