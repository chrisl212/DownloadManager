//
//  ACDownloadManager.h
//  ACDownloadManager
//
//  Created by Chris on 1/25/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CLFileNavigatorKit/CLFileNavigatorKit.h>

@interface ACDownloadManager : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate, ACAlertViewDelegate>

@property (weak, nonatomic) ACAlertView *alertView;
@property (strong, nonatomic) NSMutableData *data;
@property (nonatomic) long double downloadedSize;
@property (nonatomic) long double totalSize;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSString *fileName;

- (void)downloadFileAtURL:(NSURL *)url;

@end
