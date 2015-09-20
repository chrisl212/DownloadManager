//
//  AppDelegate.m
//  Download Manager
//
//  Created by Chris on 3/17/15.
//  Copyright (c) 2015 A and C Studios. All rights reserved.
//

#import "AppDelegate.h"
#import "ACBrowserViewController.h"
#import "ACSettingsTableViewController.h"
#import "ACiCloudViewController.h"
#import <CLFileNavigatorKit/CLFileNavigatorKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <iAd/iAd.h>
#import "ACTextField.h"

#define RGB(x) x/255.0
#define PRIMARY_COLOR [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Color1"]]
#define SECONDARY_COLOR_1 [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Color2"]]
#define SECONDARY_COLOR_2 [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Color3"]]
#define TERTIARY_COLOR [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Color4"]]


@implementation AppDelegate
{
    CLDirectoryViewController *downloadsViewController;
    SKProduct *fullFeaturesProduct;
}

- (NSString *)iCloudPath
{
    NSURL *uu = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    return [[uu path] stringByAppendingPathComponent:@"Documents"];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Color1"]) //first launch
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:RGB(170.0) green:RGB(57.0) blue:RGB(57.0) alpha:1.0]] forKey:@"Color1"];

        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:RGB(102.0) green:RGB(102.0) blue:RGB(102.0) alpha:1.0]] forKey:@"Color2"];
            
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[UIColor whiteColor]] forKey:@"Color3"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:RGB(210.0) green:RGB(210.0) blue:RGB(210.0) alpha:1.0]] forKey:@"Color4"];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"iCloud"];
        [[NSUserDefaults standardUserDefaults] setObject:@"https://google.com" forKey:@"homepage"];
        [[NSUserDefaults standardUserDefaults] setObject:@"Google" forKey:@"search engine"];
        [[NSUserDefaults standardUserDefaults] setObject:@"Modification" forKey:@"date"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"thumbnails"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"purchased"])
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"purchased"];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"thumbnails"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"thumbnails"];
        [[NSUserDefaults standardUserDefaults] setObject:@"Modification" forKey:@"date"];
    }
    
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:applicationFrame];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    //each controller needs its own nav controller (other way was tested, failed)
    [self setAppearances];

    ACBrowserViewController *browserController = [[ACBrowserViewController alloc] init];
    UINavigationController *browserNavController = [[UINavigationController alloc] initWithRootViewController:browserController];
    [browserNavController.navigationBar setTranslucent:NO];
    browserNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Internet" image:[UIImage imageNamed:@"domain-50.png"] tag:0];
    browserNavController.tabBarItem.selectedImage = [UIImage imageNamed:@"domain_filled-50.png"];
    
    ACSettingsTableViewController *settingsViewController = [[ACSettingsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    [settingsNavController.navigationBar setTranslucent:NO];
    settingsNavController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:2];

    downloadsViewController = [[CLDirectoryViewController alloc] init];
    UINavigationController *downloadsNavController = [[UINavigationController alloc] initWithRootViewController:downloadsViewController];
    [downloadsNavController.navigationBar setTranslucent:NO];
    downloadsNavController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:2];
    if (![[self allFeaturesUnlocked] boolValue])
    {
        downloadsViewController.tableView.tableHeaderView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        downloadsViewController.tableView.tableFooterView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    }
    
    ACiCloudViewController *iCloudViewController = [[ACiCloudViewController alloc] initWithDirectoryPath:[self iCloudPath]];
    UINavigationController *iCloudNavController = [[UINavigationController alloc] initWithRootViewController:iCloudViewController];
    [iCloudNavController.navigationBar setTranslucent:NO];
    iCloudNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"iCloud" image:[UIImage imageNamed:@"cloud_storage-50.png"] tag:3];
    iCloudNavController.tabBarItem.selectedImage = [UIImage imageNamed:@"cloud_storage_filled-50.png"];
    if (![[self allFeaturesUnlocked] boolValue])
    {
        iCloudViewController.tableView.tableHeaderView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        iCloudViewController.tableView.tableFooterView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    }
        
    tabBarController.viewControllers = @[browserNavController, downloadsNavController, iCloudNavController, settingsNavController];

    self.window.rootViewController = tabBarController;
    
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAppearances) name:@"appearance" object:nil];

    NSArray *productIDs = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"InAppPurchases" ofType:@"plist"]];
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIDs]];
    productsRequest.delegate = self;
    [productsRequest start];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    return YES;
}

- (void)setAppearances
{
    [[UILabel appearance] setTextColor:SECONDARY_COLOR_1];
    [[UIBarButtonItem appearance] setTintColor:SECONDARY_COLOR_2];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UITextField appearance] setTintColor:SECONDARY_COLOR_1];
    [[UIToolbar appearance] setBarTintColor:PRIMARY_COLOR];
    [[UIToolbar appearance] setTintColor:SECONDARY_COLOR_2];
    [[UIButton appearance] setTintColor:PRIMARY_COLOR];
    [[UINavigationBar appearance] setTintColor:SECONDARY_COLOR_2];
    [[UIActionSheet appearance] setTintColor:SECONDARY_COLOR_1];
    [[UITextView appearance] setTintColor:SECONDARY_COLOR_1];
    [[UISegmentedControl appearance] setTintColor:PRIMARY_COLOR];
    [[UIProgressView appearance] setTintColor:SECONDARY_COLOR_1];
    NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName : SECONDARY_COLOR_2};
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    [[UITabBar appearance] setBarTintColor:SECONDARY_COLOR_1];
    [[UITabBar appearance] setTintColor:SECONDARY_COLOR_2];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UIToolbar appearance] setTranslucent:NO];
    [[UIBarButtonItem appearance] setTintColor:SECONDARY_COLOR_2];
    [[ACTextField appearance] setTextFieldTintColor:TERTIARY_COLOR];
    [[UISwitch appearance] setOnTintColor:PRIMARY_COLOR];
    
    [[UISlider appearance] setTintColor:SECONDARY_COLOR_1];
    [[UISlider appearance] setMinimumTrackTintColor:PRIMARY_COLOR];
    [[UINavigationBar appearance] setBarTintColor:PRIMARY_COLOR];
    [[MPVolumeView appearance] setTintColor:PRIMARY_COLOR];
    [[UISlider appearance] setMaximumTrackTintColor:SECONDARY_COLOR_1];
    [[UITableViewCell appearance] setTintColor:PRIMARY_COLOR];
    
    [self.window setBackgroundColor:SECONDARY_COLOR_2];
    [self.window setTintColor:SECONDARY_COLOR_2];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:url.lastPathComponent];
    
    NSError *error;
    if (![[NSFileManager defaultManager] copyItemAtPath:url.path toPath:filePath error:&error])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            ACAlertView *errorAlert = [ACAlertView alertWithTitle:@"Error" style:ACAlertViewStyleTextView delegate:nil buttonTitles:@[@"Close"]];
            errorAlert.textView.text = error.localizedDescription;
            [errorAlert show];
        });

        return NO;
    }
    
    NSString *inboxFile = [[documentsDirectory stringByAppendingPathComponent:@"Inbox"] stringByAppendingPathComponent:filePath.lastPathComponent];

    [[NSFileManager defaultManager] removeItemAtPath:inboxFile error:&error];
    if (error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            ACAlertView *errorAlert = [ACAlertView alertWithTitle:@"Error" style:ACAlertViewStyleTextView delegate:nil buttonTitles:@[@"Close"]];
            errorAlert.textView.text = error.localizedDescription;
            [errorAlert show];
        });
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CLDirectoryViewControllerRefreshNotification object:nil];

    return YES;
}

- (NSNumber *)allFeaturesUnlocked
{
/*
 NSURL *URL = [[NSBundle mainBundle] appStoreReceiptURL];
 if (![URL checkResourceIsReachableAndReturnError:nil])
 return @(NO);
 NSData *data = [NSData dataWithContentsOfURL:URL];
 BIO *receiptBIO = BIO_new(BIO_s_mem());
 BIO_write(receiptBIO, [data bytes], (int) [data length]);
 PKCS7 *receiptPKCS7 = d2i_PKCS7_bio(receiptBIO, NULL);
 if (!receiptPKCS7)
 {
 return @(NO);
 }
 
 // Check that the container has a signature
 if (!PKCS7_type_is_signed(receiptPKCS7))
 {
 return @(NO);
 }
 
 // Check that the signed container has actual data
 if (!PKCS7_type_is_data(receiptPKCS7->d.sign->contents))
 {
 return @(NO);
 }
 NSURL *appleRootURL = [[NSBundle mainBundle] URLForResource:@"AppleIncRootCertificate" withExtension:@"cer"];
 NSData *appleRootData = [NSData dataWithContentsOfURL:appleRootURL];
 BIO *appleRootBIO = BIO_new(BIO_s_mem());
 BIO_write(appleRootBIO, (const void *) [appleRootData bytes], (int) [appleRootData length]);
 X509 *appleRootX509 = d2i_X509_bio(appleRootBIO, NULL);
 
 // Create a certificate store
 X509_STORE *store = X509_STORE_new();
 X509_STORE_add_cert(store, appleRootX509);
 
 // Be sure to load the digests before the verification
 OpenSSL_add_all_digests();
 
 // Check the signature
 int result = PKCS7_verify(receiptPKCS7, NULL, store, NULL, NULL, 0);
 if (result != 1)
 {
 return @(NO);
 }
 
 ASN1_OCTET_STRING *octets = receiptPKCS7->d.sign->contents->d.data;
 const unsigned char *ptr = octets->data;
 const unsigned char *end = ptr + octets->length;
 const unsigned char *str_ptr;
 
 int type = 0, str_type = 0;
 int xclass = 0, str_xclass = 0;
 long length = 0, str_length = 0;
 
 // Store for the receipt information
 NSString *bundleIdString = nil;
 NSString *bundleVersionString = nil;
 NSData *bundleIdData = nil;
 NSData *hashData = nil;
 NSData *opaqueData = nil;
 NSDate *expirationDate = nil;
 
 // Date formatter to handle RFC 3339 dates in GMT time zone
 NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
 [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
 [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
 
 // Decode payload (a SET is expected)
 ASN1_get_object(&ptr, &length, &type, &xclass, end - ptr);
 if (type != V_ASN1_SET)
 {
 return @(NO);
 }
 
 while (ptr < end)
 {
 ASN1_INTEGER *integer;
 
 // Parse the attribute sequence (a SEQUENCE is expected)
 ASN1_get_object(&ptr, &length, &type, &xclass, end - ptr);
 if (type != V_ASN1_SEQUENCE)
 {
 return @(NO);
 }
 
 const unsigned char *seq_end = ptr + length;
 long attr_type = 0;
 long attr_version = 0;
 
 // Parse the attribute type (an INTEGER is expected)
 ASN1_get_object(&ptr, &length, &type, &xclass, end - ptr);
 if (type != V_ASN1_INTEGER)
 {
 return @(NO);
 }
 integer = c2i_ASN1_INTEGER(NULL, &ptr, length);
 attr_type = ASN1_INTEGER_get(integer);
 ASN1_INTEGER_free(integer);
 
 // Parse the attribute version (an INTEGER is expected)
 ASN1_get_object(&ptr, &length, &type, &xclass, end - ptr);
 if (type != V_ASN1_INTEGER)
 {
 return @(NO);
 }
 integer = c2i_ASN1_INTEGER(NULL, &ptr, length);
 attr_version = ASN1_INTEGER_get(integer);
 ASN1_INTEGER_free(integer);
 
 // Check the attribute value (an OCTET STRING is expected)
 ASN1_get_object(&ptr, &length, &type, &xclass, end - ptr);
 if (type != V_ASN1_OCTET_STRING)
 {
 return @(NO);
 }
 
 switch (attr_type)
 {
 case 2:
 // Bundle identifier
 str_ptr = ptr;
 ASN1_get_object(&str_ptr, &str_length, &str_type, &str_xclass, seq_end - str_ptr);
 if (str_type == V_ASN1_UTF8STRING)
 {
 // We store both the decoded string and the raw data for later
 // The raw is data will be used when computing the GUID hash
 bundleIdString = [[NSString alloc] initWithBytes:str_ptr length:str_length encoding:NSUTF8StringEncoding];
 bundleIdData = [[NSData alloc] initWithBytes:(const void *)ptr length:length];
 }
 break;
 
 case 3:
 // Bundle version
 str_ptr = ptr;
 ASN1_get_object(&str_ptr, &str_length, &str_type, &str_xclass, seq_end - str_ptr);
 if (str_type == V_ASN1_UTF8STRING)
 {
 // We store the decoded string for later
 bundleVersionString = [[NSString alloc] initWithBytes:str_ptr length:str_length encoding:NSUTF8StringEncoding];
 }
 break;
 
 case 4:
 // Opaque value
 opaqueData = [[NSData alloc] initWithBytes:(const void *)ptr length:length];
 break;
 
 case 5:
 // Computed GUID (SHA-1 Hash)
 hashData = [[NSData alloc] initWithBytes:(const void *)ptr length:length];
 break;
 
 case 21:
 // Expiration date
 str_ptr = ptr;
 ASN1_get_object(&str_ptr, &str_length, &str_type, &str_xclass, seq_end - str_ptr);
 if (str_type == V_ASN1_IA5STRING)
 {
 // The date is stored as a string that needs to be parsed
 NSString *dateString = [[NSString alloc] initWithBytes:str_ptr length:str_length encoding:NSASCIIStringEncoding];
 expirationDate = [formatter dateFromString:dateString];
 }
 break;
 
 // You can parse more attributes...
 
 default:
 break;
 }
 
 // Move past the value
 ptr += length;
 }
 
 // Be sure that all information is present
 if (bundleIdString == nil ||
 bundleVersionString == nil ||
 opaqueData == nil ||
 hashData == nil)
 {
 return @(NO);
 }
 UIDevice *device = [UIDevice currentDevice];
 NSUUID *identifier = [device identifierForVendor];
 uuid_t uuid;
 [identifier getUUIDBytes:uuid];
 NSData *guidData = [NSData dataWithBytes:(const void *)uuid length:16];
 unsigned char hash[20];
 
 // Create a hashing context for computation
 SHA_CTX ctx;
 SHA1_Init(&ctx);
 SHA1_Update(&ctx, [guidData bytes], (size_t) [guidData length]);
 SHA1_Update(&ctx, [opaqueData bytes], (size_t) [opaqueData length]);
 SHA1_Update(&ctx, [bundleIdData bytes], (size_t) [bundleIdData length]);
 SHA1_Final(hash, &ctx);
 
 // Do the comparison
 NSData *computedHashData = [NSData dataWithBytes:hash length:20];
 if (![computedHashData isEqualToData:hashData])
 {
 return @(NO);
 }
 */
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"purchased"])
        return @(NO);
    return @([[[NSUserDefaults standardUserDefaults] objectForKey:@"purchased"] isEqualToString:@"YES"]);
}

- (void)restorePurchase
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)unlockFeatures
{
    if (!fullFeaturesProduct)
        return;
    SKPayment *payment = [SKPayment paymentWithProduct:fullFeaturesProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    fullFeaturesProduct = response.products[0];
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    NSLog(@"%@", transactions);
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"purchased"];
    downloadsViewController.tableView.tableHeaderView = downloadsViewController.searchController.searchBar;
    downloadsViewController.tableView.tableFooterView = downloadsViewController.tableFooter;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        if (transaction.transactionState == SKPaymentTransactionStatePurchased || transaction.transactionState == SKPaymentTransactionStateRestored || transaction.transactionState)
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"purchased"];
            downloadsViewController.tableView.tableHeaderView = downloadsViewController.searchController.searchBar;
            downloadsViewController.tableView.tableFooterView = downloadsViewController.tableFooter;
        }
        else
            NSLog(@"NOT BOUGHT");
        if (transaction.transactionState != SKPaymentTransactionStatePurchasing)
            [queue finishTransaction:transaction];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

@interface CLAudioPlayerViewController (SliderColor)

@end

@implementation CLAudioPlayerViewController (SliderColor)

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for (UISlider *slider in self.view.subviews)
        if ([slider isKindOfClass:[UISlider class]])
        {
            slider.maximumTrackTintColor = SECONDARY_COLOR_1;
            slider.minimumTrackTintColor = PRIMARY_COLOR;
        }
    for (UISlider *slider in self.volumeSlider.subviews)
        if ([slider isKindOfClass:[UISlider class]])
        {
            slider.maximumTrackTintColor = SECONDARY_COLOR_1;
            slider.minimumTrackTintColor = PRIMARY_COLOR;
        }
}

@end

@interface CLDirectoryViewController (Options)

@end

@implementation CLDirectoryViewController (Options)

- (NSDictionary *)options
{
    return @{CLDirectoryViewControllerDisplayThumbnailsOption: @([[NSUserDefaults standardUserDefaults] boolForKey:@"thumbnails"]), CLDirectoryViewControllerDateDisplayOption: [[NSUserDefaults standardUserDefaults] objectForKey:@"date"]};
}

@end