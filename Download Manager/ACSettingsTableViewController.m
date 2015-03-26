//
//  ACSettingsViewController.m
//  Download Manager
//
//  Created by Chris on 3/17/15.
//  Copyright (c) 2015 A and C Studios. All rights reserved.
//

#import "ACSettingsTableViewController.h"

@implementation ACSettingsTableViewController
{
    NSDictionary *settings;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    settings = @{@"Files" : @[@{@"Downloadable Types" : @"ACDownloadTypesController"}, @{@"Add to iCloud" : @"BOOL"}], @"Appearance" : @[@{@"Color Scheme" : @"ACColorSchemeController"}], @"Support" : @[@{@"Support" : @"WEB VIEW"}]};
    self.navigationItem.title = @"Settings";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return settings.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [settings.allValues[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return settings.allKeys[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    
    cell.textLabel.text = [settings.allValues[indexPath.section][indexPath.row] allKeys][0];
    
    if ([cell.textLabel.text isEqualToString:@"Add to iCloud"])
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *boolSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = boolSwitch;
        boolSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloud"];
        [boolSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryView = nil;
    }
    
    return cell;
}

- (void)switchChanged:(UISwitch *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"iCloud"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *controllerName = [settings.allValues[indexPath.section][indexPath.row] allValues][0];
    
    if ([controllerName isEqualToString:@"WEB VIEW"])
    {
        UIViewController *vc = [[UIViewController alloc] init];
        UIWebView *webView = [[UIWebView alloc] initWithFrame:vc.view.bounds];
        [vc.view addSubview:webView];
        NSURL *supportURL = [NSURL URLWithString:@"http://a-cstudios.com/mydl/support.html"];
        [webView loadRequest:[NSURLRequest requestWithURL:supportURL]];
        webView.scalesPageToFit = YES;
        webView.scrollView.scrollEnabled = NO;
        
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    Class c = NSClassFromString(controllerName);
    id vc = [[c alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
