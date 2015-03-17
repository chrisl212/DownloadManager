//
//  ACBrowserViewController.m
//  Download Manager
//
//  Created by Chris on 3/17/15.
//  Copyright (c) 2015 A and C Studios. All rights reserved.
//

#import "ACBrowserViewController.h"

@implementation ACBrowserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.addressTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.addressTextField.text = @"https://www.google.com";
    self.addressTextField.center = CGPointMake(self.view.frame.size.width/2.0, self.addressTextField.frame.size.height/2.0);
    [self.view addSubview:_addressTextField];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.view.frame.size.height - _addressTextField.frame.size.height)];
    self.webView.center = CGPointMake(self.view.frame.size.width/2.0, (self.view.frame.size.height/2.0) + _addressTextField.frame.size.height);
    [self.view addSubview:_webView];
    
    NSURL *URL = [NSURL URLWithString:_addressTextField.text];
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:URLRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
