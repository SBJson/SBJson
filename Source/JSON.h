/*
Copyright (c) 2007, Stig Brautaset. All rights reserved.

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

/**
 @mainpage A strict JSON parser and generator for Objective-C

 JSON (JavaScript Object Notation) is a lightweight data-interchange
 format. This framework provides two apis for parsing and generating
 JSON. One standard object-based and a higher level api consisting of
 categories added to existing Objective-C classes.

 Learn more on the http://code.google.com/p/json-framework project site.
  
 @section Mapping
 
 @subsection sub_objc_to_json Objective-C to JSON
 
 Objective-C types are mapped to JSON types in the following way:
 
 @li NSNull -> Null
 @li NSString -> String
 @li NSArray -> Array
 @li NSDictionary -> Object
 @li NSNumber (-initWithBool:) -> Boolean
 @li NSNumber -> Number
 
 In JSON the keys of an object must be strings. NSDictionary keys need
 not be, but attempting to convert an NSDictionary with non-string keys
 into JSON will throw an exception.
 
 NSNumber instances created with the +initWithBool: method are
 converted into the JSON boolean "true" and "false" values, and vice
 versa. Any other NSNumber instances are converted to a JSON number the
 way you would expect.
 
 @subsection sub_json_to_objc JSON to Objective-C
 
 @li Null -> NSNull
 @li String -> NSMutableString
 @li Array -> NSMutableArray
 @li Object -> NSMutableDictionary
 @li Boolean -> NSNumber (initialised with -initWithBool:)
 @li Number -> NSDecimalNumber
 
 Since Objective-C doesn't have a class for bool, Booleans turns into NSNumber
 instances. These are initialised with the -initWithBool: method, and therefore
 round-trip back to JSON properly.
 
 JSON numbers turn into NSDecimalNumber instances,
 as we can thus avoid any loss of precision. (JSON allows ridiculously large numbers.)
 
 @section sec_working_with_scalars Working with scalars
 
 Strictly speaking correctly formed JSON text must have <strong>exactly
 one top-level container</strong>. (Either an Array or an Object.) Scalars,
 i.e. nulls, numbers, booleans and strings, are not valid JSON on their own.
 It can be quite convenient to pretend that such fragments are valid
 JSON however, and this framework lets you do so.
 
 This framework does its best to be as strict as possible, both in what it
 accepts and what it generates. For example, it does not support trailing commas
 in arrays or objects. Nor does it support embedded comments, or
 anything else not in the JSON specification. This is considered a feature.
 
*/

#import <JSON/SBJSON.h>
#import <JSON/NSObject+SBJSON.h>
#import <JSON/NSString+SBJSON.h>

