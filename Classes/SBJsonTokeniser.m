/*
 Copyright (c) 2010-2011, Stig Brautaset. All rights reserved.

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

#import "SBJsonTokeniser.h"


#define SBStringIsIllegalSurrogateHighCharacter(x) (((x) >= 0xd800) && ((x) <= 0xdfff))


@implementation SBJsonTokeniser

@synthesize error = _error;

- (id)init {
    self = [super init];
    if (self) {
        _data = [[NSMutableData alloc] initWithCapacity:4096u];

    }

    return self;
}

- (void)dealloc {
    [_data release];
    [super dealloc];
}

- (void)appendData:(NSData *)data_ {

    if (_index) {
        // Discard data we've already parsed
		[_data replaceBytesInRange:NSMakeRange(0, _index) withBytes:"" length:0];

        // Keep track of how much we have discarded
        _discarded += _index;

        // Reset index to point to current position
		_index = 0;
	}

    [_data appendData:data_];
    
    // This is an optimisation. 
    _bytes = [_data bytes];
    _length = [_data length];
}

- (BOOL)getUnichar:(unichar*)ch {
    if (_index < _length) {
        *ch = (unichar)_bytes[_index];
        return YES;
    }
    return NO;
}

- (BOOL)getNextUnichar:(unichar*)ch {
    if (++_index < _length) {
        *ch = (unichar)_bytes[_index];
        return YES;
    }
    return NO;
}

- (void)skipWhitespace {
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    unichar ch;
    if (![self getUnichar:&ch])
        return;

    while ([ws characterIsMember:ch] && [self getNextUnichar:&ch])
        ;
}

- (BOOL)ensureChars:(NSUInteger)chars {
    return [_data length] - _index >= chars;
}

- (sbjson_token_t)match:(char *)pattern length:(NSUInteger)len retval:(sbjson_token_t)token {
    if (![self ensureChars:len])
        return sbjson_token_eof;

    const void *bytes = [_data bytes] + _index;
    if (!memcmp(bytes, pattern, len)) {
        _index += len;
        return token;
    }

    NSString *fmt = [NSString stringWithFormat:@"Expected '%%s' but found '%%.%us'", len];
    self.error = [NSString stringWithFormat:fmt, pattern, (const char*)bytes];
    return sbjson_token_error;
}

- (BOOL)decodeEscape:(unichar)ch into:(unichar*)decoded {
    switch (ch) {
        case '\\':
        case '/':
        case '"':
            *decoded = ch;
            break;

        case 'b':
            *decoded = '\b';
            break;

        case 'n':
            *decoded = '\n';
            break;

        case 'r':
            *decoded = '\r';
            break;

        case 't':
            *decoded = '\t';
            break;

        case 'f':
            *decoded = '\f';
            break;

        default:
            self.error = @"Illegal escape character";
            return NO;
            break;
    }
    return YES;
}

- (BOOL)decodeHexQuad:(unichar*)quad {
    unichar c, tmp = 0;

    for (int i = 0; i < 4; i++) {
        (void)[self getNextUnichar:&c];
        tmp *= 16;
        switch (c) {
            case '0' ... '9':
                tmp += c - '0';
                break;

            case 'a' ... 'f':
                tmp += 10 + c - 'a';
                break;

            case 'A' ... 'F':
                tmp += 10 + c - 'A';
                break;

            default:
                return NO;
        }
    }
    *quad = tmp;
    return YES;
}

- (sbjson_token_t)getStringToken:(NSObject**)token {
    unichar ch;
    NSMutableData *data = [NSMutableData dataWithCapacity:128u];

    while ([self getNextUnichar:&ch]) {
        switch (ch) {
            case 0 ... 0x1F:
                self.error = [NSString stringWithFormat:@"Unescaped control character [0x%0.2X]", (int)ch];
                return sbjson_token_error;
                break;

            case '"':
                (void)[self getNextUnichar:&ch];
                *token = [[[NSString alloc] initWithData:data encoding:NSUTF16LittleEndianStringEncoding] autorelease];
                return sbjson_token_string;
                break;

            case '\\':
                if (![self getNextUnichar:&ch])
                    return sbjson_token_eof;

                if (ch == 'u') {
                    if (![self ensureChars:5])
                        return sbjson_token_eof;

                    unichar hi;
                    if (![self decodeHexQuad:&hi]) {
                        self.error = @"Invalid hex quad";
                        return sbjson_token_error;
                    }

                    if (CFStringIsSurrogateHighCharacter(hi)) {
                        unichar lo;

                        if (![self ensureChars:6])
                            return sbjson_token_eof;

                        (void)[self getNextUnichar:&ch];
                        (void)[self getNextUnichar:&lo];
                        if (ch != '\\' || lo != 'u' || ![self decodeHexQuad:&lo]) {
                            self.error = @"Missing low character in surrogate pair";
                            return sbjson_token_error;
                        }

                        if (!CFStringIsSurrogateLowCharacter(lo)) {
                            self.error = @"Invalid low character in surrogate pair";
                            return sbjson_token_error;
                        }

                        unichar pair[2] = {hi, lo};
                        [data appendBytes:pair length:4];
                    } else if (SBStringIsIllegalSurrogateHighCharacter(hi)) {
                        self.error = @"Invalid high character in surrogate pair";
                        return sbjson_token_error;
                    } else {
                        [data appendBytes:&hi length:2];
                    }


                } else {
                    unichar decoded;
                    if (![self decodeEscape:ch into:&decoded])
                        return sbjson_token_error;
                    [data appendBytes:&decoded length:2];
                }

                break;

            default:
                [data appendBytes:&ch length:2];
        }
    }
    return sbjson_token_eof;
}

- (sbjson_token_t)getNumberToken:(NSObject**)token {

    NSUInteger numberStart = _index;
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];

    unichar ch;
    if (![self getUnichar:&ch])
        return sbjson_token_eof;

    BOOL isNegative = NO;
    if (ch == '-') {
        isNegative = YES;
        if (![self getNextUnichar:&ch])
            return sbjson_token_eof;
    }

    if (ch == '0') {
        if (![self getNextUnichar:&ch])
            return sbjson_token_eof;

        if ([digits characterIsMember:ch]) {
            self.error = @"Leading zero is illegal in number";
            return sbjson_token_error;
        }
    }

    unsigned long long mantissa = 0;
    int mantissa_length = 0;

    while ([digits characterIsMember:ch]) {
        mantissa *= 10;
        mantissa += (ch - '0');
        mantissa_length++;

        if (![self getNextUnichar:&ch])
            return sbjson_token_eof;
    }

    short exponent = 0;
    BOOL isFloat = NO;

    if (ch == '.') {
        isFloat = YES;
        if (![self getNextUnichar:&ch])
            return sbjson_token_eof;

        while ([digits characterIsMember:ch]) {
            mantissa *= 10;
            mantissa += (ch - '0');
            mantissa_length++;
            exponent--;

            if (![self getNextUnichar:&ch])
                return sbjson_token_eof;
        }

        if (!exponent) {
            self.error = @"No digits after decimal point";
            return sbjson_token_error;
        }
    }

    BOOL hasExponent = NO;
    if (ch == 'e' || ch == 'E') {
        hasExponent = YES;

        if (![self getNextUnichar:&ch])
            return sbjson_token_eof;

        BOOL expIsNegative = NO;
        if (ch == '-') {
            expIsNegative = YES;
            if (![self getNextUnichar:&ch])
                return sbjson_token_eof;

        } else if (ch == '+') {
            if (![self getNextUnichar:&ch])
                return sbjson_token_eof;
        }

        short exp = 0;
        short exp_length = 0;
        while ([digits characterIsMember:ch]) {
            exp *= 10;
            exp += (ch - '0');
            exp_length++;

            if (![self getNextUnichar:&ch])
                return sbjson_token_eof;
        }

        if (exp_length == 0) {
            self.error = @"No digits in exponent";
            return sbjson_token_error;
        }

        if (expIsNegative)
            exponent -= exp;
        else
            exponent += exp;
    }

    if (!mantissa_length && isNegative) {
        self.error = @"No digits after initial minus";
        return sbjson_token_error;

    } else if (mantissa_length >= 19) {

        // The slow path... for REALLY long numbers
        char *bytes = (char*)[_data bytes] + numberStart;
        NSUInteger len = _index - numberStart;
        NSString *numberString = [[[NSString alloc] initWithBytes:bytes length:len encoding:NSUTF8StringEncoding] autorelease];
        *token = [NSDecimalNumber decimalNumberWithString:numberString];

    } else if (!isFloat && !hasExponent) {
        if (!isNegative)
            *token = [NSNumber numberWithUnsignedLongLong:mantissa];
        else
            *token = [NSNumber numberWithLongLong:-mantissa];
    } else {
        *token = [NSDecimalNumber decimalNumberWithMantissa:mantissa
                                                   exponent:exponent
                                                 isNegative:isNegative];
    }

    return sbjson_token_number;
}

- (sbjson_token_t)getToken:(NSObject **)token {

    [self skipWhitespace];

    unichar ch;
    if (![self getUnichar:&ch])
        return sbjson_token_eof;

    NSUInteger oldIndexLocation = _index;
    sbjson_token_t tok;

    switch (ch) {
        case '[':
            tok = sbjson_token_array_start;
            _index++;
            break;

        case ']':
            tok = sbjson_token_array_end;
            _index++;
            break;

        case '{':
            tok = sbjson_token_object_start;
            _index++;
            break;

        case ':':
            tok = sbjson_token_keyval_separator;
            _index++;
            break;

        case '}':
            tok = sbjson_token_object_end;
            _index++;
            break;

        case ',':
            tok = sbjson_token_separator;
            _index++;
            break;

        case 'n':
            tok = [self match:"null" length:4 retval:sbjson_token_null];
            break;

        case 't':
            tok = [self match:"true" length:4 retval:sbjson_token_true];
            break;

        case 'f':
            tok = [self match:"false" length:5 retval:sbjson_token_false];
            break;

        case '"':
            tok = [self getStringToken:token];
            break;

        case '0' ... '9':
        case '-':
            tok = [self getNumberToken:token];
            break;

        case '+':
            self.error = @"Leading + is illegal in number";
            tok = sbjson_token_error;
            break;

        default:
            self.error = [NSString stringWithFormat:@"Illegal start of token [%c]", ch];
            tok = sbjson_token_error;
            break;
    }

    if (tok == sbjson_token_eof) {

        // Reset index pointer for next call
        _index = oldIndexLocation;
    }

    return tok;
}


@end
