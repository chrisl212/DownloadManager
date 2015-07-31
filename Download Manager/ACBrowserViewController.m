//
//  ACBrowserViewController.m
//  Download Manager
//
//  Created by Chris on 3/17/15.
//  Copyright (c) 2015 A and C Studios. All rights reserved.
//

#import "ACBrowserViewController.h"
#import <ACFileNavigatorKit/ACAlertView.h>
#import "ACDownloadManager.h"

@implementation ACBrowserViewController
{
    NSMutableData *downloadedData;
    long long expectedLength;
    UIBarButtonItem *refreshBarButton;
    UIBarButtonItem *progressViewBarButton;
    NSString *MIMEType;
    UIToolbar *toolbar;
    NSURL *requestURL;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    toolbar.center = CGPointMake(self.view.frame.size.width/2.0, toolbar.frame.size.height/2.0);
    //toolbar.barTintColor = [UIColor redColor];
    [self.view addSubview:toolbar];
    
    self.addressTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 10, 32)];
    self.addressTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"homepage"];
    //self.addressTextField.center = toolbar.center;//CGPointMake(self.view.frame.size.width/2.0, self.addressTextField.frame.size.height/2.0);
    self.addressTextField.keyboardType = UIKeyboardTypeWebSearch;
    self.addressTextField.placeholder = @"Address or search Google";
    self.addressTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.addressTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.addressTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.addressTextField.clearButtonMode = UITextFieldViewModeUnlessEditing;
    self.addressTextField.backgroundColor = [UIColor whiteColor];
    self.addressTextField.returnKeyType = UIReturnKeyGo;
    [self.addressTextField addTarget:self action:@selector(changeAddress:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    UIBarButtonItem *textFieldBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.addressTextField];
    UIBarButtonItem *flex1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    toolbar.items = @[flex1, textFieldBarButton, flex2];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    self.webView.delegate = self;
    [self.view addSubview:_webView];
    
    NSURL *URL = [NSURL URLWithString:_addressTextField.text];
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:URLRequest];
    
    refreshBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self.webView action:@selector(reload)];
    self.navigationItem.rightBarButtonItem = refreshBarButton;
    
    self.progressView = [[ACCircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.progressView.backgroundColor = [UIColor clearColor];
    progressViewBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.progressView];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"❰" style:UIBarButtonItemStylePlain target:self.webView action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = back;
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.webView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - toolbar.frame.size.height);
    self.webView.center = CGPointMake(self.view.bounds.size.width/2.0, (self.view.bounds.size.height/2.0) + toolbar.frame.size.height/2.0);
}

- (void)changeAddress:(UITextField *)sender
{
    [sender resignFirstResponder];

    NSString *absoluteURL = sender.text;
    if ([absoluteURL rangeOfString:@" "].location != NSNotFound || [absoluteURL rangeOfString:@".*?(\\.)((?:[a-z][a-z]+))" options:NSRegularExpressionSearch].location == NSNotFound)
    {
        absoluteURL = [absoluteURL stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        absoluteURL = [NSString stringWithFormat:@"https://www.google.com/webhp?ie=UTF-8#q=%@", absoluteURL];
    }
    else if ([absoluteURL rangeOfString:@"http://" options:NSCaseInsensitiveSearch].location == NSNotFound && [absoluteURL rangeOfString:@"https://" options:NSCaseInsensitiveSearch].location == NSNotFound)
    {
        absoluteURL = [@"http://" stringByAppendingString:sender.text];
    }
    
    NSURL *URL = [NSURL URLWithString:absoluteURL];
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:URLRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Connection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    if (response.statusCode == 200)
    {
        self.navigationItem.rightBarButtonItem = progressViewBarButton;
        
        expectedLength = response.expectedContentLength;
        downloadedData = [NSMutableData data];
        
        MIMEType = [response MIMEType];
        
        NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *mimeTypesPath = [cacheDir stringByAppendingPathComponent:@"MimeTypes.plist"];
        NSArray *typesArray = [NSArray arrayWithContentsOfFile:mimeTypesPath];
        for (NSString *mime in typesArray)
        {
            if (!MIMEType)
                break;
            if ([MIMEType caseInsensitiveCompare:mime] == NSOrderedSame)
            {
                ACAlertView *alertView = [ACAlertView alertWithTitle:@"Save as..." style:ACAlertViewStyleTextField delegate:self buttonTitles:@[@"Cancel", @"Download"]];
                alertView.textField.text = connection.originalRequest.URL.lastPathComponent;
                [alertView show];
                
                requestURL = connection.originalRequest.URL;
                [connection cancel];
            }
        }

    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [downloadedData appendData:data];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = data.length/expectedLength;
    });
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.navigationItem.rightBarButtonItem = refreshBarButton;
    
    [self.webView loadData:downloadedData MIMEType:MIMEType textEncodingName:@"utf-8" baseURL:connection.originalRequest.URL];
}

#pragma mark - Web View Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    self.addressTextField.text = request.URL.absoluteString;
    self.navigationItem.leftBarButtonItem.enabled = self.webView.canGoBack;
    

    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dlTypesPath = [cacheDir stringByAppendingPathComponent:@"DownloadTypes.plist"];
    
    NSArray *typesArray = [NSArray arrayWithContentsOfFile:dlTypesPath];
    
    NSString *requestFileType = [[request.URL.absoluteString componentsSeparatedByString:@"?"][0] pathExtension];
    for (NSString *type in typesArray)
    {
        if ([type caseInsensitiveCompare:requestFileType] == NSOrderedSame)
        {
            ACAlertView *alertView = [ACAlertView alertWithTitle:@"Save as..." style:ACAlertViewStyleTextField delegate:self buttonTitles:@[@"Cancel", @"Download"]];
            alertView.textField.text = request.URL.lastPathComponent;
            [alertView show];

            requestURL = request.URL;
            
            return NO;
        }
    }
    
    if (navigationType == UIWebViewNavigationTypeOther)
        return YES;
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    
    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (title.length > 0)
    {
        self.navigationItem.title = title;
    }
    
    if (self.webView.canGoBack) self.navigationItem.leftBarButtonItem.enabled = YES;
    else self.navigationItem.leftBarButtonItem.enabled = NO;
}

#pragma mark - Alert View Delegate

- (void)alertView:(ACAlertView *)alertView didClickButtonWithTitle:(NSString *)title
{
    if ([title isEqualToString:@"Download"])
    {
        ACDownloadManager *downloadManager = [[ACDownloadManager alloc] init];
        downloadManager.fileName = alertView.textField.text;
        
        NSString *title = alertView.textField.text;
        ACAlertView *alertView = [ACAlertView alertWithTitle:title style:ACAlertViewStyleProgressView delegate:downloadManager buttonTitles:@[@"Cancel", @"Hide"]];
        [alertView show];
        [downloadManager downloadFileAtURL:requestURL];
    }
    [alertView dismiss];
}

@end
