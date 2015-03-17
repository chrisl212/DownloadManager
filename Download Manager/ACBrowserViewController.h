//
//  ACBrowserViewController.h
//  Download Manager
//
//  Created by Chris on 3/17/15.
//  Copyright (c) 2015 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACBrowserViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UITextField *addressTextField;

@end
