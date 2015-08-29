//
//  ACiCloudViewController.m
//  Download Manager
//
//  Created by Chris on 3/25/15.
//  Copyright (c) 2015 A and C Studios. All rights reserved.
//

#import "ACiCloudViewController.h"
#import "ACDownloadManager.h"

@implementation ACiCloudViewController
{
    NSIndexPath *selectedIndex;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"iCloud";
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
    ACAlertView *alertView = [[ACAlertView alloc] initWithTitle:@"Re-Download File" style:ACAlertViewStyleTextView delegate:self buttonTitles:@[@"No", @"Yes"]];
    alertView.textView.text = @"Tapping 'Yes' will download this file to your downloads directory. \nNOTE: This will overwrite a file with the same name, should one exist.";
    [alertView show];
}

- (void)alertView:(ACAlertView *)alertView didClickButtonWithTitle:(NSString *)title
{
    [alertView dismiss];
    [self.tableView deselectRowAtIndexPath:selectedIndex animated:YES];

    if ([title isEqualToString:@"No"])
        return;
    else if (![title isEqualToString:@"Yes"])
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
            ACAlertView *errorAlert = [ACAlertView alertWithTitle:@"Error" style:ACAlertViewStyleTextView delegate:nil buttonTitles:@[@"Close"]];
            errorAlert.textView.text = error.localizedDescription;
            [errorAlert show];
        });
        
        return;
    }
    
    NSString *fileURLString = [fileContents componentsSeparatedByString:@"\n"][1];
    
    ACDownloadManager *downloadManager = [[ACDownloadManager alloc] init];
    NSString *alertTitle = [fileContents componentsSeparatedByString:@"\n"][0];
    ACAlertView *downloadAlertView = [ACAlertView alertWithTitle:alertTitle style:ACAlertViewStyleProgressView delegate:downloadManager buttonTitles:@[@"Cancel", @"Hide"]];
    downloadAlertView.progressView.backgroundColor = [UIColor clearColor];
    [downloadAlertView show];
    [downloadManager downloadFileAtURL:[NSURL URLWithString:fileURLString]];
}

@end
