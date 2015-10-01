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
#import <MobileCoreServices/MobileCoreServices.h>

@implementation ACBrowserViewController
{
    UIBarButtonItem *refreshBarButton;
    UIBarButtonItem *progressViewBarButton;
    NSString *MIMEType;
    NSURL *requestURL;
    BOOL downloadCheck;
    ACViewSelectViewController *viewSelectViewController;
}

- (WKWebView *)createWebView
{
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.mediaPlaybackRequiresUserAction = YES;
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    webView.navigationDelegate = self;
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    webView.allowsBackForwardNavigationGestures = YES;
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:kNilOptions context:NULL];
    webView.scrollView.delegate = self;
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(openMenu:)];
    longPressGestureRecognizer.minimumPressDuration = 0.5;
    longPressGestureRecognizer.delegate = self;
    [webView addGestureRecognizer:longPressGestureRecognizer];
    
    return webView;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)openMenu:(UILongPressGestureRecognizer *)sender
{
    if (sender.state != UIGestureRecognizerStateBegan)
        return;
    
    NSString *JSString = @"function GetHTMLElementsAtPoint(x,y) { var tags = \"\";var e = document.elementFromPoint(x,y);while (e) {if (e.tagName == 'A') {tags += e.getAttribute('href') + ',';} else if (e.tagName == 'IMG') { tags += e.getAttribute('src') + ',';}e = e.parentNode;}return tags;}";
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

- (void)tapDetected:(UITapGestureRecognizer *)recog
{
    if (self.webView.isLoading)
        return;
    NSString *JSString = @"function isElementUploadAtPoint(x,y) { var tags = \"\";var e = document.elementFromPoint(x,y);while (e) {tags += e.tagName}return tags;}";
    [self.webView evaluateJavaScript:JSString completionHandler:nil];

    CGPoint pt = [recog locationInView:self.webView];
    __block NSString *tags;
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"isElementUploadAtPoint(%ld,%ld);",(long)pt.x,(long)pt.y] completionHandler:^(id obj, NSError *err)
     {
         tags = obj;
         NSLog(@"%@", tags);
     }];
}

- (void)saveAsAlert:(NSTimer *)sender
{
    NSDictionary *userInfo = sender.userInfo;
    
    ACAlertView *actionSheetAlertView = [ACAlertView alertWithTitle:@"Save as..." style:ACAlertViewStyleTextField delegate:self buttonTitles:@[@"Cancel", @"Download"]];
    actionSheetAlertView.textField.text = [userInfo[@"link"] lastPathComponent];
    [actionSheetAlertView show];
    
    requestURL = [NSURL URLWithString:[userInfo[@"link"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
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
        downloadCheck = NO;
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
    downloadCheck = YES;
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.navigationController.hidesBarsOnSwipe = YES;

    self.addressTextField = [[ACTextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 32)];
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
    self.addressTextField.delegate = self;
    self.navigationItem.titleView = self.addressTextField;
    
    //UIBarButtonItem *textFieldBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.addressTextField];

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.mediaPlaybackRequiresUserAction = YES;
    
    self.webView = [self createWebView];
    
    self.webViews = @[_webView].mutableCopy;
    [self.view addSubview:_webView];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.delegate = self;
    //TODO: [self.webView addGestureRecognizer:tapGestureRecognizer];
    
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
    UIBarButtonItem *flex4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *download = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"download.png"] style:UIBarButtonItemStylePlain target:self action:@selector(downloadAddressBar)];
    UIBarButtonItem *stop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self.webView action:@selector(stopLoading)];
    UIBarButtonItem *tabs = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tabs.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showTabs)];
    
    self.toolbarItems = @[back, flex1, (isLoading) ? stop : download, flex2, (isLoading) ? progressViewBarButton : refreshBarButton, flex4, tabs, flex3, forward];
}

- (void)showTabs
{
    self.navigationController.hidesBarsOnSwipe = NO;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    viewSelectViewController = [[ACViewSelectViewController alloc] initWithViews:self.webViews delegate:self];
    [self.webView removeFromSuperview];
    for (UIGestureRecognizer *recog in self.webView.gestureRecognizers)
        if ([recog isKindOfClass:[UILongPressGestureRecognizer class]])
            [self.webView removeGestureRecognizer:recog];
    [self addChildViewController:viewSelectViewController];
    [self.view addSubview:viewSelectViewController.view];
    [viewSelectViewController setSelectedIndex:[self.webViews indexOfObject:self.webView] animated:NO];
}

- (void)viewSelectControllerShouldCreateNewView:(ACViewSelectViewController *)controller
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
    WKWebView *webView = [self createWebView];
    [self.webViews addObject:webView];
    self.navigationController.hidesBarsOnSwipe = YES;
    [viewSelectViewController removeFromParentViewController];
    [viewSelectViewController.view removeFromSuperview];
    self.webView = webView;
    self.webView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);// - toolbar.frame.size.height);
    self.webView.center = CGPointMake(self.view.bounds.size.width/2.0, (self.view.bounds.size.height/2.0));// + toolbar.frame.size.height/2.0);
    self.webView.userInteractionEnabled = YES;
    [self.view addSubview:self.webView];
    
    self.addressTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"homepage"];
    NSURL *URL = [NSURL URLWithString:_addressTextField.text];
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:URLRequest];
}

- (void)viewSelectController:(ACViewSelectViewController *)controller didSelectViewAtIndex:(NSInteger)index
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
    self.navigationController.hidesBarsOnSwipe = YES;
    [viewSelectViewController removeFromParentViewController];
    [viewSelectViewController.view removeFromSuperview];
    self.webView = self.webViews[index];
    self.webView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);// - toolbar.frame.size.height);
    self.webView.center = CGPointMake(self.view.bounds.size.width/2.0, (self.view.bounds.size.height/2.0));// + toolbar.frame.size.height/2.0);
    self.webView.userInteractionEnabled = YES;
    [self.view addSubview:self.webView];
    self.addressTextField.text = self.webView.title;
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(openMenu:)];
    longPressGestureRecognizer.minimumPressDuration = 0.5;
    longPressGestureRecognizer.delegate = self;
    [self.webView addGestureRecognizer:longPressGestureRecognizer];
}

- (void)viewSelectController:(ACViewSelectViewController *)controller didDeleteViewAtIndex:(NSInteger)index
{
    WKWebView *webView = self.webViews[index];
    [webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webViews removeObjectAtIndex:index];
    
    if (index == 0)
        index = 1;
    if (self.webViews.count == 0)
        [self.webViews addObject:[self createWebView]];
    controller.views = self.webViews;
    [controller setSelectedIndex:index-1 animated:YES];
}

- (void)searchEngineChanged
{
    NSString *searchEngine = [[NSUserDefaults standardUserDefaults] objectForKey:@"search engine"];
    self.addressTextField.placeholder = [NSString stringWithFormat:@"Enter address or search %@", searchEngine];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.webView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);// - toolbar.frame.size.height);
    self.webView.center = CGPointMake(self.view.bounds.size.width/2.0, (self.view.bounds.size.height/2.0));// + toolbar.frame.size.height/2.0);
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.addressTextField.textAlignment = NSTextAlignmentLeft;
    self.addressTextField.text = self.webView.URL.absoluteString;

    dispatch_async(dispatch_get_main_queue(), ^{
        UITextRange *range = [textField textRangeFromPosition:textField.beginningOfDocument toPosition:textField.endOfDocument];
        [textField setSelectedTextRange:range];
    });
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

#pragma mark - Web View Delegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    if (!downloadCheck)
    {
        downloadCheck = YES;
        decisionHandler(WKNavigationResponsePolicyAllow);
        return;
    }
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dlTypesPath = [cacheDir stringByAppendingPathComponent:@"DownloadTypes.plist"];
    
    NSArray *typesArray = [NSArray arrayWithContentsOfFile:dlTypesPath];
    
    NSString *requestFileType = [[navigationResponse.response.URL.absoluteString componentsSeparatedByString:@"?"][0] pathExtension];
    for (NSString *type in typesArray)
    {
        if ([type caseInsensitiveCompare:requestFileType] == NSOrderedSame)
        {
            ACAlertView *alertView = [ACAlertView alertWithTitle:@"Save as..." style:ACAlertViewStyleTextField delegate:self buttonTitles:@[@"Cancel", @"Download"]];
            alertView.textField.text = navigationResponse.response.URL.lastPathComponent;
            [alertView show];
            
            requestURL = navigationResponse.response.URL;
            decisionHandler(WKNavigationResponsePolicyCancel);
            return;
        }
    }
    
    MIMEType = [navigationResponse.response MIMEType];
    
    NSString *mimeTypesPath = [cacheDir stringByAppendingPathComponent:@"MimeTypes.plist"];
    typesArray = [NSArray arrayWithContentsOfFile:mimeTypesPath];
    for (NSString *mime in typesArray)
    {
        if (!MIMEType)
            break;
        if ([MIMEType caseInsensitiveCompare:mime] == NSOrderedSame)
        {
            NSString *fileName = navigationResponse.response.URL.lastPathComponent;

            NSString *UTI = (__bridge NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)MIMEType, NULL);
            NSString *extension = (__bridge NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassFilenameExtension);
            
            if (extension)
                fileName = [fileName stringByAppendingPathExtension:extension];
            
            ACAlertView *alertView = [ACAlertView alertWithTitle:@"Save as..." style:ACAlertViewStyleTextField delegate:self buttonTitles:@[@"Cancel", @"Download"]];
            alertView.textField.text = fileName;
            [alertView show];
            
            requestURL = navigationResponse.response.URL;
            decisionHandler(WKNavigationResponsePolicyCancel);

            return;
        }
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    self.addressTextField.textAlignment = NSTextAlignmentLeft;
    self.addressTextField.text = webView.URL.absoluteString;
    [self setUpToolbar:YES];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self webView:webView didFinishNavigation:navigation];
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
