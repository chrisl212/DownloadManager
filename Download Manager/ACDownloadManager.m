//
//  ACDownloadManager.m
//  ACDownloadManager
//
//  Created by Chris on 1/25/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import "ACDownloadManager.h"

@implementation ACDownloadManager

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
    NSString *downloadsFilePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Downloads.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:downloadsFilePath])
    {
        [[NSFileManager defaultManager] createFileAtPath:downloadsFilePath contents:nil attributes:nil];
        [@[] writeToFile:downloadsFilePath atomically:YES];
    }
    NSMutableArray *downloadsArray = [[NSArray arrayWithContentsOfFile:downloadsFilePath] mutableCopy];
    NSDictionary *downloadDictionary = @{@"URL": url.absoluteString, @"File Name" : url.absoluteString.lastPathComponent, @"Progess" : [NSNumber numberWithDouble:0.0]};
    [downloadsArray addObject:downloadDictionary];
    [downloadsArray writeToFile:downloadsFilePath atomically:YES];
    
    self.connection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
    [self.connection start];
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
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [[connection.originalRequest.URL.absoluteString componentsSeparatedByString:@"?"][0] lastPathComponent];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:self.data attributes:nil];
    [self.alertView dismiss];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

#pragma mark - Alert View Delegate

- (void)alertView:(ACAlertView *)alertView didClickButtonWithTitle:(NSString *)title
{
    if ([title isEqualToString:@"Cancel"])
    {
        [self.connection cancel];
    }
}

@end
