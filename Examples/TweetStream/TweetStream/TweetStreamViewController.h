//
//  TweetStreamViewController.h
//  TweetStream
//
//  Created by Stig Brautaset on 24/05/2011.
//  Copyright 2011 Stig Brautaset. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBJsonStreamParser;
@class SBJsonStreamParserAdapter;

@interface TweetStreamViewController : UIViewController {
    IBOutlet UILabel *username;
    IBOutlet UIButton *goButton;
    IBOutlet UITextView *tweet;
    
    NSURLConnection *theConnection;
    SBJsonStreamParser *parser;
    SBJsonStreamParserAdapter *adapter;
}

- (IBAction)go;

@end
