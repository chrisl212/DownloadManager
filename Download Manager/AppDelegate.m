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
#import <ACFileNavigatorKit/ACRootViewController.h>
#import "ACiCloudViewController.h"

#define RGB(x) x/255.0
#define PRIMARY_COLOR [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Color1"]]
#define SECONDARY_COLOR_1 [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Color2"]]
#define SECONDARY_COLOR_2 [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Color3"]]
#define TERTIARY_COLOR [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Color4"]]


@implementation AppDelegate
{
    ACRootViewController *downloadsViewController;
}

- (NSString *)iCloudPath
{
    NSURL *uu = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    return [[uu path] stringByAppendingPathComponent:@"Documents"];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Color1"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:RGB(52.0) green:RGB(102.0) blue:RGB(153.0) alpha:1.0]] forKey:@"Color1"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:RGB(102.0) green:RGB(102.0) blue:RGB(102.0) alpha:1.0]] forKey:@"Color2"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[UIColor whiteColor]] forKey:@"Color3"];
    
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:RGB(183.0) green:RGB(183.0) blue:RGB(183.0) alpha:1.0]] forKey:@"Color4"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"iCloud"];
        [[NSUserDefaults standardUserDefaults] setObject:@"https://google.com" forKey:@"homepage"];
    }
    
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dlTypesPath = [cacheDir stringByAppendingPathComponent:@"DownloadTypes.plist"];
    NSString *mimeTypesPath = [cacheDir stringByAppendingPathComponent:@"MimeTypes.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dlTypesPath])
    {
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"DownloadTypes" ofType:@"plist"] toPath:dlTypesPath error:nil];
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"MimeTypes" ofType:@"plist"] toPath:mimeTypesPath error:nil];
    }
    
    //directory for iCloud files
    //NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //NSString *iCloudDirectoryPath = [documentsDirectory stringByAppendingPathComponent:@".iCloud"];
    //if (![[NSFileManager defaultManager] fileExistsAtPath:iCloudDirectoryPath])
        //[[NSFileManager defaultManager] createDirectoryAtPath:iCloudDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtURL:[NSURL fileURLWithPath:[self iCloudPath]] toURL:[NSURL fileURLWithPath:iCloudDirectoryPath] error:&error];
        if (error)
            NSLog(@"%@", error);
    } ); */
    
    
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:applicationFrame];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.tabBar.barTintColor = SECONDARY_COLOR_1;
    
    //each controller needs its own nav controller (other way was tested, failed)
    
    ACBrowserViewController *browserController = [[ACBrowserViewController alloc] init];
    UINavigationController *browserNavController = [[UINavigationController alloc] initWithRootViewController:browserController];
    [browserNavController.navigationBar setTranslucent:NO];
    browserNavController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];

    ACSettingsTableViewController *settingsViewController = [[ACSettingsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    [settingsNavController.navigationBar setTranslucent:NO];
    settingsNavController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:2];

    downloadsViewController = [[ACRootViewController alloc] init];
    UINavigationController *downloadsNavController = [[UINavigationController alloc] initWithRootViewController:downloadsViewController];
    [downloadsNavController.navigationBar setTranslucent:NO];
    downloadsNavController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:2];
    
    ACiCloudViewController *iCloudViewController = [[ACiCloudViewController alloc] initWithDirectoryPath:[self iCloudPath]];
    UINavigationController *iCloudNavController = [[UINavigationController alloc] initWithRootViewController:iCloudViewController];
    [iCloudNavController.navigationBar setTranslucent:NO];
    iCloudNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"iCloud" image:[UIImage imageNamed:@"Cloud-Tab.png"] tag:3];

    tabBarController.viewControllers = @[browserNavController, downloadsNavController, iCloudNavController, settingsNavController];

    self.window.rootViewController = tabBarController;
    
    [self.window makeKeyAndVisible];
    
    [self setAppearances];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAppearances) name:@"appearance" object:nil];
    
    return YES;
}

- (void)setAppearances
{
    [[UILabel appearance] setTextColor:SECONDARY_COLOR_1];
    [self.window setTintColor:SECONDARY_COLOR_2];
    [[UIBarButtonItem appearance] setTintColor:SECONDARY_COLOR_2];
    [[UINavigationBar appearance] setBarTintColor:PRIMARY_COLOR];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UITextField appearance] setTintColor:SECONDARY_COLOR_1];
    [[UIToolbar appearance] setBarTintColor:TERTIARY_COLOR];
    [[UIButton appearance] setTintColor:SECONDARY_COLOR_2];
    [[UIActionSheet appearance] setTintColor:SECONDARY_COLOR_1];
    [[UITextView appearance] setTintColor:SECONDARY_COLOR_1];
    
    NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName : SECONDARY_COLOR_2};
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
    [self.window setBackgroundColor:SECONDARY_COLOR_2];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:url.lastPathComponent];
    
    NSError *error;
    if (![[NSFileManager defaultManager] copyItemAtPath:url.path toPath:filePath error:&error])
    {
        ACAlertView *alertView = [ACAlertView alertWithTitle:@"Error" style:ACAlertViewStyleTextView delegate:nil buttonTitles:@[@"Dismiss"]];
        alertView.textView.text = error.description;
        return NO;
    }
    
    NSString *inboxFile = [[documentsDirectory stringByAppendingPathComponent:@"Inbox"] stringByAppendingPathComponent:filePath.lastPathComponent];
    [[NSFileManager defaultManager] removeItemAtPath:inboxFile error:nil];
    
    [downloadsViewController updateFiles];
    [downloadsViewController.tableView reloadData];
    
    return YES;
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
