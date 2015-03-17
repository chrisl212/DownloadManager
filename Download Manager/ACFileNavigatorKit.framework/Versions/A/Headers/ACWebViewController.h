//
//  ACWebViewController.h
//  ACBrowsers
//
//  Created by Chris on 1/10/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACFile.h"

/* The default PDF viewer (since UIWebView has a built-in one) and can also be used to view most other things. */

@interface ACWebViewController : UIViewController

@property (strong, nonatomic) UIActivity *activity; //Necessary when presented from a UIActivityViewController
@property (strong, nonatomic) ACFile *file; //The file to open
@property (weak, nonatomic) IBOutlet UIWebView *webView; //The web view to display content on

- (id)initWithFile:(ACFile *)file;
- (void)dismiss;

@end
