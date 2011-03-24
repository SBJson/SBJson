/*
 Copyright (C) 2009 Stig Brautaset. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
   to endorse or promote products derived from this software without specific
   prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSObject+JSON.h"
#import "SBJsonWriter.h"
#import "SBJsonParser.h"

@implementation NSObject (NSObject_SBJsonWriting)

- (NSString *)JSONRepresentation {
    SBJsonWriter *jsonWriter = [SBJsonWriter new];    
    NSString *json = [jsonWriter stringWithObject:self];
    if (!json)
        NSLog(@"-JSONRepresentation failed. Error is: %@", jsonWriter.error);
    [jsonWriter release];
    return json;
}

- (NSString *)JSONRepresentationSmallest {
	return [self JSONRepresentation];
}

- (NSData *)JSONDataRepresentation {
	NSString *json = [self JSONRepresentation];
	if (!json) {
		NSLog(@"Failed to create JSON: %@", self); 
		return nil;
	}

	return [NSData dataWithBytes:[json UTF8String] length:[json lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
}

@end



@implementation NSString (NSString_SBJsonParsing)

- (id)JSONValue {
    SBJsonParser *jsonParser = [SBJsonParser new];
    id repr = [jsonParser objectWithString:self];
    if (!repr)
        NSLog(@"-JSONValue failed. Error is: %@", jsonParser.error);
    [jsonParser release];
    return repr;
}

@end


@implementation NSData (SBJSON)

- (id)JSONValue {
	if ([self length] == 0) {
		return [@"" JSONValue];
	}

	NSUInteger length = [self length];
	const char *bytes = [self bytes];

	while (length > 0 && bytes[length - 1] == 0) {
		length -= 1; // removing traling '\0'
	}

	NSString *s = [[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
	id result = [s JSONValue];
	[s release];

	return result;
}

@end
