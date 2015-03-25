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

#define RGB(x) x/255.0
#define PRIMARY_COLOR [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Color1"]]
#define SECONDARY_COLOR_1 [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Color2"]]
#define SECONDARY_COLOR_2 [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Color3"]]
#define TERTIARY_COLOR [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Color4"]]


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Color1"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:RGB(52.0) green:RGB(102.0) blue:RGB(153.0) alpha:1.0]] forKey:@"Color1"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:RGB(102.0) green:RGB(102.0) blue:RGB(102.0) alpha:1.0]] forKey:@"Color2"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[UIColor whiteColor]] forKey:@"Color3"];
    
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:RGB(183.0) green:RGB(183.0) blue:RGB(183.0) alpha:1.0]] forKey:@"Color4"];
    }
    
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dlTypesPath = [cacheDir stringByAppendingPathComponent:@"DownloadTypes.plist"];
    NSString *mimeTypesPath = [cacheDir stringByAppendingPathComponent:@"MimeTypes.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dlTypesPath])
    {
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"DownloadTypes" ofType:@"plist"] toPath:dlTypesPath error:nil];
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"MimeTypes" ofType:@"plist"] toPath:mimeTypesPath error:nil];
    }
    
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

    ACRootViewController *downloadsViewController = [[ACRootViewController alloc] init];
    UINavigationController *downloadsNavController = [[UINavigationController alloc] initWithRootViewController:downloadsViewController];
    [downloadsNavController.navigationBar setTranslucent:NO];
    downloadsNavController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:2];

    tabBarController.viewControllers = @[browserNavController, downloadsNavController, settingsNavController];

    self.window.rootViewController = tabBarController;
    
    [self.window makeKeyAndVisible];
    
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
