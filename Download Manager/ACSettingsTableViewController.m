//
//  ACSettingsViewController.m
//  Download Manager
//
//  Created by Chris on 3/17/15.
//  Copyright (c) 2015 A and C Studios. All rights reserved.
//

#import "ACSettingsTableViewController.h"
#import "AppDelegate.h"

NSString *const ACSettingsViewControllerKey = @"vc";
NSString *const ACSettingsSwitchKey = @"switch";
NSString *const ACSettingsTextFieldKey = @"text";
NSString *const ACSettingsSegmentedControlKey = @"segment";
NSString *const ACSettingsWebViewKey = @"web";
NSString *const ACSettingsButtonKey = @"button";

@implementation ACSettingsTableViewController
{
    NSArray *settings;
}

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary *fileSettings =
  @{@"name" : @"Files", @"items" : @[
            @{@"name" : @"Downloadable Types", @"type" : ACSettingsViewControllerKey, @"controller" : @"ACDownloadTypesController", @"requiresPurchase" : @(YES)},
            @{@"name" : @"Add to iCloud", @"type" : ACSettingsSwitchKey, @"selector" : @"toggleiCloudSettings:", @"state" : @([[NSUserDefaults standardUserDefaults] boolForKey:@"iCloud"]), @"requiresPurchase" : @(NO)},
            @{@"name" : @"Thumbnails", @"type" : ACSettingsSwitchKey, @"selector" : @"toggleThumbnails:", @"state" : @([[NSUserDefaults standardUserDefaults] boolForKey:@"thumbnails"]), @"requiresPurchase" : @(YES)},
            @{@"name" : @"Dates", @"type" : ACSettingsSegmentedControlKey, @"selector" : @"changeDateDisplay:", @"values" : @[@"Creation", @"Modification"], @"selectedValue" : [[NSUserDefaults standardUserDefaults] objectForKey:@"date"], @"requiresPurchase" : @(YES)},
            @{@"name" : @"Clear Cache", @"type" : ACSettingsButtonKey, @"selector" : @"clearCache", @"requiresPurchase" : @(NO)}
            ]};
    
    NSDictionary *appearanceSettings =
  @{@"name" : @"Appearance", @"items" : @[
            @{@"name" : @"Color Scheme", @"type" : ACSettingsViewControllerKey, @"controller" : @"ACColorSchemeController", @"requiresPurchase" : @(YES)},
            @{@"name" : @"Homepage", @"type" : ACSettingsTextFieldKey, @"selector" : @"changeHomepage:", @"value" : [[NSUserDefaults standardUserDefaults] objectForKey:@"homepage"], @"keyboard" : @(UIKeyboardTypeURL), @"requiresPurchase" : @(YES)},
            @{@"name" : @"Search Engine", @"type" : ACSettingsSegmentedControlKey, @"selector" : @"changeSearchEngine:", @"values" : @[@"Google", @"Yahoo", @"Bing"], @"selectedValue" : [[NSUserDefaults standardUserDefaults] objectForKey:@"search engine"], @"requiresPurchase" : @(YES)}
            ]};
    
    NSDictionary *supportSettings =
  @{@"name" : @"Support", @"items" : @[
            @{@"name" : @"Contact", @"type" : ACSettingsWebViewKey, @"url" : @"http://a-cstudios.com/mydl/support.html", @"requiresPurchase" : @(NO)},
            @{@"name" : @"Unlock all features", @"type" : ACSettingsButtonKey, @"selector" : @"unlockFeatures", @"requiresPurchase" : @(NO)}
            /*@{@"name" : @"Restore purchase", @"type" : ACSettingsButtonKey, @"selector" : @"restorePurchase", @"requiresPurchase" : @(NO)}*/
            //@{@"name" : @"Source Code", @"type" : ACSettingsWebViewKey, @"url" : @"https://github.com/chrisl212/DownloadManager"}
            ]};
    
    settings = @[fileSettings, appearanceSettings, supportSettings];
    self.navigationItem.title = @"Settings";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return settings.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [settings[section][@"items"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return settings[section][@"name"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    
    NSDictionary *cellDictionary = settings[indexPath.section][@"items"][indexPath.row];
    NSString *cellType = cellDictionary[@"type"];
    
    cell.textLabel.text = cellDictionary[@"name"];
    
    if ([cellType isEqualToString:ACSettingsSwitchKey])
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *boolSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = boolSwitch;
        boolSwitch.on = [cellDictionary[@"state"] boolValue];
        [boolSwitch addTarget:self action:NSSelectorFromString(cellDictionary[@"selector"]) forControlEvents:UIControlEventValueChanged];
    }
    else if ([cellType isEqualToString:ACSettingsTextFieldKey])
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.detailTextLabel.hidden = YES;
        [[cell viewWithTag:3] removeFromSuperview];
        UITextField *textField = [[UITextField alloc] init];
        
        textField.text = cellDictionary[@"value"];
        textField.keyboardType = [cellDictionary[@"keyboard"] integerValue];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        textField.tag = 3;
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:textField];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.textLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:8]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:8]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-8]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-16]];
        textField.textAlignment = NSTextAlignmentRight;
        
        [textField addTarget:self action:NSSelectorFromString(cellDictionary[@"selector"]) forControlEvents:UIControlEventEditingDidEnd];
        [textField addTarget:textField action:@selector(resignFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
    }
    else if ([cellType isEqualToString:ACSettingsSegmentedControlKey])
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:cellDictionary[@"values"]];
        [segment addTarget:self action:NSSelectorFromString(cellDictionary[@"selector"]) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = segment;
        
        NSDictionary *titleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12.0]};
        [segment setTitleTextAttributes:titleAttributes forState:UIControlStateNormal];
        
        NSString *selectedValue = cellDictionary[@"selectedValue"];
        for (int i = 0; i < [cellDictionary[@"values"] count]; i++)
            if ([[segment titleForSegmentAtIndex:i] isEqualToString:selectedValue])
                [segment setSelectedSegmentIndex:i];
    }
    else if ([cellType isEqualToString:ACSettingsViewControllerKey] || [cellType isEqualToString:ACSettingsWebViewKey])
    {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if ([cellType isEqualToString:ACSettingsButtonKey])
    {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    BOOL requiresPurchase = [cellDictionary[@"requiresPurchase"] boolValue];
    if (![[[self appDelegate] allFeaturesUnlocked] boolValue])
    {
        if (requiresPurchase)
        {
            if (cell.accessoryView && [cell.accessoryView isKindOfClass:[UIControl class]])
                [(UIControl *)cell.accessoryView setEnabled:NO];
            cell.textLabel.enabled = NO;
            cell.userInteractionEnabled = NO;
        }
        else
        {
            if (cell.accessoryView && [cell.accessoryView isKindOfClass:[UIControl class]])
                [(UIControl *)cell.accessoryView setEnabled:YES];
            cell.textLabel.enabled = YES;
            cell.userInteractionEnabled = YES;
        }
    }
    else
    {
        if (cell.accessoryView && [cell.accessoryView isKindOfClass:[UIControl class]])
            [(UIControl *)cell.accessoryView setEnabled:YES];
        cell.textLabel.enabled = YES;
        cell.userInteractionEnabled = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *cellDictionary = settings[indexPath.section][@"items"][indexPath.row];
    NSString *cellType = cellDictionary[@"type"];
    
    id vc = nil;
    
    if ([cellType isEqualToString:ACSettingsTextFieldKey] || [cellType isEqualToString:ACSettingsSegmentedControlKey] || [cellType isEqualToString:ACSettingsSwitchKey])
        return;
    else if ([cellType isEqualToString:ACSettingsButtonKey])
    {
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:NSSelectorFromString(cellDictionary[@"selector"])];
        return;
    }
    else if ([cellType isEqualToString:ACSettingsWebViewKey])
    {
        UIViewController *webViewController = [[UIViewController alloc] init];
        UIWebView *webView = [[UIWebView alloc] initWithFrame:webViewController.view.bounds];
        [webViewController.view addSubview:webView];
        NSURL *URL = [NSURL URLWithString:cellDictionary[@"url"]];
        [webView loadRequest:[NSURLRequest requestWithURL:URL]];
        webView.scalesPageToFit = YES;
        //webView.scrollView.scrollEnabled = NO;
        vc = webViewController;
    }
    else if ([cellType isEqualToString:ACSettingsViewControllerKey])
    {
        Class c = NSClassFromString(cellDictionary[@"controller"]);
        vc = [[c alloc] init];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)alertView:(ACAlertView *)alertView didClickButtonWithTitle:(NSString *)title
{
    if ([title isEqualToString:@"Reset"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"Arial" forKey:@"font"];
    }
    else if ([title isEqualToString:@"OK"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:alertView.pickerViewButton.titleLabel.text forKey:@"font"];
    }
    
    [alertView dismiss];
}

- (NSArray *)fonts
{
    NSMutableArray *fonts = [NSMutableArray array];
    
    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
    NSArray *fontNames;
    NSInteger indFamily;
    for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
    {
        fontNames = [[NSArray alloc] initWithArray:
                     [UIFont fontNamesForFamilyName:
                      [familyNames objectAtIndex:indFamily]]];
        [fonts addObjectsFromArray:fontNames];
    }
    return [NSArray arrayWithArray:fonts];
}

#pragma mark - Cell Actions

- (void)restorePurchase
{
    [[self appDelegate] restorePurchase];
}

- (void)unlockFeatures
{
    [[self appDelegate] unlockFeatures];
}

- (void)clearCache
{
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachesDirectory error:nil];
    for (NSString *fileName in directoryContents)
    {
        NSString *filePath = [cachesDirectory stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

- (void)changeDateDisplay:(UISegmentedControl *)sender
{
    NSArray *items = @[@"Creation", @"Modification"];
    [[NSUserDefaults standardUserDefaults] setObject:items[[sender selectedSegmentIndex]] forKey:@"date"];
}

- (void)changeSearchEngine:(UISegmentedControl *)sender
{
    NSArray *items = @[@"Google", @"Yahoo", @"Bing"];
    [[NSUserDefaults standardUserDefaults] setObject:items[[sender selectedSegmentIndex]] forKey:@"search engine"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"searchEngine" object:nil]; //for updating browser address text field placeholder
}

- (void)changeHomepage:(UITextField *)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:sender.text forKey:@"homepage"];
}

- (void)toggleiCloudSettings:(UISwitch *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"iCloud"];
}

- (void)toggleThumbnails:(UISwitch *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"thumbnails"];
}

@end
