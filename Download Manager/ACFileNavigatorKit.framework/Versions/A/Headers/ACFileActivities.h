//
//  FileActivities.h
//  ACFileBrowser
//
//  Created by Chris on 4/25/13.
//  Copyright (c) 2013 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ACTextEditor.h"
#import "ACAudioPlayerController.h"
#import "ACImageViewer.h"
#import "ACPropertyViewController.h"
#import "ACWebViewController.h"
#import "ACAlertView.h"
#import "ACZip.h"

/* These are all of the UIActivitys that are displayed when a UIActivityViewController is shown. The offer editors and viewers for quite a few different types of files. To create your own, follow the model of the others and see ACDirectoryViewController for how to insert it into a long press UIActivityViewController. The names here are pretty self-explanatory, so I won't go into too much depth for any of them. */

@interface ACTextEditorActivity : UIActivity

@property (strong, nonatomic) ACFile *file;
@property (strong, nonatomic) UIImage *activityImage;
@property (strong, nonatomic) NSString *activityType;
@property (strong, nonatomic) NSString *activityTitle;

@end

@interface ACFilePropertiesActivity : UIActivity

@property (strong, nonatomic) ACFile *file;
@property (strong, nonatomic) UIImage *activityImage;
@property (strong, nonatomic) NSString *activityType;
@property (strong, nonatomic) NSString *activityTitle;
@property (strong, nonatomic) UIImage *imageToUse;

@end

@interface ACCompressActivity : UIActivity <ACAlertViewDelegate>

@property (strong, nonatomic) ACFile *file;
@property (strong, nonatomic) UIImage *activityImage;
@property (strong, nonatomic) NSString *activityType;
@property (strong, nonatomic) NSString *activityTitle;
@property (strong, nonatomic) NSString *zipName;
@property (strong, nonatomic) UIImage *imageToUse;

@end

@interface ACDeCompressActivity : UIActivity

@property (strong, nonatomic) ACFile *file;
@property (strong, nonatomic) UIImage *activityImage;
@property (strong, nonatomic) NSString *activityType;
@property (strong, nonatomic) NSString *activityTitle;
@property (strong, nonatomic) UIImage *imageToUse;

@end

@interface ACMoviePlayerActivity: UIActivity
{
    MPMoviePlayerViewController *moviePlayer;
}

@property (strong, nonatomic) ACFile *file;
@property (strong, nonatomic) UIImage *activityImage;
@property (strong, nonatomic) NSString *activityType;
@property (strong, nonatomic) NSString *activityTitle;

@end

@interface ACAudioPlayerActivity : UIActivity

@property (strong, nonatomic) ACFile *file;
@property (strong, nonatomic) UIImage *activityImage;
@property (strong, nonatomic) NSString *activityType;
@property (strong, nonatomic) NSString *activityTitle;

@end

@interface ACWebViewerActivity : UIActivity

@property (strong, nonatomic) ACFile *file;
@property (strong, nonatomic) UIImage *activityImage;
@property (strong, nonatomic) NSString *activityType;
@property (strong, nonatomic) NSString *activityTitle;

@end

@interface ACImageViewerActivity : UIActivity

@property (strong, nonatomic) ACFile *file;
@property (strong, nonatomic) UIImage *activityImage;
@property (strong, nonatomic) NSString *activityType;
@property (strong, nonatomic) NSString *activityTitle;

@end

@interface ACDeleteActivity : UIActivity

@property (strong, nonatomic) ACFile *file;
@property (strong, nonatomic) UIImage *activityImage;
@property (strong, nonatomic) NSString *activityType;
@property (strong, nonatomic) NSString *activityTitle;

@end
