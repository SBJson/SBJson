//
// Created by SuperPappi on 09/01/2013.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>

typedef enum {
    sbjson_token_error = -1,
    sbjson_token_eof,

    sbjson_token_array_open,
    sbjson_token_array_close,
    sbjson_token_value_sep,

    sbjson_token_object_open,
    sbjson_token_object_close,
    sbjson_token_entry_sep,

    sbjson_token_bool,
    sbjson_token_null,

    sbjson_token_integer,
    sbjson_token_real,

    sbjson_token_string,
    sbjson_token_encoded,
} sbjson_token_t;


@interface SBJsonStreamTokeniser : NSObject

@property (nonatomic, readonly, copy) NSString *error;

- (void)appendData:(NSData*)data_;
- (sbjson_token_t)getToken:(char**)tok length:(NSUInteger*)len;

@end

