//
//  ACDirectoryViewController.h
//  ACFileNavigator
//
//  Created by Chris on 7/18/13.
//  Copyright (c) 2013 A and C Studios. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "ACFileCell.h"
#import "ACTextEditor.h"
#import "ACUnzip.h"
#import "ACFileActivities.h"
#import "ACSettingsViewController.h"
#import "ACZip.h"

@interface ACDirectoryViewController : UITableViewController <UIGestureRecognizerDelegate, UISearchBarDelegate, UIActionSheetDelegate, ACAlertViewDelegate>

@property (strong, nonatomic) MPMoviePlayerViewController *moviePlayer; //For playing video files
@property (strong, nonatomic) NSString *directoryPath; //The path to the directory to display
@property (strong, nonatomic) NSMutableArray *files; //The array of ACFile objects, each objects holds info for a file in the directory
@property (strong, nonatomic) UIToolbar *searchBar;

- (id)initWithDirectoryPath:(NSString *)dir;
- (void)updateFiles;

@end
