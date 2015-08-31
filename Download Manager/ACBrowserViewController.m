//
//  ACBrowserViewController.m
//  Download Manager
//
//  Created by Chris on 3/17/15.
//  Copyright (c) 2015 A and C Studios. All rights reserved.
//

#import "ACBrowserViewController.h"
#import <CLFileNavigatorKit/CLFileNavigatorKit.h>
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)openMenu:(UILongPressGestureRecognizer *)sender
{
    if (sender.state != UIGestureRecognizerStateBegan)
        return;
    
    NSString *JSString = @"function GetHTMLElementsAtPoint(x,y) { var tags = \"\";var e = document.elementFromPoint(x,y);while (e) {if (e.tagName == 'A') {tags += e.getAttribute('href') + ',';}e = e.parentNode;}return tags;}";
    [self.webView evaluateJavaScript:JSString completionHandler:nil];
    
    CGPoint pt = [sender locationInView:self.webView];
    __block NSString *tags;
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"GetHTMLElementsAtPoint(%ld,%ld);",(long)pt.x,(long)pt.y] completionHandler:^(id obj, NSError *err)
                      {
                          tags = obj;
                          if (tags.length > 0)
                          {
                              NSString *linkURLString = [tags componentsSeparatedByString:@","][0];
                              UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:linkURLString delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Download" otherButtonTitles:@"Open", @"Copy", nil];
                              [actionSheet showInView:self.webView];
                          }
                      }];
}

- (void)saveAsAlert:(NSTimer *)sender
{
    NSDictionary *userInfo = sender.userInfo;
    
    ACAlertView *actionSheetAlertView = [ACAlertView alertWithTitle:@"Save as..." style:ACAlertViewStyleTextField delegate:self buttonTitles:@[@"Cancel", @"Download"]];
    actionSheetAlertView.textField.text = [userInfo[@"link"] lastPathComponent];
    [actionSheetAlertView show];
    
    requestURL = [NSURL URLWithString:userInfo[@"link"]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSString *linkURLString = actionSheet.title;
    
    if ([buttonTitle isEqualToString:@"Cancel"])
        return;
    else if ([buttonTitle isEqualToString:@"Download"])
    {
        NSTimer *alertTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(saveAsAlert:) userInfo:@{@"link" : linkURLString} repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:alertTimer forMode:NSRunLoopCommonModes];
    }
    else if ([buttonTitle isEqualToString:@"Open"])
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:linkURLString]];
        [self.webView loadRequest:request];
    }
    else if ([buttonTitle isEqualToString:@"Copy"])
        [[UIPasteboard generalPasteboard] setString:linkURLString];
}

- (void)downloadAddressBar
{
    NSURL *URL = self.webView.URL;
    
    ACAlertView *alertView = [ACAlertView alertWithTitle:@"Save as..." style:ACAlertViewStyleTextField delegate:self buttonTitles:@[@"Cancel", @"Download"]];
    alertView.textField.text = URL.lastPathComponent;
    [alertView show];
    
    requestURL = URL;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = self.webView.estimatedProgress;
        });
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;

    self.addressTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 32)];
    self.addressTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"homepage"];
    //self.addressTextField.center = toolbar.center;//CGPointMake(self.view.frame.size.width/2.0, self.addressTextField.frame.size.height/2.0);
    self.addressTextField.keyboardType = UIKeyboardTypeWebSearch;
    
    NSString *searchEngine = [[NSUserDefaults standardUserDefaults] objectForKey:@"search engine"];
    self.addressTextField.placeholder = [NSString stringWithFormat:@"Enter address or search %@", searchEngine];
    
    self.addressTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.addressTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.addressTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.addressTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.addressTextField.backgroundColor = [UIColor whiteColor];
    self.addressTextField.returnKeyType = UIReturnKeyGo;
    [self.addressTextField addTarget:self action:@selector(changeAddress:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.addressTextField addTarget:self action:@selector(displayAddress) forControlEvents:UIControlEventEditingDidBegin];
    self.navigationItem.titleView = self.addressTextField;
    
    //UIBarButtonItem *textFieldBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.addressTextField];

    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    self.webView.navigationDelegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:kNilOptions context:NULL];
    self.webView.scrollView.delegate = self;
    [self.view addSubview:_webView];
    
    NSURL *URL = [NSURL URLWithString:_addressTextField.text];
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:URLRequest];
    
    
    self.progressView = [[ACCircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.lineWidth = 2.5;
    progressViewBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.progressView];
    
    refreshBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self.webView action:@selector(reload)];
    
    [self.navigationController setToolbarHidden:NO];
    [self setUpToolbar:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchEngineChanged) name:@"searchEngine" object:nil];
}

- (void)setUpToolbar:(BOOL)isLoading
{
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-50.png"] style:UIBarButtonItemStylePlain target:self.webView action:@selector(goBack)];
    back.enabled = self.webView.canGoBack;
    UIBarButtonItem *forward = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward-50.png"] style:UIBarButtonItemStylePlain target:self.webView action:@selector(goForward)];
    forward.enabled = self.webView.canGoForward;
    
    UIBarButtonItem *flex1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *download = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"download.png"] style:UIBarButtonItemStylePlain target:self action:@selector(downloadAddressBar)];
    UIBarButtonItem *stop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self.webView action:@selector(stopLoading)];
    
    self.toolbarItems = @[back, flex1, (isLoading) ? stop : download, flex2, (isLoading) ? progressViewBarButton : refreshBarButton, flex3, forward];
}

- (void)searchEngineChanged
{
    NSString *searchEngine = [[NSUserDefaults standardUserDefaults] objectForKey:@"search engine"];
    self.addressTextField.placeholder = [NSString stringWithFormat:@"Enter address or search %@", searchEngine];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.webView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - toolbar.frame.size.height);
    self.webView.center = CGPointMake(self.view.bounds.size.width/2.0, (self.view.bounds.size.height/2.0) + toolbar.frame.size.height/2.0);
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(openMenu:)];
    longPressGestureRecognizer.minimumPressDuration = 0.5;
    longPressGestureRecognizer.delegate = self;
    [self.webView addGestureRecognizer:longPressGestureRecognizer];
}

- (void)displayAddress
{
    self.addressTextField.textAlignment = NSTextAlignmentLeft;
    self.addressTextField.text = self.webView.URL.absoluteString;
}

- (void)changeAddress:(UITextField *)sender
{
    [sender resignFirstResponder];

    NSString *absoluteURL = sender.text;
    if ([absoluteURL rangeOfString:@" "].location != NSNotFound || [absoluteURL rangeOfString:@".*?(\\.)((?:[a-z][a-z]+))" options:NSRegularExpressionSearch].location == NSNotFound)
    {
        absoluteURL = [absoluteURL stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        NSString *searchEngine = [[NSUserDefaults standardUserDefaults] objectForKey:@"search engine"];
        
        if ([searchEngine isEqualToString:@"Google"])
            absoluteURL = [NSString stringWithFormat:@"https://www.google.com/webhp?ie=UTF-8#q=%@", absoluteURL];
        else if ([searchEngine isEqualToString:@"Yahoo"])
            absoluteURL = [NSString stringWithFormat:@"https://search.yahoo.com/search?p=%@", absoluteURL];
        else if ([searchEngine isEqualToString:@"Bing"])
            absoluteURL = [NSString stringWithFormat:@"http://www.bing.com/search?q=%@", absoluteURL];
    }
    else if ([absoluteURL rangeOfString:@"((?:http|https)(?::\\/{2}[\\w]+)(?:[\\/|\\.]?)(?:[^\\s""]*))" options:NSCaseInsensitiveSearch | NSRegularExpressionSearch].location == NSNotFound)
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
    [connection cancel];
    if (response.statusCode == 200)
    {
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
            }
        }
    }
}

#pragma mark - Web View Delegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    self.addressTextField.textAlignment = NSTextAlignmentLeft;
    self.addressTextField.text = webView.URL.absoluteString;
    [self setUpToolbar:YES];
    
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dlTypesPath = [cacheDir stringByAppendingPathComponent:@"DownloadTypes.plist"];
    
    NSArray *typesArray = [NSArray arrayWithContentsOfFile:dlTypesPath];
    
    NSString *requestFileType = [[webView.URL.absoluteString componentsSeparatedByString:@"?"][0] pathExtension];
    for (NSString *type in typesArray)
    {
        if ([type caseInsensitiveCompare:requestFileType] == NSOrderedSame)
        {
            ACAlertView *alertView = [ACAlertView alertWithTitle:@"Save as..." style:ACAlertViewStyleTextField delegate:self buttonTitles:@[@"Cancel", @"Download"]];
            alertView.textField.text = webView.URL.lastPathComponent;
            [alertView show];
            
            requestURL = webView.URL;
            
            return;
        }
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:webView.URL];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start]; 
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self webView:webView didFinishNavigation:navigation];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [webView evaluateJavaScript:@"document.body.style.webkitTouchCallout='none';" completionHandler:nil];
    
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id obj, NSError *err)
                       {
                           NSString *title = obj;
                           if (title.length > 0)
                           {
                               self.addressTextField.text = title;
                               self.addressTextField.textAlignment = NSTextAlignmentCenter;
                           }
                           else
                           {
                               self.addressTextField.text = webView.URL.absoluteString;
                               self.addressTextField.textAlignment = NSTextAlignmentLeft;
                           }
                       }];
    [self setUpToolbar:NO];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].y > 0)
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController setToolbarHidden:NO animated:YES];
    } else
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
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
