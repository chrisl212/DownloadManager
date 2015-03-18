//
//  ACBrowserViewController.m
//  Download Manager
//
//  Created by Chris on 3/17/15.
//  Copyright (c) 2015 A and C Studios. All rights reserved.
//

#import "ACBrowserViewController.h"
#import "ACFileNavigatorKit.framework/Headers/ACAlertView.h"
#import "ACDownloadManager.h"

@implementation ACBrowserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    self.addressTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.addressTextField.text = @"https://www.google.com";
    self.addressTextField.center = CGPointMake(self.view.frame.size.width/2.0, self.addressTextField.frame.size.height/2.0);
    self.addressTextField.keyboardType = UIKeyboardTypeURL;
    self.addressTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.addressTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.addressTextField.clearButtonMode = UITextFieldViewModeUnlessEditing;
    self.addressTextField.backgroundColor = [UIColor whiteColor];
    self.addressTextField.returnKeyType = UIReturnKeyGo;
    [self.addressTextField addTarget:self action:@selector(changeAddress:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:_addressTextField];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    self.webView.delegate = self;
    [self.view addSubview:_webView];
    
    NSURL *URL = [NSURL URLWithString:_addressTextField.text];
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:URLRequest];
    
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self.webView action:@selector(reload)];
    self.navigationItem.rightBarButtonItem = refresh;
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"❰" style:UIBarButtonItemStylePlain target:self.webView action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = back;
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.webView.frame = CGRectMake(0.0, 0.0, 320.0, self.view.frame.size.height - _addressTextField.frame.size.height);
    self.webView.center = CGPointMake(self.view.bounds.size.width/2.0, (self.view.bounds.size.height/2.0) + _addressTextField.frame.size.height/2.0);
}

- (void)changeAddress:(UITextField *)sender
{
    NSString *absoluteURL = sender.text;
    if ([absoluteURL rangeOfString:@"http://" options:NSCaseInsensitiveSearch].location == NSNotFound && [absoluteURL rangeOfString:@"https://" options:NSCaseInsensitiveSearch].location == NSNotFound)
    {
        absoluteURL = [@"http://" stringByAppendingString:sender.text];
    }
    [sender resignFirstResponder];
    NSURL *URL = [NSURL URLWithString:absoluteURL];
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:URLRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Web View Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dlTypesPath = [cacheDir stringByAppendingPathComponent:@"DownloadTypes.plist"];
    NSString *mimeTypesPath = [cacheDir stringByAppendingPathComponent:@"MimeTypes.plist"];
    
    NSArray *typesArray = [NSArray arrayWithContentsOfFile:dlTypesPath];
    
    NSURLRequest *fileUrlRequest = [[NSURLRequest alloc] initWithURL:request.URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:0.3];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:fileUrlRequest returningResponse:&response error:&error];
    NSString *MIMEType = [response MIMEType];
    
    NSString *requestFileType = request.URL.absoluteString.pathExtension;
    for (NSString *type in typesArray)
    {
        if ([type caseInsensitiveCompare:requestFileType] == NSOrderedSame)
        {
            ACDownloadManager *downloadManager = [[ACDownloadManager alloc] init];
            NSString *title = request.URL.absoluteString.lastPathComponent;
            ACAlertView *alertView = [ACAlertView alertWithTitle:title style:ACAlertViewStyleProgressView delegate:downloadManager buttonTitles:@[@"Cancel", @"Hide"]];
            [alertView show];
            [downloadManager downloadFileAtURL:request.URL];
            return NO;
        }
    }
    typesArray = [NSArray arrayWithContentsOfFile:mimeTypesPath];
    for (NSString *mime in typesArray)
    {
        if (!MIMEType)
            break;
        if ([MIMEType caseInsensitiveCompare:mime] == NSOrderedSame)
        {
            ACDownloadManager *downloadManager = [[ACDownloadManager alloc] init];
            NSString *title = request.URL.absoluteString.lastPathComponent;
            ACAlertView *alertView = [ACAlertView alertWithTitle:title style:ACAlertViewStyleProgressView delegate:downloadManager buttonTitles:@[@"Cancel", @"Hide"]];
            [alertView show];
            [downloadManager downloadFileAtURL:request.URL];
            return NO;
        }
    }
    
    self.addressTextField.text = request.URL.absoluteString;
    return YES;
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

@end
