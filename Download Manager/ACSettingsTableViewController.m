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
    settings = @{@"Files" : @[@{@"Downloadable Types" : @"ACDownloadTypesController"}], @"Appearance" : @[@{@"Color Scheme" : @"ACColorSchemeController"}]};
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *controllerName = [settings.allValues[indexPath.section][indexPath.row] allValues][0];
    Class c = NSClassFromString(controllerName);
    id vc = [[c alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
