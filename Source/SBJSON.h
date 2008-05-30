/*
Copyright (C) 2008 Stig Brautaset. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

  Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

  Neither the name of the author nor the names of its contributors may be used
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

#import <Foundation/Foundation.h>

extern NSString * SBJSONErrorDomain;

enum {
    EUNSUPPORTED = 1,
    EPARSENUM,
    EPARSE,
    EFRAGMENT,
    ECTRL,
    EUNICODE,
    EDEPTH,
    EESCAPE,
    ETRAILCOMMA,
    ETRAILGARBAGE,
};

/// A strict JSON parser and generator
@interface SBJSON : NSObject {
    // Attributes
    BOOL humanReadable;
    unsigned maxDepth;

@private
    // Used temporarily during scanning/generation
    unsigned depth;
    const char *c;
}

/// Whether we are generating human-readable (multiline) JSON
- (BOOL)humanReadable;

/// Set whether to generate human-readable JSON or not
- (void)setHumanReadable:(BOOL)y;

/// The maximum depth the parser will go to
- (unsigned)maxDepth;

/// Set the maximum depth the parser will go to
- (void)setMaxDepth:(unsigned)y;

/// Return JSON representation of an array  or dictionary
- (NSString*)stringWithObject:(id)value error:(NSError**)error;

/// Return JSON representation of any legal JSON value
- (NSString*)stringWithFragment:(id)value error:(NSError**)error;

/// Return the object represented by the given string
- (id)objectWithString:(NSString*)jsonrep error:(NSError**)error;

/// Return the fragment represented by the given string
- (id)fragmentWithString:(NSString*)jsonrep error:(NSError**)error;

@end
