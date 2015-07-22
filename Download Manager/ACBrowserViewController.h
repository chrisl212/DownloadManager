//
//  ACBrowserViewController.h
//  Download Manager
//
//  Created by Chris on 3/17/15.
//  Copyright (c) 2015 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ACFileNavigatorKit/ACFileNavigatorKit.h>

@interface ACBrowserViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDataDelegate, NSURLConnectionDelegate, ACAlertViewDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UITextField *addressTextField;
@property (strong, nonatomic) ACCircularProgressView *progressView;

@end
