//
//  ACBrowserViewController.h
//  Download Manager
//
//  Created by Chris on 3/17/15.
//  Copyright (c) 2015 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CLFileNavigatorKit/CLFileNavigatorKit.h>
#import <WebKit/WebKit.h>
#import "ACTextField.h"

@interface ACBrowserViewController : UIViewController <WKNavigationDelegate, UIWebViewDelegate, NSURLConnectionDataDelegate, NSURLConnectionDelegate, ACAlertViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, UIScrollViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) ACTextField *addressTextField;
@property (strong, nonatomic) ACCircularProgressView *progressView;

@end
