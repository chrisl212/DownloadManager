//
//  ACiCloudViewController.m
//  Download Manager
//
//  Created by Chris on 3/25/15.
//  Copyright (c) 2015 A and C Studios. All rights reserved.
//

#import "ACiCloudViewController.h"
#import "ACDownloadManager.h"
#import "AppDelegate.h"

@implementation ACiCloudViewController
{
    NSIndexPath *selectedIndex;
}

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"iCloud";
    if ([[[self appDelegate] allFeaturesUnlocked] boolValue])
    {
        self.tableView.tableHeaderView = self.searchController.searchBar;
        self.tableView.tableFooterView = [self tableFooter];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing)
        return;
    selectedIndex = indexPath;
    ACAlertView *alertView = [[ACAlertView alloc] initWithTitle:NSLocalizedString(@"Redownload", NULL) style:ACAlertViewStyleTextView delegate:self buttonTitles:@[NSLocalizedString(@"No", NULL), NSLocalizedString(@"Yes", NULL)]];
    alertView.textView.text = NSLocalizedString(@"RedownloadBody", NULL);
    [alertView show];
}

- (void)alertView:(ACAlertView *)alertView didClickButtonWithTitle:(NSString *)title
{
    [alertView dismiss];
    [self.tableView deselectRowAtIndexPath:selectedIndex animated:YES];

    if ([title isEqualToString:NSLocalizedString(@"No", NULL)])
        return;
    else if (![title isEqualToString:NSLocalizedString(@"Yes", NULL)])
    {
        [super alertView:alertView didClickButtonWithTitle:title];
        return;
    }
    
    CLFile *file = self.files[selectedIndex.row];
    
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:file.filePath encoding:NSUTF8StringEncoding error:&error];
    if (error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            ACAlertView *errorAlert = [ACAlertView alertWithTitle:NSLocalizedString(@"Error", NULL) style:ACAlertViewStyleTextView delegate:nil buttonTitles:@[NSLocalizedString(@"Close", NULL)]];
            errorAlert.textView.text = error.localizedDescription;
            [errorAlert show];
        });
        
        return;
    }
    
    NSString *fileURLString = [fileContents componentsSeparatedByString:@"\n"][1];
    
    ACDownloadManager *downloadManager = [[ACDownloadManager alloc] init];
    NSString *alertTitle = [fileContents componentsSeparatedByString:@"\n"][0];
    ACAlertView *downloadAlertView = [ACAlertView alertWithTitle:alertTitle style:ACAlertViewStyleProgressView delegate:downloadManager buttonTitles:@[NSLocalizedString(@"Cancel", NULL), NSLocalizedString(@"Hide", NULL)]];
    downloadAlertView.progressView.backgroundColor = [UIColor clearColor];
    [downloadAlertView show];
    [downloadManager downloadFileAtURL:[NSURL URLWithString:fileURLString]];
}

@end
