//
//  ACDownloadTypesController.m
//  ACDownloadManager
//
//  Created by Chris on 1/26/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACDownloadTypesController.h"

@implementation ACDownloadTypesController

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStyleGrouped])
    {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    self.navigationItem.title = @"Downloadable Types";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [cacheDir stringByAppendingPathComponent:@"DownloadTypes.plist"];
    self.typesArray = [NSMutableArray arrayWithContentsOfFile:filePath];
    filePath = [cacheDir stringByAppendingPathComponent:@"MimeTypes.plist"];
    self.mimeTypesArray = [NSMutableArray arrayWithContentsOfFile:filePath];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addType
{
    ACAlertView *alertView = [ACAlertView alertWithTitle:@"New Type" style:ACAlertViewStyleTextFieldAndPickerView delegate:self buttonTitles:@[@"Cancel", @"Add"]];
    alertView.pickerViewItems = @[@"File Extension", @"Mime Type"];
    [alertView show];
}

#pragma mark - Alert View Delegate

- (void)alertView:(ACAlertView *)alertView didClickButtonWithTitle:(NSString *)title
{
    if ([title isEqualToString:@"Cancel"])
        return;
    else
    {
        if ([alertView.pickerViewButton.titleLabel.text isEqualToString:@"File Extension"])
        {
            NSString *type = alertView.textField.text;
            [self.typesArray addObject:type];
            NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *arrayPath = [cacheDir stringByAppendingPathComponent:@"DownloadTypes.plist"];
            [self.typesArray writeToFile:arrayPath atomically:YES];
        }
        else
        {
            NSString *type = alertView.textField.text;
            [self.mimeTypesArray addObject:type];
            NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *arrayPath = [cacheDir stringByAppendingPathComponent:@"MimeTypes.plist"];
            [self.mimeTypesArray writeToFile:arrayPath atomically:YES];
        }

        [alertView dismiss];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return self.typesArray.count;
    else
        return self.mimeTypesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    NSArray *array = @[self.typesArray, self.mimeTypesArray];
    cell.textLabel.text = array[indexPath.section][indexPath.row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (editing)
    {
        UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addType)];
        self.navigationItem.leftBarButtonItem = add;
    }
    else
    {
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (indexPath.section == 0)
        {
            [self.typesArray removeObjectAtIndex:indexPath.row];
            NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *arrayPath = [cacheDir stringByAppendingPathComponent:@"DownloadTypes.plist"];
            [self.typesArray writeToFile:arrayPath atomically:YES];
        }
        else
        {
            [self.mimeTypesArray removeObjectAtIndex:indexPath.row];
            NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *arrayPath = [cacheDir stringByAppendingPathComponent:@"MimeTypes.plist"];
            [self.mimeTypesArray writeToFile:arrayPath atomically:YES];
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
