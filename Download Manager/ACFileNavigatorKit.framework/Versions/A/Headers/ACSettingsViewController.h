//
//  ACSettingsViewController.h
//  ACFileNavigator
//
//  Created by Chris on 1/19/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACAlertView.h"

@interface ACSettingsViewController : UITableViewController <ACAlertViewDelegate>

@property (strong, nonatomic) NSArray *fileTypeArray;

@end
