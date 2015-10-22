//
//  ACDownloadManager.m
//  ACDownloadManager
//
//  Created by Chris on 1/25/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACDownloadManager.h"
#import <CLFileNavigatorKit/CLFileNavigatorKit.h>
#import "AppDelegate.h"

@implementation ACDownloadManager
{
    UILabel *downloadLabel;
    NSTimer *timeElapsedTimer;
    NSTimeInterval elapsedTime;
    CGFloat previousSize;
}

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (NSString *)iCloudPath
{
    NSURL *uu = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    return [[uu path] stringByAppendingPathComponent:@"Documents"];
}

- (id)init
{
    if (self = [super init])
    {
        self.data = [NSMutableData data];
        self.downloadedSize = 0;
    }
    return self;
}

- (void)downloadFileAtURL:(NSURL *)url
{
    for (ACAlertView *alert in [UIApplication sharedApplication].keyWindow.subviews)
    {
        if ([alert isKindOfClass:[ACAlertView class]])
            self.alertView = alert;
    }
    downloadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80.0, 80.0)];
    downloadLabel.center = CGPointMake(CGRectGetMidX(self.alertView.bounds), CGRectGetMidY(self.alertView.bounds));
    downloadLabel.textAlignment = NSTextAlignmentCenter;
    downloadLabel.numberOfLines = 0;
    downloadLabel.font = [UIFont systemFontOfSize:9.0];
    downloadLabel.textColor = [UIColor whiteColor];
    [self.alertView addSubview:downloadLabel];
    
    if (![[[self appDelegate] allFeaturesUnlocked] boolValue])
    {
        NSInteger totalCount = [[CLFile fileWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] error:nil] directoryContents].count;
        if (totalCount >= 3)
        {
            [self.alertView dismiss];
            ACAlertView *alertView = [ACAlertView alertWithTitle:NSLocalizedString(@"Unlock", NULL) style:ACAlertViewStyleTextView delegate:nil buttonTitles:@[NSLocalizedString(@"Cancel", NULL), NSLocalizedString(@"Unlock", NULL)]];
            alertView.textView.text = NSLocalizedString(@"MaxFiles", NULL);
            [alertView showWithSelectionHandler:^(ACAlertView *alert, NSString *buttonTitle)
             {
                 if ([buttonTitle isEqualToString:NSLocalizedString(@"Unlock", NULL)])
                 {
                     [[self appDelegate] unlockFeatures];
                     
                     [alertView dismiss];
                 }
             }];
            return;
        }
    }
    previousSize = 0;
    elapsedTime = 1;
    timeElapsedTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerIncrement) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timeElapsedTimer forMode:NSRunLoopCommonModes];
    self.connection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
    [self.connection start];
}

- (void)timerIncrement
{
    elapsedTime++;
    CGFloat rate = (self.downloadedSize - previousSize);
    NSString *labelString = [NSString stringWithFormat:@"%@/%@\n%@/s", [[NSFileManager defaultManager] formattedSizeStringForBytes:self.downloadedSize], [[NSFileManager defaultManager] formattedSizeStringForBytes:self.totalSize], [[NSFileManager defaultManager] formattedSizeStringForBytes:rate]];
    downloadLabel.text = labelString;
    previousSize = self.downloadedSize;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.totalSize = response.expectedContentLength;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
    self.downloadedSize += data.length;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.alertView.progressView setProgress:self.downloadedSize/self.totalSize];
    });
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [timeElapsedTimer invalidate];
    [self.alertView dismiss];

    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *fileName;
    if (!self.fileName)
        fileName = [[connection.originalRequest.URL.absoluteString componentsSeparatedByString:@"?"][0] lastPathComponent];
    else
        fileName = self.fileName;
    
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:self.data attributes:nil];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"iCloud"])
        return;
    
    dispatch_async(dispatch_queue_create("com.a-c", NULL), ^{
        if (![self iCloudPath])
            return;
        NSString *iCloudDirectoryPath = [documentsDirectory stringByAppendingPathComponent:@".iCloud"];
        
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:iCloudDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                ACAlertView *errorAlert = [ACAlertView alertWithTitle:NSLocalizedString(@"Error", NULL) style:ACAlertViewStyleTextView delegate:nil buttonTitles:@[NSLocalizedString(@"Close", NULL)]];
                errorAlert.textView.text = [NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"iCloudDirError", NULL), error];
                [errorAlert show];
            });
            return;
        }
        
        NSString *iCloudFilePath = [iCloudDirectoryPath stringByAppendingPathComponent:fileName];
        NSString *iCloudFileContents = [NSString stringWithFormat:@"%@\n%@", fileName, connection.originalRequest.URL.absoluteString];
        [iCloudFileContents writeToFile:iCloudFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                ACAlertView *errorAlert = [ACAlertView alertWithTitle:NSLocalizedString(@"Error", NULL) style:ACAlertViewStyleTextView delegate:nil buttonTitles:@[NSLocalizedString(@"Close", NULL)]];
                errorAlert.textView.text = [NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"iCloudFileError", NULL), error];
                [errorAlert show];
            });
            return;
        }
        
        NSString *iCloudPath = [self iCloudPath];
        
        [[NSFileManager defaultManager] setUbiquitous:YES itemAtURL:[NSURL fileURLWithPath:iCloudFilePath] destinationURL:[NSURL fileURLWithPath:[iCloudPath stringByAppendingPathComponent:fileName]] error:&error];
        if (error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                ACAlertView *errorAlert = [ACAlertView alertWithTitle:NSLocalizedString(@"Error", NULL) style:ACAlertViewStyleTextView delegate:nil buttonTitles:@[NSLocalizedString(@"Close", NULL)]];
                errorAlert.textView.text = [NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"iCloudUbiqError", NULL), error];
                if (error.code != 516) //this would show every time a file was redownloaded - annoying
                    [errorAlert show];
            });
            error = nil;
        }
        
        [[NSFileManager defaultManager] removeItemAtPath:iCloudDirectoryPath error:&error];
        if (error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                ACAlertView *errorAlert = [ACAlertView alertWithTitle:NSLocalizedString(@"Error", NULL) style:ACAlertViewStyleTextView delegate:nil buttonTitles:@[NSLocalizedString(@"Close", NULL)]];
                errorAlert.textView.text = [NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"iCloudRemDirError", NULL), error];
                [errorAlert show];
            });
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CLDirectoryViewControllerRefreshNotification object:nil];
        });
    });
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

#pragma mark - Alert View Delegate

- (void)alertView:(ACAlertView *)alertView didClickButtonWithTitle:(NSString *)title
{
    if ([title isEqualToString:NSLocalizedString(@"Cancel", NULL)])
    {
        [timeElapsedTimer invalidate];
        [self.connection cancel];
        [alertView dismiss];
    }
    else if ([title isEqualToString:NSLocalizedString(@"Hide", NULL)])
    {
        [alertView hide];
    }
}

@end
