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
    settings = @{@"Files" : @[@{@"Downloadable Types" : @"ACDownloadTypesController"}, @{@"Add to iCloud" : @"BOOL"}], @"Appearance" : @[@{@"Color Scheme" : @"ACColorSchemeController"}, @{@"Font" : @"ALERT"}, @{@"Homepage" : @"TEXT FIELD"}], @"Support" : @[@{@"Support" : @"WEB VIEW"}]};
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
    else if ([cell.textLabel.text isEqualToString:@"Homepage"])
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.textLabel.text = [settings.allValues[indexPath.section][indexPath.row] allKeys][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.detailTextLabel.hidden = YES;
        [[cell viewWithTag:3] removeFromSuperview];
        UITextField *textField = [[UITextField alloc] init];
        
        textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"homepage"];
        textField.keyboardType = UIKeyboardTypeURL;
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
        textField.delegate = self;
        
        [textField addTarget:textField action:@selector(resignFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
    }
    else if ([cell.textLabel.text isEqualToString:@"Font"])
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.textLabel.text = @"Font";
        cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"font"];
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:@"homepage"];
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
    else if ([controllerName isEqualToString:@"TEXT FIELD"])
        return;
    else if ([controllerName isEqualToString:@"ALERT"])
    {
        ACAlertView *alertView = [ACAlertView alertWithTitle:@"Font" style:ACAlertViewStylePickerView delegate:self buttonTitles:@[@"Cancel", @"Reset", @"OK"]];
        alertView.pickerViewItems = [self fonts];
        
        [alertView show];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    Class c = NSClassFromString(controllerName);
    id vc = [[c alloc] init];
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

@end
