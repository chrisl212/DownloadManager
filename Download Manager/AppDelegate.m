//
//  AppDelegate.m
//  Download Manager
//
//  Created by Chris on 3/17/15.
//  Copyright (c) 2015 A and C Studios. All rights reserved.
//

#import "AppDelegate.h"
#import "ACBrowserViewController.h"
#import "ACDownloadTypesController.h"
#import "ACFileNavigatorKit.framework/Headers/ACRootViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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
    [tabBarController.tabBar setTranslucent:NO];
    
    //each controller needs its own nav controller (other way was tested, failed)
    
    ACBrowserViewController *browserController = [[ACBrowserViewController alloc] init];
    UINavigationController *browserNavController = [[UINavigationController alloc] initWithRootViewController:browserController];
    [browserNavController.navigationBar setTranslucent:NO];
    browserNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Web" image:nil tag:0];

    ACDownloadTypesController *downloadTypes = [[ACDownloadTypesController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *downloadTypesNavController = [[UINavigationController alloc] initWithRootViewController:downloadTypes];
    [downloadTypesNavController.navigationBar setTranslucent:NO];
    downloadTypesNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:nil tag:1];

    ACRootViewController *downloadsViewController = [[ACRootViewController alloc] init];
    UINavigationController *downloadsNavController = [[UINavigationController alloc] initWithRootViewController:downloadsViewController];
    [downloadsNavController.navigationBar setTranslucent:NO];
    downloadsNavController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:2];

    tabBarController.viewControllers = @[browserNavController, downloadsNavController, downloadTypesNavController];

    self.window.rootViewController = tabBarController;
    
    [self.window makeKeyAndVisible];
    
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
