/*
 *  Error.h
 *  JSON
 *
 *  Created by Stig Brautaset on 17/03/2009.
 *  Copyright 2009 Stig Brautaset. All rights reserved.
 *
 */

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
    EEOF,
    EINPUT
};

